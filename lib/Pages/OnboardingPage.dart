import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/Routers.dart';
import 'package:flutter_application_1/Common/UserStorage.dart';

/// Configuración inicial: bienvenida → nombre → permiso de notificaciones →
/// presupuesto mensual. Al terminar lleva a crear el PIN.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _stepCount = 4;

  final PageController _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _presupuestoController = TextEditingController();
  int _step = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
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

  double? get _presupuesto {
    final digits = _presupuestoController.text.replaceAll('.', '');
    final value = double.tryParse(digits);
    return value == null || value <= 0 ? null : value;
  }

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

  void _requestNotificationAccess() {
    // TODO: abrir el ajuste de Android "Acceso a notificaciones" cuando se
    // implemente el servicio que lee las notificaciones.
    _next();
  }

  Future<void> _finish() async {
    final presupuesto = _presupuesto;
    if (presupuesto == null) return;
    setState(() => _saving = true);
    await UserStorage.saveProfile(
      nombre: _nombreController.text.trim(),
      presupuesto: presupuesto,
    );
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
                      _NotificationsStep(
                        onAllow: _requestNotificationAccess,
                        onSkip: _next,
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

InputDecoration _inputDecoration({String? hint, String? prefix}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: kTextSecondary),
    prefixText: prefix,
    prefixStyle: const TextStyle(
      color: kPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    filled: true,
    fillColor: kButtonBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: border(kButtonBorder),
    focusedBorder: border(kPrimary),
  );
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
              'Cifrado en el dispositivo · funciona sin internet',
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
          'Controla tus gastos sin escribir nada.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSecondary, fontSize: 15),
        ),
        SizedBox(height: 36),
        _FeatureRow(
          icon: Icons.notifications_active_outlined,
          title: 'Registro automático',
          description: 'Leemos tus notificaciones de pago y anotamos cada gasto.',
        ),
        _FeatureRow(
          icon: Icons.bar_chart_rounded,
          title: 'Reportes visuales',
          description: 'Gráficas por categoría, semana y mes.',
        ),
        _FeatureRow(
          icon: Icons.lock_outline_rounded,
          title: 'Privado de verdad',
          description: 'Tus datos se quedan en el teléfono, cifrados.',
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
          subtitle: 'Así personalizamos tu tablero.',
        ),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 40,
          style: const TextStyle(color: kTextPrimary, fontSize: 18),
          cursorColor: kPrimary,
          decoration: _inputDecoration(hint: 'Tu nombre').copyWith(
            counterText: '',
          ),
          onSubmitted: (_) => onContinue?.call(),
        ),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.onAllow, required this.onSkip});

  final VoidCallback onAllow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      actions: [
        PrimaryButton(label: 'Dar permiso', onPressed: onAllow),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(foregroundColor: kTextSecondary),
          child: const Text('Ahora no'),
        ),
      ],
      children: const [
        _StepHeader(
          icon: Icons.notifications_active_outlined,
          title: 'Permite leer tus notificaciones',
          subtitle:
              'Así registramos tus gastos solos cada vez que pagas con tu banco o billetera digital.',
        ),
        _FeatureRow(
          icon: Icons.account_balance_outlined,
          title: 'Solo pagos',
          description: 'Leemos notificaciones de bancos, billeteras y facturas.',
        ),
        _FeatureRow(
          icon: Icons.phone_android_rounded,
          title: 'Nada sale del teléfono',
          description: 'El texto se procesa en el dispositivo, sin internet.',
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
              '$greeting¿cuánto quieres gastar al mes? Te avisaremos cuando te acerques al límite.',
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [_ThousandsFormatter()],
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          cursorColor: kPrimary,
          decoration: _inputDecoration(hint: '0', prefix: '\$ '),
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
        const SizedBox(height: 16),
        const Text(
          'Podrás cambiarlo y definir límites por categoría en Configuración.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

/// Formatea dígitos con punto como separador de miles: 1500000 → 1.500.000.
String formatThousands(String digits) {
  final clean = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final buffer = StringBuffer();
  for (var i = 0; i < clean.length; i++) {
    if (i > 0 && (clean.length - i) % 3 == 0) buffer.write('.');
    buffer.write(clean[i]);
  }
  return buffer.toString();
}

class _ThousandsFormatter extends TextInputFormatter {
  static const int _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > _maxDigits) return oldValue;
    final text = formatThousands(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
