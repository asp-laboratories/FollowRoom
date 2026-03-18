import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class PantallaEstadoSalones extends StatefulWidget {
  const PantallaEstadoSalones({super.key});

  @override
  State<PantallaEstadoSalones> createState() =>
      _PantallaEstadoSalonesState();
}

class _PantallaEstadoSalonesState extends State<PantallaEstadoSalones> {
  int _estadoSeleccionado = 0;

  final List<String> estados = [
    "Todos",
    "Disponible",
    "Reservado",
    "En limpieza",
    "No disponible",
  ];

  List<Map<String, dynamic>> salones = [
    {
      'id': 1,
      'nombre': 'Salón Imperial',
      'estado': 'En limpieza',
      'precio': 1500,
      'capacidad': 100,
    },
    {
      'id': 2,
      'nombre': 'Salón Ejecutivo',
      'estado': 'Reservado',
      'precio': 2500,
      'capacidad': 50,
    },
    {
      'id': 3,
      'nombre': 'Salón Universal',
      'estado': 'No disponible',
      'precio': 3000,
      'capacidad': 200,
    },
    {
      'id': 4,
      'nombre': 'Salón Premium',
      'estado': 'Disponible',
      'precio': 4000,
      'capacidad': 80,
    },
  ];

  List<Map<String, dynamic>> salonesMostrados = [];
  @override
  void initState() {
    super.initState();
    salonesMostrados = List.from(salones);
  }

  void filtrarPorEstado(int index) {
    setState(() {
      _estadoSeleccionado = index;

      if (estados[index] == "Todos") {
        salonesMostrados = List.from(salones);
      } else {
        salonesMostrados = salones.where((salon) {
          return salon['estado'] == estados[index];
        }).toList();
      }
    });
  }

  void cambiarEstado(int index, String nuevoEstado) {
    setState(() {
      salonesMostrados[index]['estado'] = nuevoEstado;

      final id = salonesMostrados[index]['id'];
      final originalIndex =
          salones.indexWhere((salon) => salon['id'] == id);
      if (originalIndex != -1) {
        salones[originalIndex]['estado'] = nuevoEstado;
      }
    });
  }

  void abrirModalEstado(int index) async {
    final String? nuevoEstado = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return _ModalEstados();
      },
    );
    if (nuevoEstado != null) {
      cambiarEstado(index, nuevoEstado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: estados.length,
              itemBuilder: (context, index) {
                final seleccionado = index == _estadoSeleccionado;
                return GestureDetector(
                  onTap: () => filtrarPorEstado(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColores.backgroundComponent,
                      border: Border.all(
                        color: seleccionado
                            ? AppColores.primary
                            : AppColores.primary.withValues(alpha: 0.3),
                        width: seleccionado ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: seleccionado
                              ? AppColores.primary.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      estados[index],
                      style: TextStyle(
                        color: seleccionado
                            ? AppColores.primary
                            : AppColores.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: salonesMostrados.length,
              itemBuilder: (context, index) {
                final salon = salonesMostrados[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration:
                      ContainerStyles.cardSeleccion(isSelected: false),
                  child: ListTile(
                    onTap: () => abrirModalEstado(index),
                    title: Text(
                      salon['nombre'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        _getEstadoIcon(salon['estado']),
                        SizedBox(width: 5),
                        Text(
                          salon['estado'],
                          style: TextStyle(
                            color: _getEstadoColor(salon['estado']),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEstadoIcon(String estado) {
    Color color = _getEstadoColor(estado);
    IconData icon;

    switch (estado) {
      case 'Disponible':
        icon = Icons.check_circle;
        break;
      case 'Reservado':
        icon = Icons.event_busy;
        break;
      case 'En limpieza':
        icon = Icons.cleaning_services;
        break;
      default:
        icon = Icons.cancel;
    }
    return Icon(icon, size: 16, color: color);
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Disponible':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'En limpieza':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
}

class _ModalEstados extends StatelessWidget {
  final List<String> estados = [
    "Disponible",
    "No disponible",
    "Reservado",
    "En limpieza",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: estados.map((estado) {
          return ListTile(
            leading: Icon(Icons.circle),
            title: Text(estado),
            onTap: () {
              Navigator.pop(context, estado);
            },
          );
        }).toList(),
      ),
    );
  }
}