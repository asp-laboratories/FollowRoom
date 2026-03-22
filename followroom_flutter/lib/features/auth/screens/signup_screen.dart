import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';

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
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
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
      resizeToAvoidBottomInset: false,
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
      backgroundColor: AppColores.secundary,
      body: Center(
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Registrate",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                                color: AppColores.primary.withValues(alpha: 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Text("Nombre de usuario"),
                        TextField(
                          controller: nombreController,
                          decoration: createAppDecoration(
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Ingresa tu nombre de usuario",
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Correo electronico"),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: createAppDecoration(
                            prefixIcon: const Icon(Icons.email),
                            hintText: "Ingresa tu correo electronico",
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Contraseña"),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: createAppDecoration(
                            prefixIcon: const Icon(Icons.password_sharp),
                            hintText: "Ingresa tu contraseña",
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Confirmar contraseña"),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: createAppDecoration(
                            prefixIcon: const Icon(Icons.password_outlined),
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
                          style: BotonStyles.botonEstilos,
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
                  borderRadius: BorderRadius.circular(16),
                  color: AppColores.backgroundComponent.withValues(alpha: 0.9),
                  shadowColor: AppColores.primary.withValues(alpha: 0.5),
                ),
          ),
        ),
      ),
    );
  }
}
