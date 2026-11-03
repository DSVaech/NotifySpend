import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Formatos.dart';
import 'package:flutter_application_1/Common/PerfilService.dart';
import 'package:flutter_application_1/Common/Routers.dart';

/// Configuración inicial: bienvenida → nombre → presupuesto mensual. Al
/// terminar lleva a crear el PIN. El nombre se guarda en la cuenta y el
/// presupuesto en Firestore; si la cuenta ya tiene nombre, se propone ese.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _stepCount = 3;

  final PageController _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _presupuestoController = TextEditingController();
  int _step = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = AuthService.nombre ?? '';
    _nombreController.addListener(() => setState(() {}));
    _presupuestoController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }

  double? get _presupuesto => parseMonto(_presupuestoController.text);

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() => _goTo(_step + 1);

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  Future<void> _finish() async {
    final presupuesto = _presupuesto;
    if (presupuesto == null) return;
    final nombre = _nombreController.text.trim();
    setState(() => _saving = true);
    try {
      await AuthService.guardarNombre(nombre);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(e))),
      );
      return;
    }
    // Firestore lo guarda en su caché al instante; no esperamos al servidor.
    unawaited(PerfilService.guardarPresupuesto(presupuesto));
    if (!mounted) return;
    setState(() => _saving = false);
    context.push(ROUTE_PIN);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: kBackground,
        body: Container(
          decoration: kScreenBackground,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: _step == 0
                      ? null
                      : Row(
                          children: [
                            IconButton(
                              onPressed: _back,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: kTextPrimary,
                              tooltip: 'Volver',
                            ),
                            Expanded(
                              child: _StepProgress(
                                current: _step,
                                total: _stepCount - 1,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomeStep(onStart: _next),
                      _NameStep(
                        controller: _nombreController,
                        onContinue: _nombreController.text.trim().isEmpty
                            ? null
                            : _next,
                      ),
                      _BudgetStep(
                        nombre: _nombreController.text.trim(),
                        controller: _presupuestoController,
                        onContinue:
                            _presupuesto == null || _saving ? null : _finish,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index < current ? kPrimary : kButtonBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Estructura común de cada paso: contenido arriba y acciones abajo,
/// con scroll cuando aparece el teclado.
class _StepLayout extends StatelessWidget {
  const _StepLayout({required this.children, required this.actions});

  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  ...children,
                  const Spacer(),
                  const SizedBox(height: 24),
                  ...actions,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        CircleIcon(icon),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kTextSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kButtonBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kButtonBorder),
      ),
      child: Row(
        children: [
          CircleIcon(icon, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: kTextSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      actions: [
        PrimaryButton(label: 'Comenzar', onPressed: onStart),
        const SizedBox(height: 18),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, color: kPrimary, size: 14),
            SizedBox(width: 8),
            Text(
              'Protegido con PIN · sincronizado con tu cuenta',
              style: TextStyle(color: kTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
      children: const [
        SizedBox(height: 16),
        AppLogo(),
        SizedBox(height: 20),
        Text(
          'Bienvenido a NotifySpend',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kTextPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Controla tus gastos en segundos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSecondary, fontSize: 15),
        ),
        SizedBox(height: 36),
        _FeatureRow(
          icon: Icons.add_card_rounded,
          title: 'Registro rápido',
          description: 'Anota cada gasto con su monto y categoría, y listo.',
        ),
        _FeatureRow(
          icon: Icons.bar_chart_rounded,
          title: 'Reportes visuales',
          description: 'Gráficas por categoría, semana y mes.',
        ),
        _FeatureRow(
          icon: Icons.cloud_done_outlined,
          title: 'Siempre contigo',
          description: 'Tus gastos se guardan en tu cuenta, aunque cambies de teléfono.',
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onContinue});

  final TextEditingController controller;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      actions: [PrimaryButton(label: 'Continuar', onPressed: onContinue)],
      children: [
        const _StepHeader(
          icon: Icons.person_outline_rounded,
          title: '¿Cómo te llamas?',
          subtitle:
              'Así personalizamos tu tablero. Se guarda en tu cuenta para que no tengas que escribirlo de nuevo.',
        ),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 40,
          style: const TextStyle(color: kTextPrimary, fontSize: 18),
          cursorColor: kPrimary,
          decoration: appInputDecoration(hint: 'Tu nombre').copyWith(
            counterText: '',
          ),
          onSubmitted: (_) => onContinue?.call(),
        ),
      ],
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({
    required this.nombre,
    required this.controller,
    required this.onContinue,
  });

  static const List<int> _suggestions = [500000, 1000000, 2000000];

  final String nombre;
  final TextEditingController controller;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final greeting = nombre.isEmpty ? '' : '$nombre, ';
    return _StepLayout(
      actions: [PrimaryButton(label: 'Continuar', onPressed: onContinue)],
      children: [
        _StepHeader(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Define tu presupuesto',
          subtitle:
              '$greeting¿cuánto quieres gastar al mes? En tu tablero verás cuánto te queda.',
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsFormatter()],
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          cursorColor: kPrimary,
          decoration: appInputDecoration(hint: '0', prefix: '\$ '),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _suggestions.map((value) {
            final text = formatThousands(value.toString());
            return ActionChip(
              label: Text('\$ $text'),
              labelStyle: const TextStyle(color: kTextPrimary),
              backgroundColor: kButtonBackground,
              side: const BorderSide(color: kButtonBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
