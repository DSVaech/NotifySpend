import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/Formatos.dart';
import 'package:flutter_application_1/Common/Gasto.dart';
import 'package:flutter_application_1/Common/GastoService.dart';

/// Abre el formulario para registrar un gasto. Con [gasto] se abre en modo
/// edición y muestra el botón para borrarlo.
Future<void> mostrarGastoSheet(BuildContext context, {Gasto? gasto}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _GastoSheet(gasto: gasto),
  );
}

class _GastoSheet extends StatefulWidget {
  const _GastoSheet({this.gasto});

  final Gasto? gasto;

  @override
  State<_GastoSheet> createState() => _GastoSheetState();
}

class _GastoSheetState extends State<_GastoSheet> {
  late final TextEditingController _montoCtrl = TextEditingController(
    text: widget.gasto == null
        ? ''
        : formatThousands(widget.gasto!.monto.round().toString()),
  );
  late final TextEditingController _descripcionCtrl =
      TextEditingController(text: widget.gasto?.descripcion ?? '');
  late CategoriaGasto? _categoria = widget.gasto?.categoria;
  late DateTime _fecha = widget.gasto?.fecha ?? DateTime.now();

  bool get _editando => widget.gasto != null;

  double? get _monto => parseMonto(_montoCtrl.text);

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha.isAfter(ahora) ? ahora : _fecha,
      firstDate: DateTime(ahora.year - 5),
      lastDate: ahora,
    );
    if (elegida == null) return;
    // Conservamos la hora para no desordenar los movimientos de ese día.
    setState(() {
      _fecha = DateTime(
        elegida.year,
        elegida.month,
        elegida.day,
        _fecha.hour,
        _fecha.minute,
      );
    });
  }

  void _guardar() {
    final descripcion = _descripcionCtrl.text.trim();
    final gasto = Gasto(
      id: widget.gasto?.id,
      monto: _monto!,
      categoria: _categoria!,
      descripcion: descripcion.isEmpty ? null : descripcion,
      fecha: _fecha,
    );
    // No esperamos a Firestore: el tablero lo muestra al instante desde la
    // caché y se sube cuando haya conexión.
    unawaited(
      _editando ? GastoService.actualizar(gasto) : GastoService.crear(gasto),
    );
    Navigator.pop(context);
  }

  Future<void> _borrar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar este gasto?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    unawaited(GastoService.borrar(widget.gasto!.id!));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final puedeGuardar = _monto != null && _categoria != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kButtonBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _editando ? 'Editar gasto' : 'Nuevo gasto',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _montoCtrl,
              autofocus: !_editando,
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
            const SizedBox(height: 20),
            const _Label('Categoría'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CategoriaGasto.values.map((c) {
                return _CategoriaChip(
                  categoria: c,
                  seleccionada: c == _categoria,
                  onTap: () => setState(() => _categoria = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descripcionCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              style: const TextStyle(color: kTextPrimary, fontSize: 16),
              cursorColor: kPrimary,
              decoration: appInputDecoration(
                hint: 'Descripción (opcional)',
                icon: Icons.notes_rounded,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 12),
            _FechaButton(fecha: _fecha, onTap: _elegirFecha),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _editando ? 'Guardar cambios' : 'Guardar',
              onPressed: puedeGuardar ? _guardar : null,
            ),
            if (_editando) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _borrar,
                style: TextButton.styleFrom(foregroundColor: kError),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Borrar gasto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  const _CategoriaChip({
    required this.categoria,
    required this.seleccionada,
    required this.onTap,
  });

  final CategoriaGasto categoria;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: seleccionada,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: seleccionada ? categoria.color : kButtonBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionada ? categoria.color : kButtonBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoria.icono,
                color: seleccionada ? categoria.colorSobre : kTextPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                categoria.nombre,
                style: TextStyle(
                  color: seleccionada ? categoria.colorSobre : kTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FechaButton extends StatelessWidget {
  const _FechaButton({required this.fecha, required this.onTap});

  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kButtonBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kButtonBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: kTextSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatFecha(fecha),
                  style: const TextStyle(color: kTextPrimary, fontSize: 16),
                ),
              ),
              const Text(
                'Cambiar',
                style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
