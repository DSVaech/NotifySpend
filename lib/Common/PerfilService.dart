import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Common/AuthService.dart';

/// Perfil del usuario en Firestore (`usuarios/{uid}`). Por ahora solo guarda
/// el presupuesto mensual; el nombre vive en la cuenta (`AuthService.nombre`).
class PerfilService {
  static DocumentReference<Map<String, dynamic>> get _perfil =>
      FirebaseFirestore.instance.collection('usuarios').doc(AuthService.uid);

  // El redirect del router pregunta en cada navegación: cuando ya sabemos que
  // hay perfil, no volvemos a leer Firestore.
  static bool _tienePerfil = false;

  static Future<bool> hasProfile() async {
    if (_tienePerfil) return true;
    try {
      final snapshot = await _perfil.get();
      _tienePerfil = snapshot.data()?['presupuesto'] != null;
    } on FirebaseException {
      // Sin conexión y sin caché: se repite la configuración inicial.
      _tienePerfil = false;
    }
    return _tienePerfil;
  }

  static Stream<double?> get presupuesto => _perfil.snapshots().map(
        (snapshot) => (snapshot.data()?['presupuesto'] as num?)?.toDouble(),
      );

  /// Como en `GastoService`, no hace falta esperar al servidor.
  static Future<void> guardarPresupuesto(double presupuesto) {
    _tienePerfil = true;
    return _perfil.set({'presupuesto': presupuesto}, SetOptions(merge: true));
  }

  /// Se llama al cerrar sesión, para que la siguiente cuenta se consulte de
  /// nuevo.
  static void olvidar() => _tienePerfil = false;
}
