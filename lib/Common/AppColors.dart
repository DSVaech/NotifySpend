import 'package:flutter/material.dart';

// Paleta "Luxury" (Adobe Color): F0F0F2 · BFBFBF · 364959 · 8C8C8B · 0D0D0D.
// Modo claro: fondo F0F0F2, texto 0D0D0D y el azul pizarra como color
// principal.

const Color kBackground = Color(0xFFF0F0F2);
const Color kPrimary = Color(0xFF364959);
// Azul pizarra al 10 % sobre el fondo, para círculos e íconos destacados.
const Color kPrimarySurface = Color(0xFFDDDFE3);
// El rojo no está en la paleta, pero los errores necesitan verse como tales.
const Color kError = Color(0xFFB3261E);
const Color kTextPrimary = Color(0xFF0D0D0D);
// 8C8C8B oscurecido: sobre F0F0F2 no llegaba al contraste mínimo (4,5:1).
const Color kTextSecondary = Color(0xFF6B6B6A);
const Color kButtonBackground = Color(0xFFFFFFFF);
const Color kButtonBorder = Color(0xFFBFBFBF);

const BoxDecoration kScreenBackground = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(0, 0.1),
    radius: 0.9,
    colors: [Color(0xFFFFFFFF), kBackground],
  ),
);
