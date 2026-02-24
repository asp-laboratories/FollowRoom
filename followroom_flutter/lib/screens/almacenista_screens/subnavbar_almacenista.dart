import 'package:flutter/material.dart';

class Textos extends StatelessWidget {
  final List<String> texts;
  final int seleccionActual;
  final Function(int) alSeleccionar;

  const Textos({
    super.key, 
    required this.texts,
    required this.seleccionActual,
    required this.alSeleccionar,
    });

  @override
  Widget build(BuildContext context) {
    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 16.0,),

      child: Wrap(

        spacing: 10.0,

        children: texts.asMap().entries.map((teexto) {

          int indice = teexto.key;
          String texto = teexto.value;

          bool estaSeleccionado = seleccionActual == indice;

          return ChoiceChip(
            label: Text(texto),

            labelStyle: TextStyle(
              color: estaSeleccionado ? Colors.white : Colors.black,
              fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
              fontSize: estaSeleccionado ?16 :12,

            ),

            backgroundColor: Colors.grey,
            selectedColor: Color.fromARGB(255, 155, 88, 43),
            showCheckmark: false,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            selected: estaSeleccionado,
          
            onSelected: (bool seleccionado) {
              alSeleccionar(indice);
            },
        
          );

        }).toList(),

      ),
    );
  }

}
