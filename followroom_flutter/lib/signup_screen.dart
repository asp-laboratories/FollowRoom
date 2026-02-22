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
      appBar: AppBar(title: Text("Regresar", style: TextEstilos.encabezados,), backgroundColor: AppColores.secundary,),
      backgroundColor: AppColores.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColores.backgroundComponent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Text("Registrate", style: TextEstilos.encabezados, textAlign: TextAlign.center,),

                  SizedBox(height: 24),

                  TextField(
                    decoration: createAppDecoration(
                      labelText: 'Nombre de usuario',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
          
                  SizedBox(height: 12),
          
                  TextField(
                    decoration: createAppDecoration(
                      labelText: 'Correo electronico',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
          
                  SizedBox(height: 12),
          
                  TextField(
                    decoration: createAppDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.password_sharp),
                    ),
                  ),
          
                  SizedBox(height: 12),
          
                  TextField(
                    decoration: createAppDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.password_outlined),
                    ),
                  ),
          
                  SizedBox(height: 12),
          
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Registrarse"),
                    style: BotonStyles.botonEstilos,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
