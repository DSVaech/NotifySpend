import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Routers.dart';

/// Inicio de sesión con la cuenta de Firebase. Solo aparece cuando no hay
/// sesión en el dispositivo; al entrar, el redirect del router decide el
/// siguiente paso (configuración inicial, crear PIN o desbloqueo).
class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await AuthService.ingresar(_emailCtrl.text, _passCtrl.text);
      // No navegamos: el router escucha la sesión y redirige solo.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(e))),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Container(
        decoration: kScreenBackground,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              children: [
                const SizedBox(height: 56),
                const Center(child: AppLogo()),
                const SizedBox(height: 20),
                const Text(
                  'Inicia sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Usa tu cuenta de NotifySpend.\nTus gastos te esperan en cualquier teléfono.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                _EmailField(controller: _emailCtrl),
                const SizedBox(height: 16),
                _PasswordField(
                  controller: _passCtrl,
                  onSubmitted: _cargando ? null : _ingresar,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _cargando ? 'Ingresando…' : 'Ingresar',
                  onPressed: _cargando ? null : _ingresar,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push(ROUTE_REGISTRO),
                  style: TextButton.styleFrom(foregroundColor: kPrimary),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_rounded, color: kPrimary, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'Solo necesitas internet para iniciar sesión',
                      style: TextStyle(color: kTextSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: const TextStyle(color: kTextPrimary, fontSize: 16),
      cursorColor: kPrimary,
      decoration: appInputDecoration(
        hint: 'Correo electrónico',
        icon: Icons.email_outlined,
      ),
      validator: (v) => (v ?? '').contains('@') ? null : 'Correo no válido',
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: kTextPrimary, fontSize: 16),
      cursorColor: kPrimary,
      decoration: appInputDecoration(
        hint: 'Contraseña',
        icon: Icons.lock_outline_rounded,
      ),
      validator: (v) => (v ?? '').length >= 6 ? null : 'Mínimo 6 caracteres',
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
