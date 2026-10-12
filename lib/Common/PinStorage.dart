import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el PIN cifrado en el dispositivo. Nunca se almacena el PIN en
/// texto plano: solo un hash SHA-256 con sal aleatoria.
class PinStorage {
  static const int pinLength = 4;

  static const String _hashKey = 'pin_hash';
  static const String _saltKey = 'pin_salt';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> hasPin() async {
    return await _storage.read(key: _hashKey) != null;
  }

  static Future<void> savePin(String pin) async {
    final salt = _generateSalt();
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: _hash(pin, salt));
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _saltKey);
    final hash = await _storage.read(key: _hashKey);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  static String _hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
