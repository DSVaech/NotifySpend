import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Formatos.dart';
import 'package:flutter_application_1/Common/Gasto.dart';
import 'package:flutter_application_1/Common/GastoService.dart';
import 'package:flutter_application_1/Common/PerfilService.dart';
import 'package:flutter_application_1/Common/Routers.dart';
import 'package:flutter_application_1/Pages/GastoSheet.dart';

/// Tablero principal: resumen del periodo, gasto por categoría y movimientos.
/// Todo se calcula a partir de los gastos que el usuario registra a mano.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _ultimosVisibles = 5;

  final Stream<List<Gasto>> _gastos = GastoService.gastos;
  final Stream<double?> _presupuesto = PerfilService.presupuesto;
  Periodo _periodo = Periodo.mes;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Container(
        decoration: kScreenBackground,
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<double?>(
            stream: _presupuesto,
            builder: (context, presupuesto) {
              return StreamBuilder<List<Gasto>>(
                stream: _gastos,
                builder: (context, gastos) {
                  if (gastos.hasError) {
                    return _ErrorMessage(error: gastos.error!);
                  }
                  if (!gastos.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    );
                  }
                  return _tab == 0
                      ? _tablero(gastos.data!, presupuesto.data)
                      : _movimientos(gastos.data!);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarGastoSheet(context),
        backgroundColor: kPrimary,
        foregroundColor: kBackground,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar gasto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onTap: (i) {
          if (i == 2) {
            context.go(ROUTE_SETTINGS);
            return;
          }
          setState(() => _tab = i);
        },
      ),
    );
  }

  Widget _tablero(List<Gasto> gastos, double? presupuesto) {
    final ahora = DateTime.now();
    final delPeriodo = gastosDelPeriodo(gastos, _periodo, ahora);
    final gastadoMes = totalDe(gastosDelPeriodo(gastos, Periodo.mes, ahora));

    return ListView(
      // Espacio abajo para que el botón flotante no tape el último movimiento.
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        _Header(subtitulo: formatMes(ahora)),
        const SizedBox(height: 20),
        _PeriodSelector(
          value: _periodo,
          onChanged: (p) => setState(() => _periodo = p),
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          periodo: _periodo,
          total: totalDe(delPeriodo),
          gastadoMes: gastadoMes,
          presupuesto: presupuesto,
          ahora: ahora,
        ),
        const SizedBox(height: 16),
        _CategoriesCard(totales: totalesPorCategoria(delPeriodo)),
        const SizedBox(height: 16),
        _MovimientosCard(
          titulo: 'Últimos movimientos',
          gastos: gastos.take(_ultimosVisibles).toList(),
          onVerTodos: gastos.length > _ultimosVisibles
              ? () => setState(() => _tab = 1)
              : null,
        ),
      ],
    );
  }

  Widget _movimientos(List<Gasto> gastos) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        _Header(
          titulo: 'Movimientos',
          subtitulo: '${gastos.length} ${gastos.length == 1 ? 'gasto' : 'gastos'}'
              ' · ${formatMoney(totalDe(gastos))}',
        ),
        const SizedBox(height: 20),
        _MovimientosCard(titulo: 'Todos', gastos: gastos),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.titulo, required this.subtitulo});

  /// Si es null, saluda al usuario por su nombre.
  final String? titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final nombre = AuthService.nombre;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo ?? (nombre == null ? 'Hola' : 'Hola, $nombre'),
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(color: kTextSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.lock_outline_rounded,
          tooltip: 'Bloquear app',
          onPressed: () => context.go(ROUTE_LOGIN),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kButtonBackground,
      shape: const CircleBorder(side: BorderSide(color: kButtonBorder)),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: kTextPrimary, size: 22),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kButtonBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kButtonBorder),
      ),
      child: child,
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: kError, size: 40),
            const SizedBox(height: 12),
            const Text(
              'No pudimos cargar tus gastos.',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: kTextSecondary, fontSize: 14, height: 1.5),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});

  final Periodo value;
  final ValueChanged<Periodo> onChanged;

  static const Map<Periodo, String> _labels = {
    Periodo.dia: 'Día',
    Periodo.semana: 'Semana',
    Periodo.mes: 'Mes',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kButtonBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kButtonBorder),
      ),
      child: Row(
        children: Periodo.values.map((p) {
          final selected = p == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _labels[p]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? kBackground : kTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.periodo,
    required this.total,
    required this.gastadoMes,
    required this.presupuesto,
    required this.ahora,
  });

  final Periodo periodo;
  final double total;
  final double gastadoMes;
  final double? presupuesto;
  final DateTime ahora;

  static const Map<Periodo, String> _titles = {
    Periodo.dia: 'Gastado hoy',
    Periodo.semana: 'Gastado esta semana',
    Periodo.mes: 'Gastado este mes',
  };

  @override
  Widget build(BuildContext context) {
    final presupuesto = this.presupuesto;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titles[periodo]!,
            style: const TextStyle(color: kTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            formatMoney(total),
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (presupuesto != null && presupuesto > 0) ...[
            const SizedBox(height: 20),
            _BudgetProgress(
              presupuesto: presupuesto,
              gastadoMes: gastadoMes,
              ahora: ahora,
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({
    required this.presupuesto,
    required this.gastadoMes,
    required this.ahora,
  });

  final double presupuesto;
  final double gastadoMes;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final progress = gastadoMes / presupuesto;
    final barColor = progress >= 0.8 ? kError : kPrimary;
    final restante = presupuesto - gastadoMes;
    final dias =
        DateUtils.getDaysInMonth(ahora.year, ahora.month) - ahora.day + 1;
    final diasTexto = dias == 1 ? 'último día' : '$dias días';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Presupuesto mensual',
              style: TextStyle(color: kTextSecondary, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}% de ${formatMoney(presupuesto)}',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1).toDouble(),
            minHeight: 10,
            backgroundColor: kButtonBorder,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          restante >= 0
              ? 'Te quedan ${formatMoney(restante)} · $diasTexto'
              : 'Te pasaste por ${formatMoney(-restante)} · $diasTexto',
          style: TextStyle(
            color: restante >= 0 ? kTextSecondary : kError,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.totales});

  /// De mayor a menor, como lo devuelve `totalesPorCategoria`.
  final List<({CategoriaGasto categoria, double total})> totales;

  @override
  Widget build(BuildContext context) {
    if (totales.isEmpty) {
      return const _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Por categoría'),
            _EmptyMessage('Sin gastos en este periodo.'),
          ],
        ),
      );
    }

    final total = totales.fold<double>(0, (suma, t) => suma + t.total);
    final principal = totales.first;
    final porcentajePrincipal = (principal.total / total * 100).round();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Por categoría'),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: CustomPaint(
                  painter: _DonutPainter(totales, total),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$porcentajePrincipal%',
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          principal.categoria.nombre,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: totales.map((t) {
                    final pct = (t.total / total * 100).round();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: t.categoria.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.categoria.nombre,
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.totales, this.total);

  final List<({CategoriaGasto categoria, double total})> totales;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    // Con una sola categoría el aro va completo, sin separación.
    final gap = totales.length > 1 ? 0.04 : 0.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (final t in totales) {
      final sweep = t.total / total * 2 * math.pi;
      paint.color = t.categoria.color;
      canvas.drawArc(rect, start + gap / 2, math.max(sweep - gap, 0.01), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.totales != totales || oldDelegate.total != total;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: kPrimary,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

class _MovimientosCard extends StatelessWidget {
  const _MovimientosCard({
    required this.titulo,
    required this.gastos,
    this.onVerTodos,
  });

  final String titulo;
  final List<Gasto> gastos;
  final VoidCallback? onVerTodos;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SectionTitle(titulo, action: 'Ver todos', onAction: onVerTodos),
          const SizedBox(height: 8),
          if (gastos.isEmpty)
            const _EmptyMessage(
              'Aún no registras gastos.\nToca "Registrar gasto" para empezar.',
            ),
          ...gastos.map((g) => _TransactionTile(g)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile(this.gasto);

  final Gasto gasto;

  @override
  Widget build(BuildContext context) {
    final categoria = gasto.categoria;
    final descripcion = gasto.descripcion;
    return InkWell(
      onTap: () => mostrarGastoSheet(context, gasto: gasto),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: categoria.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoria.icono, color: categoria.colorSobre, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descripcion ?? categoria.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion == null
                        ? formatFecha(gasto.fecha)
                        : '${categoria.nombre} · ${formatFecha(gasto.fecha)}',
                    style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '- ${formatMoney(gasto.monto)}',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: kButtonBackground,
        indicatorColor: kPrimary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? kPrimary
                : kTextSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? kPrimary
                : kTextSecondary,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Movimientos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
