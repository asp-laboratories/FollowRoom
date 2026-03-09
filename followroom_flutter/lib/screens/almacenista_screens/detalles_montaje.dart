import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:followroom_flutter/core/colores.dart';

class Detalles extends StatelessWidget {
  final String numeroReservacion;

  const Detalles({super.key, required this.numeroReservacion});

  // Logica pa jalar info de los mobiliarios y ese pedo q nos retorna una lista de mapas o parecidos
  Future<List<dynamic>> _jalarMobiliarios() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      {
        'nomre': "mesa",
        'caracteristicas': ["rojo", 'madera'],
        'descripcion': "Mesa para banquetes",
        'tipoMobiliario': "Mesa",
        'completado': false,
      },
      {
        'nomre': "sillka",
        'caracteristicas': ["azul", 'madera'],
        'descripcion': "silla para banquetes",
        'tipoMobiliario': "silla",
        'completado': true,
      },
      {
        'nomre': "taburete",
        'caracteristicas': ["cafe", 'madera'],
        'descripcion': "tabuerete para banquetes",
        'tipoMobiliario': "taburete",
        'completado': false,
      },
      {
        'nomre': "mesa",
        'caracteristicas': ["rojo", 'madera'],
        'descripcion': "Mesa para banquetes",
        'tipoMobiliario': "Mesa",
        'completado': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventario Requerido"),
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<dynamic>>(
          future: _jalarMobiliarios(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error ${snapshot.error}"));
            }

            if (snapshot.hasData) {
              final mobiliarios = snapshot.data!;

              return mobiliarios.isEmpty
                  ? Text("No hay mobiliarios")
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(15),

                          sliver: DecoratedSliver(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            sliver: SliverPadding(
                              padding: const EdgeInsets.all(15),

                              sliver: SliverList.separated(
                                itemCount: mobiliarios.length,

                                itemBuilder: (context, index) {
                                  final mobiliarioActual = mobiliarios[index];

                                  // Modificaciones aca para determinar como es que se va a ver l atarjetita donde se ponen los detalles del montajde e la reservacion
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              mobiliarioActual['nomre'],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                          "Tipo: ${mobiliarioActual['tipoMobiliario']}",
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                          "Descripcion: ${mobiliarioActual['descripcion']}",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Divider(),

                                                Text("Caracteristicass"),

                                                ...(mobiliarioActual['caracteristicas']
                                                        as List)
                                                    .map((caracteristica) {
                                                      return Row(
                                                        children: [
                                                          Icon(
                                                            Icons.arrow_right,
                                                            color: AppColores
                                                                .foreground,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              caracteristica
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },

                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 15);
                                },
                              ),
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.all(15),

                          sliver: DecoratedSliver(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            sliver: SliverPadding(
                              padding: const EdgeInsets.all(15),

                              sliver: SliverToBoxAdapter(
                                child: GeneradorChecklists(
                                  mobiliarios: mobiliarios,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            }

            return const Text("No encontre mobiliarios");
          },
        ),
      ),
    );
  }
}

class GeneradorChecklists extends StatefulWidget {
  final List<dynamic> mobiliarios;

  const GeneradorChecklists({super.key, required this.mobiliarios});

  @override
  State<GeneradorChecklists> createState() => _GeneradorChecklistsState();
}

class _GeneradorChecklistsState extends State<GeneradorChecklists> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Mobiliarios a Montar:"),

          ...widget.mobiliarios.map((mobiliarioActual) {
            return CheckboxListTile(
              title: Text(mobiliarioActual['nomre']),
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
