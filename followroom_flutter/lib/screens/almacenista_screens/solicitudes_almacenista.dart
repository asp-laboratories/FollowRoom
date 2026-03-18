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
        {'nomre': "Silla metalica", 'cantidad': 2, 'completado': false},
        {'nomre': "Mesa circular", 'cantidad': 1, 'completado': false},
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
        {'nomre': "Mesa comun", 'cantidad': 1, 'completado': false},
        {'nomre': "Sila de madera", 'cantidad': 3, 'completado': false},
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
                  behavior: HitTestBehavior.opaque,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(index['nombre'], style: TextStyle(fontSize: 25)),
                        Row(children: [Spacer(), Text("Detalles >")]),
                      ],
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
        mainAxisSize: MainAxisSize.min,
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
      appBar: AppBar(
        title: Text("Solicitudes"),
        backgroundColor: AppColores.backgroundComponent,
        foregroundColor: AppColores.foreground,
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(15),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColores.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColores.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(evento['nombre'], style: TextStyle(fontSize: 30)),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: AppColores.secundary,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mobiliarios", style: TextStyle(fontSize: 30)),
                        GenerarChecklists(
                          objetos: evento['solicitudesMobiles'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: AppColores.secundary,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Equipamientos", style: TextStyle(fontSize: 30)),
                        GenerarChecklists(
                          objetos: evento['solicitudesEquipos'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 30)),
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: SliverToBoxAdapter(
                child: ElevatedButton(
                  // Aca funcion pa registrar q una u otra seccion se ha completado
                  onPressed: () {},
                  child: Text("Completar Registro"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
