import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _baseUrl = 'http://${IpConfig.ip}/api';

  String _mensajeError = '';
  bool _isLoading = false;

  Future<void> _registrarUsuario() async {
    setState(() {
      _mensajeError = '';
      _isLoading = true;
    });

    if (nombreController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        _mensajeError = 'Por favor completa todos los campos';
        _isLoading = false;
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _mensajeError = 'Las contraseñas no coinciden';
        _isLoading = false;
      });
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() {
        _mensajeError = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
      });
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final idToken = await userCredential.user!.getIdToken();

      final dio = Dio();
      dio.options.baseUrl = _baseUrl;

      await dio.post(
        '/signup/',
        data: {'token': idToken, 'nombre': nombreController.text.trim()},
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _mensajeError = _obtenerMensajeError(e.code));
    } catch (e) {
      setState(() => _mensajeError = 'Error al registrar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _obtenerMensajeError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error al registrar usuario';
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "¿Tienes cuenta?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(0, 3),
                blurRadius: 5,
                color: AppColores.primary.withValues(alpha: 1),
              ),
            ],
          ),
        ),
        backgroundColor: AppColores.secundary,
      ),
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
                            "Registrate",
                            style: TextEstilos.encabezadosBlancos,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Nombre de usuario",
                            style: TextEstilos.simpleTexto,
                          ),
                          TextField(
                            controller: nombreController,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppColores.primary,
                              ),
                              hintText: "Ingresa tu nombre de usuario",
                            ),
                          ),
                          const SizedBox(height: 12),
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
                              hintText: "Ingresa tu correo electronico",
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text("Contraseña", style: TextEstilos.simpleTexto),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.password,
                                color: AppColores.primary,
                              ),
                              hintText: "Ingresa tu contraseña",
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Confirmar contraseña",
                            style: TextEstilos.simpleTexto,
                          ),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.password_outlined,
                                color: AppColores.primary,
                              ),
                              hintText: "Confirma tu contraseña",
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_mensajeError.isNotEmpty)
                            Text(
                              _mensajeError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _registrarUsuario,
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
                                : const Text("Registrarse"),
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
