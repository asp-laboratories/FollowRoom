import 'package:flutter/material.dart';
import 'navegacion_barra.dart';

class PanelCoordinador extends StatelessWidget {
  const PanelCoordinador({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Coordinador"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Bienvenido, NombreRandom",
          style: TextStyle(fontSize: 16),
        ),
      ),

      bottomNavigationBar: const NavegacionBarra(),
    );
  }
}