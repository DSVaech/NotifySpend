import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/Routers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('HOME PAGE'),
            ElevatedButton(
              onPressed: () {
                context.go(ROUTE_LOGIN);
              },
              child: const Text('IR A LOGIN'),
            ),
          ],
        ),
      ),
    );
  }
}
