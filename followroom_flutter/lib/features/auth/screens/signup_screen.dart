import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

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
                offset: Offset(0, 3),
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
                        //style: TextEstilos.encabezados,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 3),
                              blurRadius: 5,
                              color: AppColores.primary.withValues(alpha: 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24),

                      Text("Nombre de usuario", style: TextEstilos.simpleTexto),
                      SizedBox(height: 5),

                      TextField(
                        decoration: createAppDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: "Ingresa tu nombre de usuario",
                        ),
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Correo electronico",
                        style: TextEstilos.simpleTexto,
                      ),
                      SizedBox(height: 5),

                      TextField(
                        decoration: createAppDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Ingresa tu correo electronico",
                        ),
                      ),

                      SizedBox(height: 12),

                      Text("Contraseña", style: TextEstilos.simpleTexto),
                      SizedBox(height: 5),

                      TextField(
                        decoration: createAppDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: "Ingresa tu contraseña",
                        ),
                        obscureText: true,
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Confirmar contraseña",
                        style: TextEstilos.simpleTexto,
                      ),
                      SizedBox(height: 5),

                      TextField(
                        decoration: createAppDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: "Confirma tu contraseña",
                        ),
                        obscureText: true,
                      ),

                      SizedBox(height: 18),

                      ElevatedButton(
                        onPressed: () {},
                        style: BotonStyles.botonEstilos,
                        child: Text("Registrarse"),
                      ),
                    ],
                  ),
                ),
              ).blurry(
                blur: 5,
                borderRadius: BorderRadius.circular(16),
                color: AppColores.secundary.withValues(alpha: 0.9),
                shadowColor: AppColores.primary.withValues(alpha: 0.5),
              ),
        ),
      ),
    );
  }
}
