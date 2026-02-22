import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/almacenista_screens/navbar_almacenista.dart';
import 'package:followroom_flutter/screens/cliente_screens/navbar_screen_cliente.dart';
import 'package:followroom_flutter/signup_screen.dart';

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
      backgroundColor: AppColores.primary,
      body: Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColores.backgroundComponent,
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
                      style: TextEstilos.encabezados,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    Image.asset(
                      'assets/images/followroom_logo.png',
                      height: 120,
                    ),

                    SizedBox(height: 24),

                    TextField(
                      controller: email,
                      decoration: createAppDecoration(
                        labelText: 'Correo electronico',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    SizedBox(height: 24),

                    TextField(
                      controller: password,
                      decoration: createAppDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.password),
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(mensajeError),

                    ElevatedButton(
                      onPressed: () {
                        if (email.text == 'example' && password.text == '123') {
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
                            MaterialPageRoute(builder: (context) => Almacen()),
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
                          MaterialPageRoute(builder: (context) => Registro()),
                        );
                      },
                      style: BotonStyles.botonEstilos,
                      child: Text("Registrate"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
