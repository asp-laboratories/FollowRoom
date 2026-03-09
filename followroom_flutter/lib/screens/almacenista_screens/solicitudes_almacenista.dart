import 'package:flutter/material.dart';

class AlmacenistaSolicitudesScreen extends StatelessWidget {
  AlmacenistaSolicitudesScreen({super.key});

  // Logica para jalar la info cada q se acceda
  List solicitudesMobiliarios = [
    {'nomre': "Silla chida", 'cantidad': 2, 'completado': false},
    {'nomre': "mesa no tan chida", 'cantidad': 1, 'completado': false},
    {'nomre': "Taburete", 'cantidad': 3, 'completado': false},
    {'nomre': "Silla", 'cantidad': 1, 'completado': false},
    {'nomre': "mesa no", 'cantidad': 1, 'completado': false},
    {'nomre': "caca", 'cantidad': 3, 'completado': false},
  ];
  List solicitudesEquipamientos = [
    {'nomre': "Microfono", 'cantidad': 1, 'completado': false},
    {'nomre': "Television", 'cantidad': 2, 'completado': false},
    {'nomre': "Microfono", 'cantidad': 1, 'completado': false},
    {'nomre': "Television", 'cantidad': 2, 'completado': false},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(15),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Text("Mobiliarios:", style: TextStyle(fontSize: 25)),
                  GenerarChecklists(objetos: solicitudesMobiliarios),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 15)),

        SliverPadding(
          padding: EdgeInsets.all(15),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Text("Equipamientos:", style: TextStyle(fontSize: 25)),
                  GenerarChecklists(objetos: solicitudesEquipamientos),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GenerarChecklists extends StatefulWidget {
  final List objetos;
  const GenerarChecklists({super.key, required this.objetos});

  @override
  State<GenerarChecklists> createState() => _GenerarChecklistsState();
}

class _GenerarChecklistsState extends State<GenerarChecklists> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Divider(),

          ...widget.objetos.map((mobiliarioActual) {
            return CheckboxListTile(
              title: Column(
                children: [
                  Text(
                    "${mobiliarioActual['nomre']}: ${mobiliarioActual['cantidad']}",
                  ),
                  Divider(),
                ],
              ),
              value: mobiliarioActual['completado'],
              onChanged: (bool? actualizacion) {
                setState(() {
                  mobiliarioActual['completado'] = actualizacion ?? false;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
