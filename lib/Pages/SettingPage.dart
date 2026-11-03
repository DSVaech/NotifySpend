import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Routers.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Se borrará tu PIN de este dispositivo. '
          'Tus gastos y tu presupuesto siguen guardados en tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    // El router escucha la sesión y lleva solo a la pantalla de cuenta.
    if (confirmado == true) await AuthService.salir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SETTINGS PAGE'),
            Text(AuthService.nombre ?? ''),
            Text(AuthService.correo ?? ''),
            ElevatedButton(
              onPressed: () {
                context.go(ROUTE_HOME);
              },
              child: const Text('VOLVER AL INICIO'),
            ),
            ElevatedButton(
              onPressed: () => _cerrarSesion(context),
              child: const Text('CERRAR SESIÓN'),
            ),
          ],
        ),
      ),
    );
  }
}
