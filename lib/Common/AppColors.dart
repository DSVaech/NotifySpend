import 'package:flutter/material.dart';

const Color kBackground = Color(0xFF0E1A28);
const Color kPrimary = Color(0xFF00D1B2);
const Color kError = Color(0xFFFF6B6B);
const Color kTextPrimary = Color(0xFFF5F7FA);
const Color kTextSecondary = Color(0xFF9AA8B8);
const Color kButtonBackground = Color(0xFF172433);
const Color kButtonBorder = Color(0xFF2C3A4A);

const BoxDecoration kScreenBackground = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(0, 0.1),
    radius: 0.9,
    colors: [Color(0xFF0F2E36), kBackground],
  ),
);
