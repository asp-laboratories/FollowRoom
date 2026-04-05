import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class AlmacenistaSolicitudesScreen extends StatelessWidget {
  AlmacenistaSolicitudesScreen({super.key});

  List reservaciones = [
    {
      'nombre': "Reservacion 1",
      'descripcion': "Evento de prueba",
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
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: reservaciones.length,
          itemBuilder: (context, index) {
            final item = reservaciones[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: ContainerStyles.sombreado,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Solicitudes(evento: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['nombre'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['descripcion'],
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColores.foreground.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
    return Column(
      children: widget.objetos.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: CheckboxListTile(
            value: item['completado'],
            activeColor: AppColores.primary,
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['nomre']),
                Text(
                  "x${item['cantidad']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
            onChanged: (bool? value) {
              setState(() {
                item['completado'] = value ?? false;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class Solicitudes extends StatelessWidget {
  final Map evento;

  const Solicitudes({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      appBar: AppBar(
        title: const Text("Solicitudes"),
        backgroundColor: AppColores.background2,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: AppColores.background2),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  evento['nombre'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _seccion(
                titulo: "Mobiliario",
                icono: Icons.chair,
                child: GenerarChecklists(objetos: evento['solicitudesMobiles']),
              ),
              const SizedBox(height: 16),
              _seccion(
                titulo: "Equipamiento",
                icono: Icons.devices,
                child: GenerarChecklists(objetos: evento['solicitudesEquipos']),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {},
                  child: const Text("Completar Registro"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion({
    required String titulo,
    required IconData icono,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ContainerStyles.sombreado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: AppColores.primary),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
