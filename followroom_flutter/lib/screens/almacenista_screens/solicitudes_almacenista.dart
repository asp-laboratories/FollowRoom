import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class AlmacenistaSolicitudesScreen extends StatelessWidget {
  AlmacenistaSolicitudesScreen({super.key});

  // Logica para jalar la info cada q se acceda

  List reservaciones = [
    {
      'nombre': "Reservacion 1",
      'solicitudesEquipos': [
        {'nomre': "Microfono", 'cantidad': 1, 'completado': false},
        {'nomre': "Television", 'cantidad': 2, 'completado': false},
      ],
      'solicitudesMobiles': [
        {'nomre': "Silla chida", 'cantidad': 2, 'completado': false},
        {'nomre': "mesa no tan chida", 'cantidad': 1, 'completado': false},
        {'nomre': "Taburete", 'cantidad': 3, 'completado': false},
      ],
    },
    {
      'nombre': "Reservacion 2",
      'solicitudesEquipos': [
        {'nomre': "Microfono", 'cantidad': 1, 'completado': false},
        {'nomre': "Television", 'cantidad': 2, 'completado': false},
      ],
      'solicitudesMobiles': [
        {'nomre': "Silla", 'cantidad': 1, 'completado': false},
        {'nomre': "mesa no", 'cantidad': 1, 'completado': false},
        {'nomre': "caca", 'cantidad': 3, 'completado': false},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ...(reservaciones).map((index) {
          return SliverPadding(
            padding: EdgeInsets.all(15),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: AppColores.backgroundComponent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColores.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Solicitudes(evento: index),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      index['nombre'],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        SliverToBoxAdapter(child: SizedBox(height: 15)),
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

class Solicitudes extends StatelessWidget {
  final Map evento;

  const Solicitudes({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solicitudes")),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(15),
            sliver: SliverToBoxAdapter(
              child: Text(evento['nombre'], style: TextStyle(fontSize: 30)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(child: SizedBox(height: 15)),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Text("Mobiliarios", style: TextStyle(fontSize: 30)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  GenerarChecklists(objetos: evento['solicitudesMobiles']),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 15)),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Text("Equipamientos", style: TextStyle(fontSize: 30)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  GenerarChecklists(objetos: evento['solicitudesEquipos']),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 30)),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: ElevatedButton(
                onPressed: () {},
                child: Text("q hongo presionae"),
              ),
            ),
          ),
        ],
      ),
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Column(
      //     children: [
      //       Text(evento['nombre'], style: TextStyle(fontSize: 25)),
      //       Text("Mobiliarios:", style: TextStyle(fontSize: 25)),
      //       GenerarChecklists(objetos: evento['solicitudesMobiles']),
      //       SizedBox(height: 15),

      //       Text("Equipamientos:", style: TextStyle(fontSize: 25)),
      //       GenerarChecklists(objetos: evento['solicitudesEquipos']),

      //       SizedBox(height: 40,),

      //       ElevatedButton(
      //         // Logica para hcer el guardado logico en la base ded atos
      //         onPressed: () {},
      //         child: Text("Q hongo"),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
