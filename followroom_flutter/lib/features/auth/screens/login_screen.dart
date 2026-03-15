import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/almacenista_screens/navbar_almacenista.dart';
import 'package:followroom_flutter/screens/cliente_screens/navbar_screen_cliente.dart';
import 'package:followroom_flutter/screens/coordinador_screens/navegacion_barra.dart';
import 'package:followroom_flutter/screens/coordinador_screens/panelprincipal.dart';
import 'package:followroom_flutter/features/auth/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  String mensajeError = '';

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

                          SizedBox(height: 24),

                          Image.asset(
                            'assets/images/followroom_logo.png',
                            height: 120,
                          ),

                          SizedBox(height: 24),

                          Text(
                            "Correo electronico",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          TextField(
                            controller: email,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppColores.primary,
                              ),
                              hintText: 'Ingresa tu correo',
                            ),
                          ),

                          SizedBox(height: 24),

                          Text(
                            "Contraseña",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          TextField(
                            controller: password,
                            decoration: createAppDecoration(
                              prefixIcon: Icon(
                                Icons.password,
                                color: AppColores.primary,
                              ),
                              hintText: 'Ingresa tu contraseña',
                            ),
                          ),

                          SizedBox(height: 24),

                          Text(mensajeError),

                          ElevatedButton(
                            onPressed: () {
                              if (email.text == 'example' &&
                                  password.text == '123') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowRoom(),
                                  ),
                                );
                              } else if ((email.text == 'exa' &&
                                  password.text == '321')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Almacen(),
                                  ),
                                );
                              } else if (email.text == 'coordinador' &&
                                  password.text == '456') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavegacionBarra(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  mensajeError = "Campos incorrectos";
                                });
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColores.primary,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Iniciar sesión"),
                          ),

                          SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Registro(),
                                ),
                              );
                            },
                            style: BotonStyles.botonEstilos,
                            child: Text("Registrate"),
                          ),
                        ],
                      ),
                    ),
                  ).blurry(
                    blur: 5,
                    elevation: 0,
                    color: const Color.fromARGB(54, 255, 255, 255).withValues(),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
