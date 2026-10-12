import 'package:flutter/material.dart';
import 'package:flutter_application_1/Common/AppColors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, color: kBackground, size: 36),
          Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Text(
              '\$',
              style: TextStyle(
                color: kBackground,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícono dentro de un círculo verde azulado, usado como encabezado de pantallas.
class CircleIcon extends StatelessWidget {
  const CircleIcon(this.icon, {super.key, this.size = 56});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0D3A3E),
        border: Border.all(color: kPrimary.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, color: kPrimary, size: size * 0.45),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kBackground,
          disabledBackgroundColor: kButtonBackground,
          disabledForegroundColor: kTextSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: kButtonBackground,
          foregroundColor: kTextPrimary,
          side: const BorderSide(color: kButtonBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
