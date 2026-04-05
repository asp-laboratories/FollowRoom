import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/features/auth/screens/signup_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/bottom_navbar_screen_cliente.dart'
    show FollowRoom;
import 'package:followroom_flutter/screens/almacenista_screens/navbar_almacenista.dart'
    show Almacen;
import 'package:followroom_flutter/screens/coordinador_screens/navegacion_barra.dart'
    show NavegacionBarra;
import 'package:followroom_flutter/services/auth_service.dart';
import 'package:followroom_flutter/services/session_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _mostrarSnackBar(String mensaje, {bool esError = true}) {
    AnimatedSnackBar(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: esError ? Colors.red.shade100 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              esError ? Icons.error_outline : Icons.warning_amber,
              color: esError ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(
                  color: esError ? Colors.red.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }

  void _redirigirPorRol(Map<String, dynamic> userData) {
    Widget pantalla;
    String? rol = userData['rol'];
    String tipo = userData['tipo'] ?? 'cliente';

    if (tipo == 'trabajador') {
      switch (rol) {
        case 'ADMIN':
          pantalla = const NavegacionBarra();
          break;
        case 'RECEP':
          pantalla = const NavegacionBarra();
          break;
        case 'ALMAC':
          pantalla = const Almacen();
          break;
        default:
          pantalla = const NavegacionBarra();
      }
    } else {
      pantalla = const FollowRoom();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
  }

  Future<void> _iniciarSesion() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _mostrarSnackBar('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userData = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      print('Usuario autenticado: $userData');
      await SessionData.setFromLogin(userData);
      if (mounted) {
        _redirigirPorRol(userData);
      }
    } catch (e) {
      _mostrarSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _olvideContrasena() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _mostrarSnackBar('Ingresa tu correo primero');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _mostrarSnackBar('Correo de recuperación enviado a $email');
    } catch (e) {
      _mostrarSnackBar('Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColores.secundary,
              AppColores.secundary,
              AppColores.secundary,
              AppColores.secundary.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Bienvenido a FollowRoom",
                            style: TextEstilos.encabezadosBlancos,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Image.asset(
                            'assets/images/followroom_logo.png',
                            height: 120,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Correo electronico",
                            style: TextEstilos.simpleTexto,
                          ),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppColores.primary,
                              ),
                              hintText: 'Ingresa tu correo',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text("Contraseña", style: TextEstilos.simpleTexto),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.password,
                                color: AppColores.primary,
                              ),
                              hintText: 'Ingresa tu contraseña',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColores.primary,
                              shadowColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Iniciar sesión"),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Registro(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColores.primary,
                              shadowColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Regístrate"),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _olvideContrasena,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColores.primary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).blurry(
                    blur: 5,
                    elevation: 0,
                    color: const Color.fromARGB(54, 255, 255, 255),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
