import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/PinStorage.dart';
import 'package:flutter_application_1/Common/UserStorage.dart';
import 'package:flutter_application_1/Pages/LoginPage.dart';
import 'package:flutter_application_1/Pages/HomePage.dart';
import 'package:flutter_application_1/Pages/OnboardingPage.dart';
import 'package:flutter_application_1/Pages/PinPage.dart';
import 'package:flutter_application_1/Pages/PerfilPage.dart';
import 'package:flutter_application_1/Pages/SettingPage.dart';

const String ROUTE_HOME = '/';
const String ROUTE_LOGIN = '/login';
const String ROUTE_PIN = '/pin';
const String ROUTE_ONBOARDING = '/bienvenida';
const String ROUTE_PERFIL = '/perfil';
const String ROUTE_SETTINGS = '/settings';

final GoRouter router = GoRouter(
  initialLocation: ROUTE_LOGIN,
  // Primer uso: configuración inicial → crear PIN. Después, siempre bloqueo.
  redirect: (context, state) async {
    final location = state.matchedLocation;
    if (!await UserStorage.hasProfile()) {
      return location == ROUTE_ONBOARDING ? null : ROUTE_ONBOARDING;
    }
    if (!await PinStorage.hasPin()) {
      return location == ROUTE_PIN ? null : ROUTE_PIN;
    }
    return location == ROUTE_ONBOARDING ? ROUTE_LOGIN : null;
  },
  routes: <RouteBase>[
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
