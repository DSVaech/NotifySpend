import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Common/AppColors.dart';

/// Categorías fijas del MVP. En Firestore se guarda el `name` del enum
/// (`comida`, `transporte`…), así que no se deben renombrar. Sus colores son
/// los cuatro tonos de la paleta que se ven sobre el fondo claro.
enum CategoriaGasto {
  comida('Comida', Icons.restaurant_rounded, Color(0xFF364959)),
  transporte('Transporte', Icons.directions_bus_rounded, Color(0xFF0D0D0D)),
  compras('Compras', Icons.shopping_bag_rounded, Color(0xFF8C8C8B)),
  ocio('Ocio', Icons.local_activity_rounded, Color(0xFFBFBFBF));

  const CategoriaGasto(this.nombre, this.icono, this.color);

  final String nombre;
  final IconData icono;
  final Color color;

  /// Color legible para un ícono o texto sobre [color].
  Color get colorSobre =>
      color.computeLuminance() > 0.4 ? kTextPrimary : kBackground;
}

/// Un gasto registrado a mano. Se guarda en `usuarios/{uid}/gastos/{id}`.
class Gasto {
  const Gasto({
    this.id,
    required this.monto,
    required this.categoria,
    this.descripcion,
    required this.fecha,
  });

  /// null mientras el gasto no se ha guardado.
  final String? id;
  final double monto;
  final CategoriaGasto categoria;
  final String? descripcion;
  final DateTime fecha;

  factory Gasto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Gasto(
      id: doc.id,
      monto: (data['monto'] as num).toDouble(),
      categoria: CategoriaGasto.values.byName(data['categoria'] as String),
      descripcion: data['descripcion'] as String?,
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'monto': monto,
        'categoria': categoria.name,
        'descripcion': descripcion,
        'fecha': Timestamp.fromDate(fecha),
      };
}

enum Periodo { dia, semana, mes }

/// Desde cuándo cuenta cada periodo: hoy, el lunes de esta semana o el día 1
/// del mes.
DateTime inicioDelPeriodo(Periodo periodo, DateTime ahora) {
  return switch (periodo) {
    Periodo.dia => DateTime(ahora.year, ahora.month, ahora.day),
    Periodo.semana =>
      DateTime(ahora.year, ahora.month, ahora.day - (ahora.weekday - 1)),
    Periodo.mes => DateTime(ahora.year, ahora.month),
  };
}

List<Gasto> gastosDelPeriodo(
  List<Gasto> gastos,
  Periodo periodo,
  DateTime ahora,
) {
  final inicio = inicioDelPeriodo(periodo, ahora);
  return gastos.where((g) => !g.fecha.isBefore(inicio)).toList();
}

double totalDe(List<Gasto> gastos) =>
    gastos.fold<double>(0, (suma, g) => suma + g.monto);

/// Total de cada categoría con gastos, de mayor a menor.
List<({CategoriaGasto categoria, double total})> totalesPorCategoria(
  List<Gasto> gastos,
) {
  final totales = <CategoriaGasto, double>{};
  for (final g in gastos) {
    totales[g.categoria] = (totales[g.categoria] ?? 0) + g.monto;
  }
  return totales.entries
      .map((e) => (categoria: e.key, total: e.value))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}
