import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Pages/LoginFormPage.dart';
import 'package:flutter_application_1/Pages/RegisterPage.dart';

// Estas pruebas no llaman a Firebase: la validación del formulario corta
// antes de llegar al servicio.
void main() {
  test('mensajeDeError traduce los códigos de Firebase', () {
    expect(
      mensajeDeError(FirebaseAuthException(code: 'invalid-credential')),
      'Correo o contraseña incorrectos.',
    );
    expect(
      mensajeDeError(FirebaseAuthException(code: 'otro-codigo')),
      'Error inesperado (otro-codigo).',
    );
  });

  testWidgets('El inicio de sesión valida correo y contraseña', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginFormPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'sin-arroba');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Correo no válido'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
  });

  testWidgets('El registro exige que las contraseñas coincidan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@correo.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto1');
    await tester.enterText(find.byType(TextFormField).at(2), 'secreto2');
    await tester.ensureVisible(find.text('Registrarme'));
    await tester.tap(find.text('Registrarme'));
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });
}
