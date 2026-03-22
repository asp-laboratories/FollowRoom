import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/features/auth/screens/signup_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/navbar_screen_cliente.dart'
    show FollowRoom;
import 'package:followroom_flutter/screens/almacenista_screens/navbar_almacenista.dart'
    show Almacen;
import 'package:followroom_flutter/screens/coordinador_screens/navegacion_barra.dart'
    show NavegacionBarra;
import 'package:followroom_flutter/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String mensajeError = '';
  bool _isLoading = false;

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
      setState(() => mensajeError = 'Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userData = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      print('Usuario autenticado: $userData');
      if (mounted) {
        _redirigirPorRol(userData);
      }
    } catch (e) {
      setState(() => mensajeError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
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
      resizeToAvoidBottomInset: false,
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                          const Text(
                            "Correo electronico",
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
                          const Text(
                            "Contraseña",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
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
                          const SizedBox(height: 16),
                          if (mensajeError.isNotEmpty)
                            Text(
                              mensajeError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColores.primary,
                              shadowColor: Colors.black,
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
                            style: BotonStyles.botonEstilos,
                            child: const Text("Registrate"),
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
