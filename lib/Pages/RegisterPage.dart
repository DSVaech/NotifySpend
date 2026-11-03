import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/Common/AppColors.dart';
import 'package:flutter_application_1/Common/AppWidgets.dart';
import 'package:flutter_application_1/Common/AuthService.dart';
import 'package:flutter_application_1/Common/Routers.dart';

/// Crea la cuenta de Firebase. Firebase inicia la sesión al registrarse, así
/// que el router lleva directo a la configuración inicial.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await AuthService.registrar(_emailCtrl.text, _passCtrl.text);
      // No navegamos: el router escucha la sesión y redirige solo.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(e))),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Container(
        decoration: kScreenBackground,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(ROUTE_CUENTA),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: kTextPrimary,
                    tooltip: 'Volver',
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: CircleIcon(Icons.person_add_alt_1_outlined)),
                      const SizedBox(height: 20),
                      const Text(
                        'Crear cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Con tu correo podrás volver a entrar si cambias de teléfono.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        style: const TextStyle(color: kTextPrimary, fontSize: 16),
                        cursorColor: kPrimary,
                        decoration: appInputDecoration(
                          hint: 'Correo electrónico',
                          icon: Icons.email_outlined,
                        ),
                        validator: (v) =>
                            (v ?? '').contains('@') ? null : 'Correo no válido',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: kTextPrimary, fontSize: 16),
                        cursorColor: kPrimary,
                        decoration: appInputDecoration(
                          hint: 'Contraseña',
                          icon: Icons.lock_outline_rounded,
                        ),
                        validator: (v) =>
                            (v ?? '').length >= 6 ? null : 'Mínimo 6 caracteres',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: kTextPrimary, fontSize: 16),
                        cursorColor: kPrimary,
                        decoration: appInputDecoration(
                          hint: 'Confirmar contraseña',
                          icon: Icons.lock_outline_rounded,
                        ),
                        validator: (v) => v == _passCtrl.text
                            ? null
                            : 'Las contraseñas no coinciden',
                        onFieldSubmitted: (_) {
                          if (!_cargando) _registrar();
                        },
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: _cargando ? 'Registrando…' : 'Registrarme',
                        onPressed: _cargando ? null : _registrar,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
