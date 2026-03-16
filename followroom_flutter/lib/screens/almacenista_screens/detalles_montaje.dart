import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class Detalles extends StatelessWidget {
  final String numeroReservacion;

  const Detalles({super.key, required this.numeroReservacion});

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
        title: Text(
          "Inventario Requerido",
          style: TextStyle(color: AppColores.foreground),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: AppColores.backgroundComponent,
        foregroundColor: AppColores.foreground,
      ),
      backgroundColor: AppColores.background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<dynamic>>(
          future: _jalarMobiliarios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColores.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error ${snapshot.error}",
                  style: TextStyle(color: AppColores.foreground),
                ),
              );
            }

            if (snapshot.hasData) {
              final mobiliarios = snapshot.data!;

              return mobiliarios.isEmpty
                  ? Center(
                      child: Text(
                        "No hay mobiliarios",
                        style: TextStyle(color: AppColores.foreground),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(15),
                          sliver: DecoratedSliver(
                            decoration: BoxDecoration(
                              color: AppColores.backgroundComponent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColores.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            sliver: SliverPadding(
                              padding: const EdgeInsets.all(15),
                              sliver: SliverList.separated(
                                itemCount: mobiliarios.length,
                                itemBuilder: (context, index) {
                                  final mobiliarioActual = mobiliarios[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColores
                                          .backgroundComponentSelected,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColores.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                mobiliarioActual['completado']
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    mobiliarioActual['completado']
                                                    ? Colors.green
                                                    : AppColores.foreground,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  mobiliarioActual['nomre']
                                                          ?.toString()
                                                          .toUpperCase() ??
                                                      '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        AppColores.foreground,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Divider(
                                            color: AppColores.primary
                                                .withValues(alpha: 0.3),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildInfoChip(
                                                  "Tipo",
                                                  mobiliarioActual['tipoMobiliario']
                                                          ?.toString() ??
                                                      '',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: _buildInfoChip(
                                                  "Descripción",
                                                  mobiliarioActual['descripcion']
                                                          ?.toString() ??
                                                      '',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Características",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColores.foreground,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...(mobiliarioActual['caracteristicas']
                                                      as List?)
                                                  ?.map((caracteristica) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 4,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.arrow_right,
                                                            color: AppColores
                                                                .primary,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              caracteristica
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: AppColores
                                                                    .foreground,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }) ??
                                              [],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 15),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(15),
                          sliver: DecoratedSliver(
                            decoration: BoxDecoration(
                              color: AppColores.backgroundComponent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColores.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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

            return Center(
              child: Text(
                "No encontré mobiliarios",
                style: TextStyle(color: AppColores.foreground),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColores.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColores.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColores.primary,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: AppColores.foreground),
          ),
        ],
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
          Text(
            "Mobiliarios a Montar:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColores.foreground,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.mobiliarios.map((mobiliarioActual) {
            return CheckboxListTile(
              title: Text(
                mobiliarioActual['nomre'] ?? '',
                style: TextStyle(color: AppColores.foreground),
              ),
              value: mobiliarioActual['completado'],
              activeColor: AppColores.primary,
              checkColor: Colors.white,
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
