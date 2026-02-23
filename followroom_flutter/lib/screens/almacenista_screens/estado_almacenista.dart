import 'package:flutter/material.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';

class AlmacenistaEstadoScreen extends StatefulWidget {
  const AlmacenistaEstadoScreen({super.key});

  @override
  State<AlmacenistaEstadoScreen> createState() => _AlmacenistaEstadoScreenState();
}

class _AlmacenistaEstadoScreenState extends State<AlmacenistaEstadoScreen> {
  int _actualIndice = 0;

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Textos(
          
          texts: ['Mobiliarios', 'Equipamientos',],
          
          seleccionActual: _actualIndice,
          
          alSeleccionar: (int nuevoIndice) {
            setState(() {
              _actualIndice = nuevoIndice;
            });
          }, 
        ),

        Text("Hola q hacen")

      ],

    );
  
  }

}