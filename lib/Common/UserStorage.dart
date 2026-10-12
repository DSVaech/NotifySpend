import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Datos del perfil capturados en la configuración inicial. Se guardan
/// cifrados en el dispositivo hasta que exista la base de datos local.
class UserStorage {
  static const String _nombreKey = 'usuario_nombre';
  static const String _presupuestoKey = 'usuario_presupuesto';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> hasProfile() async {
    return await _storage.read(key: _presupuestoKey) != null;
  }

  static Future<void> saveProfile({
    required String nombre,
    required double presupuesto,
  }) async {
    await _storage.write(key: _nombreKey, value: nombre);
    await _storage.write(key: _presupuestoKey, value: presupuesto.toString());
  }

  static Future<String?> getNombre() => _storage.read(key: _nombreKey);

  static Future<double?> getPresupuesto() async {
    final value = await _storage.read(key: _presupuestoKey);
    return value == null ? null : double.tryParse(value);
  }
}
