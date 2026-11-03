import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Gasto.dart';

/// Gastos del usuario con sesión, en `usuarios/{uid}/gastos`.
///
/// Firestore aplica cada cambio en su caché local al instante y lo sube cuando
/// hay conexión, así que las pantallas no esperan estos `Future`: sin internet
/// no terminarían nunca, pero el stream [gastos] ya muestra el cambio.
class GastoService {
  static CollectionReference<Map<String, dynamic>> get _gastos =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(AuthService.uid)
          .collection('gastos');

  /// Todos los gastos, del más reciente al más antiguo.
  static Stream<List<Gasto>> get gastos => _gastos
      .orderBy('fecha', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Gasto.fromDoc).toList());

  static Future<void> crear(Gasto gasto) => _gastos.add(gasto.toMap());

  static Future<void> actualizar(Gasto gasto) =>
      _gastos.doc(gasto.id).set(gasto.toMap());

  static Future<void> borrar(String id) => _gastos.doc(id).delete();
}
