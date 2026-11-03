import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/PerfilService.dart';
import 'package:flutter_application_1/Common/PinStorage.dart';
import 'package:flutter_application_1/Pages/LoginFormPage.dart';
import 'package:flutter_application_1/Pages/LoginPage.dart';
import 'package:flutter_application_1/Pages/HomePage.dart';
import 'package:flutter_application_1/Pages/OnboardingPage.dart';
import 'package:flutter_application_1/Pages/PinPage.dart';
import 'package:flutter_application_1/Pages/PerfilPage.dart';
import 'package:flutter_application_1/Pages/RegisterPage.dart';
import 'package:flutter_application_1/Pages/SettingPage.dart';

const String ROUTE_HOME = '/';
const String ROUTE_LOGIN = '/login';
const String ROUTE_PIN = '/pin';
const String ROUTE_ONBOARDING = '/bienvenida';
const String ROUTE_PERFIL = '/perfil';
const String ROUTE_SETTINGS = '/settings';
const String ROUTE_CUENTA = '/cuenta';
const String ROUTE_REGISTRO = '/registro';

final GoRouter router = GoRouter(
  initialLocation: ROUTE_LOGIN,
  refreshListenable: _SesionListenable(AuthService.cambiosDeSesion),
  // Primer uso: cuenta → configuración inicial → crear PIN. Después, siempre
  // bloqueo. Al cerrar sesión se vuelve a empezar desde la cuenta.
  redirect: (context, state) async {
    final location = state.matchedLocation;
    final enCuenta = location == ROUTE_CUENTA || location == ROUTE_REGISTRO;
    if (!AuthService.haySesion) {
      return enCuenta ? null : ROUTE_CUENTA;
    }
    if (!await PerfilService.hasProfile()) {
      return location == ROUTE_ONBOARDING ? null : ROUTE_ONBOARDING;
    }
    if (!await PinStorage.hasPin()) {
      return location == ROUTE_PIN ? null : ROUTE_PIN;
    }
    return location == ROUTE_ONBOARDING || enCuenta ? ROUTE_LOGIN : null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: ROUTE_CUENTA,
      builder: (context, state) {
        return LoginFormPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_REGISTRO,
      builder: (context, state) {
        return RegisterPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_LOGIN,
      builder: (context, state) {
        return LoginPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_ONBOARDING,
      builder: (context, state) {
        return OnboardingPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_PIN,
      builder: (context, state) {
        return PinPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_HOME,
      builder: (context, state) {
        return HomePage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_PERFIL,
      builder: (context, state) {
        return PerfilPage();
      },
    ), // GoRoute
    GoRoute(
      path: ROUTE_SETTINGS,
      builder: (context, state) {
        return SettingPage();
      },
    ), // GoRoute
  ],
);

/// Avisa al router cada vez que alguien inicia o cierra sesión, para que
/// vuelva a evaluar el redirect.
class _SesionListenable extends ChangeNotifier {
  _SesionListenable(Stream<User?> cambios) {
    _subscription = cambios.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
