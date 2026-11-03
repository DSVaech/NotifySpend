import 'package:flutter/services.dart';

const List<String> _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto',
  'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const List<String> _mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov',
  'dic',
];

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

/// 1500000 → "$ 1.500.000".
String formatMoney(double value) => '\$ ${formatThousands(value.round().toString())}';

/// "Noviembre 2026".
String formatMes(DateTime fecha) => '${_meses[fecha.month - 1]} ${fecha.year}';

/// "1:24 p. m."
String formatHora(DateTime fecha) {
  final hora = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final minutos = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minutos ${fecha.hour < 12 ? 'a. m.' : 'p. m.'}';
}

/// "Hoy, 1:24 p. m.", "Ayer, 8:10 p. m.", "3 nov, 9:15 p. m." o, si es de
/// otro año, "3 nov 2025, 9:15 p. m.".
String formatFecha(DateTime fecha, {DateTime? ahora}) {
  ahora ??= DateTime.now();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final dia = DateTime(fecha.year, fecha.month, fecha.day);
  final diferencia = hoy.difference(dia).inDays;
  final String prefijo;
  if (diferencia == 0) {
    prefijo = 'Hoy';
  } else if (diferencia == 1) {
    prefijo = 'Ayer';
  } else {
    final anio = fecha.year == ahora.year ? '' : ' ${fecha.year}';
    prefijo = '${fecha.day} ${_mesesCortos[fecha.month - 1]}$anio';
  }
  return '$prefijo, ${formatHora(fecha)}';
}

/// Campo de montos: solo dígitos, con separador de miles mientras se escribe.
class ThousandsFormatter extends TextInputFormatter {
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

/// Lee un monto escrito con [ThousandsFormatter]. Devuelve null si está vacío
/// o es cero.
double? parseMonto(String text) {
  final value = double.tryParse(text.replaceAll('.', ''));
  return value == null || value <= 0 ? null : value;
}
