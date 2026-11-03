import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/firebase_options.dart';

import 'Common/Routers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // La sesión guardada se recupera de forma asíncrona (sobre todo en web):
  // esperamos el primer aviso para que el redirect no mande a /cuenta por error.
  await AuthService.cambiosDeSesion.first;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Go Router Example',
      // Los colores de cada pantalla vienen de AppColors; el tema solo ajusta
      // lo que dibuja Material: diálogos, SnackBar y selector de fecha.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          error: kError,
          surface: kBackground,
        ),
      ),
      routerConfig: router,
    );
  }
}
