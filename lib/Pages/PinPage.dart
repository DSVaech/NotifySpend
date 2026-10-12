import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/PinStorage.dart';
import 'package:flutter_application_1/Common/Routers.dart';

enum _PinMode { loading, create, confirm, verify }

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  static const int _maxAttempts = 5;
  static const int _lockoutSeconds = 30;

  _PinMode _mode = _PinMode.loading;
  String _pin = '';
  String _firstPin = '';
  String? _error;
  bool _busy = false;
  int _failedAttempts = 0;
  int _lockoutRemaining = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMode() async {
    final hasPin = await PinStorage.hasPin();
    if (!mounted) return;
    setState(() => _mode = hasPin ? _PinMode.verify : _PinMode.create);
  }

  bool get _locked => _lockoutRemaining > 0;

  String get _title {
    switch (_mode) {
      case _PinMode.create:
        return 'Crea tu PIN';
      case _PinMode.confirm:
        return 'Confirma tu PIN';
      case _PinMode.verify:
      case _PinMode.loading:
        return 'Ingresa tu PIN';
    }
  }

  String get _subtitle {
    if (_locked) return 'Demasiados intentos. Espera $_lockoutRemaining s';
    switch (_mode) {
      case _PinMode.create:
        return 'Elige ${PinStorage.pinLength} dígitos para desbloquear la app';
      case _PinMode.confirm:
        return 'Vuelve a ingresar los ${PinStorage.pinLength} dígitos';
      case _PinMode.verify:
      case _PinMode.loading:
        return 'Desbloquea NotifySpend';
    }
  }

  void _onDigit(String digit) {
    if (_busy || _locked || _pin.length >= PinStorage.pinLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == PinStorage.pinLength) _submit();
  }

  void _onDelete() {
    if (_busy || _locked || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    switch (_mode) {
      case _PinMode.create:
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _mode = _PinMode.confirm;
        });
        break;
      case _PinMode.confirm:
        if (_pin == _firstPin) {
          await PinStorage.savePin(_pin);
          if (!mounted) return;
          context.go(ROUTE_HOME);
          return;
        }
        setState(() {
          _error = 'Los PIN no coinciden. Inténtalo de nuevo';
          _pin = '';
          _firstPin = '';
          _mode = _PinMode.create;
        });
        break;
      case _PinMode.verify:
        final ok = await PinStorage.verifyPin(_pin);
        if (!mounted) return;
        if (ok) {
          context.go(ROUTE_HOME);
          return;
        }
        HapticFeedback.heavyImpact();
        _failedAttempts++;
        setState(() {
          _pin = '';
          _error = 'PIN incorrecto';
        });
        if (_failedAttempts >= _maxAttempts) _startLockout();
        break;
      case _PinMode.loading:
        break;
    }
    if (mounted) setState(() => _busy = false);
  }

  void _startLockout() {
    _failedAttempts = 0;
    setState(() {
      _error = null;
      _lockoutRemaining = _lockoutSeconds;
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _lockoutRemaining--);
      if (_lockoutRemaining <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Container(
        decoration: kScreenBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go(ROUTE_LOGIN),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: kTextPrimary,
                    tooltip: 'Volver',
                  ),
                ),
                const SizedBox(height: 32),
                const CircleIcon(Icons.lock_outline_rounded),
                const SizedBox(height: 20),
                Text(
                  _title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _locked ? kError : kTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),
                _PinDots(filled: _pin.length, hasError: _error != null),
                const SizedBox(height: 16),
                SizedBox(
                  height: 20,
                  child: Text(
                    _error ?? '',
                    style: const TextStyle(color: kError, fontSize: 13),
                  ),
                ),
                const Spacer(),
                _PinKeypad(
                  enabled: !_locked && _mode != _PinMode.loading,
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled, required this.hasError});

  final int filled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final activeColor = hasError ? kError : kPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(PinStorage.pinLength, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? activeColor : Colors.transparent,
            border: Border.all(
              color: isFilled || hasError ? activeColor : kButtonBorder,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_buildKey).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    const size = 72.0;
    if (key.isEmpty) return const SizedBox(width: size, height: size);

    final isDelete = key == 'del';
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: isDelete ? Colors.transparent : kButtonBackground,
        shape: CircleBorder(
          side: BorderSide(
            color: isDelete ? Colors.transparent : kButtonBorder,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? (isDelete ? onDelete : () => onDigit(key)) : null,
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.backspace_outlined,
                    color: kTextSecondary,
                    semanticLabel: 'Borrar',
                  )
                : Text(
                    key,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
