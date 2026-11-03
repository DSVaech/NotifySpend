import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/Common/PerfilService.dart';
import 'package:flutter_application_1/Common/PinStorage.dart';

/// Cuenta del usuario en Firebase Authentication. Su `uid` identifica los
/// datos del usuario en Firestore; el PIN es lo único que queda solo en el
/// teléfono.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Avisa cada vez que alguien inicia o cierra sesión.
  static Stream<User?> get cambiosDeSesion => _auth.authStateChanges();

  static bool get haySesion => _auth.currentUser != null;

  static String? get uid => _auth.currentUser?.uid;

  static String? get correo => _auth.currentUser?.email;

  /// Nombre guardado en la cuenta, así se recupera al cambiar de teléfono.
  static String? get nombre {
    final nombre = _auth.currentUser?.displayName?.trim();
    return nombre == null || nombre.isEmpty ? null : nombre;
  }

  static Future<void> guardarNombre(String nombre) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(nombre.trim());
    await user.reload();
  }

  /// Crea la cuenta y, de una vez, inicia la sesión.
  static Future<void> registrar(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> ingresar(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Borra el PIN de este dispositivo y cierra la sesión. Los gastos y el
  /// presupuesto siguen en la cuenta; la siguiente persona que entre crea su
  /// propio PIN.
  static Future<void> salir() async {
    await PinStorage.clear();
    PerfilService.olvidar();
    await _auth.signOut();
  }
}

/// Traduce los códigos de Firebase a mensajes para el usuario.
String mensajeDeError(FirebaseAuthException e) => switch (e.code) {
      'email-already-in-use' => 'Ese correo ya está registrado.',
      'invalid-email' => 'El formato del correo no es válido.',
      'weak-password' => 'La contraseña debe tener mínimo 6 caracteres.',
      'invalid-credential' => 'Correo o contraseña incorrectos.',
      'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
      'network-request-failed' => 'Sin conexión a internet.',
      _ => 'Error inesperado (${e.code}).',
    };
