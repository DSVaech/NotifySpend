import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/Routers.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _unlock(BuildContext context) {
    // TODO: autenticación biométrica real (local_auth). Mientras tanto,
    // el sensor lleva al PIN para no dejar la app sin protección.
    context.push(ROUTE_PIN);
  }

  void _usePin(BuildContext context) {
    context.push(ROUTE_PIN);
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
                const SizedBox(height: 72),
                const AppLogo(),
                const SizedBox(height: 20),
                const Text(
                  'NotifySpend',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tus gastos se registran solos.\nTus datos nunca salen del teléfono.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                _FingerprintSensor(onTap: () => _unlock(context)),
                const SizedBox(height: 16),
                const Text(
                  'Toca el sensor para desbloquear',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Huella o reconocimiento facial',
                  style: TextStyle(color: kTextSecondary, fontSize: 14),
                ),
                const Spacer(),
                SecondaryButton(
                  label: 'Usar PIN',
                  onPressed: () => _usePin(context),
                ),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FingerprintSensor extends StatelessWidget {
  const _FingerprintSensor({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Desbloquear con biometría',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kPrimary.withValues(alpha: 0.15),
              width: 3,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D3A3E),
              border: Border.all(
                color: kPrimary.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.fingerprint,
              color: kPrimary,
              size: 64,
              shadows: [
                Shadow(color: kPrimary.withValues(alpha: 0.6), blurRadius: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
