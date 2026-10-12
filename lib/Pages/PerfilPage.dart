import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/Routers.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PERFIL PAGE'),
            ElevatedButton(
              onPressed: () {
                context.go(ROUTE_SETTINGS);
              },
              child: const Text('IR A SETTINGS'),
            ),
          ],
        ),
      ),
    );
  }
}
