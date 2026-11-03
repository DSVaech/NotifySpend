import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/Common/Formatos.dart';
import 'package:flutter_application_1/Common/Gasto.dart';

void main() {
  // Miércoles 4 de noviembre de 2026, 10:30 a. m.
  final ahora = DateTime(2026, 11, 4, 10, 30);

  Gasto gasto(double monto, CategoriaGasto categoria, DateTime fecha) =>
      Gasto(monto: monto, categoria: categoria, fecha: fecha);

  final gastos = [
    gasto(20000, CategoriaGasto.comida, DateTime(2026, 11, 4, 8)), // hoy
    gasto(5000, CategoriaGasto.transporte, DateTime(2026, 11, 2, 7)), // lunes
    gasto(50000, CategoriaGasto.ocio, DateTime(2026, 11, 1, 20)), // domingo
    gasto(90000, CategoriaGasto.compras, DateTime(2026, 10, 31, 12)), // octubre
  ];

  test('Cada periodo empieza hoy, el lunes o el día 1', () {
    expect(inicioDelPeriodo(Periodo.dia, ahora), DateTime(2026, 11, 4));
    expect(inicioDelPeriodo(Periodo.semana, ahora), DateTime(2026, 11, 2));
    expect(inicioDelPeriodo(Periodo.mes, ahora), DateTime(2026, 11, 1));
  });

  test('Los totales solo cuentan los gastos del periodo', () {
    expect(totalDe(gastosDelPeriodo(gastos, Periodo.dia, ahora)), 20000);
    expect(totalDe(gastosDelPeriodo(gastos, Periodo.semana, ahora)), 25000);
    expect(totalDe(gastosDelPeriodo(gastos, Periodo.mes, ahora)), 75000);
  });

  test('Las categorías se ordenan de mayor a menor', () {
    final totales =
        totalesPorCategoria(gastosDelPeriodo(gastos, Periodo.mes, ahora));
    expect(totales.map((t) => t.categoria), [
      CategoriaGasto.ocio,
      CategoriaGasto.comida,
      CategoriaGasto.transporte,
    ]);
    expect(totales.first.total, 50000);
  });

  test('Formatos de montos y fechas', () {
    expect(formatMoney(1500000), '\$ 1.500.000');
    expect(parseMonto('1.500.000'), 1500000);
    expect(parseMonto(''), isNull);
    expect(formatFecha(DateTime(2026, 11, 4, 13, 24), ahora: ahora),
        'Hoy, 1:24 p. m.');
    expect(formatFecha(DateTime(2026, 11, 3, 0, 5), ahora: ahora),
        'Ayer, 12:05 a. m.');
    expect(formatFecha(DateTime(2025, 12, 24, 20), ahora: ahora),
        '24 dic 2025, 8:00 p. m.');
  });
}
