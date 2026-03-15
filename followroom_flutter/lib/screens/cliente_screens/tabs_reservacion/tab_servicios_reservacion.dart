import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TabServiciosReservacion extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onServiciosChanged;
  final List<Map<String, dynamic>> serviciosSeleccionados;

  const TabServiciosReservacion({
    super.key,
    required this.onServiciosChanged,
    required this.serviciosSeleccionados,
  });

  @override
  State<TabServiciosReservacion> createState() =>
      _TabServiciosReservacionState();
}

class _TabServiciosReservacionState extends State<TabServiciosReservacion> {
  List<String> tiposServicios = [];
  String? tiposServicioSeleccionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTiposServicio();
  }

  Future<void> _loadTiposServicio() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.8:8000/api/tipo-servicio/'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          tiposServicios = data.map((e) => e['nombre'].toString()).toList();
          print("Datos");
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        tiposServicios = ['ejecutivos', 'empresariales'];
        isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> serviciosDB = [
    {
      'id': 1,
      'nombre': 'Internet de alta velocidad',
      'descripcion': '500 MB',
      'precio': 1500,
      'tipo': 'empresariales',
    },
    {
      'id': 2,
      'nombre': 'Servicio de seguridad',
      'descripcion': '2 guardias',
      'precio': 2500,
      'tipo': 'empresariales',
    },
    {
      'id': 3,
      'nombre': 'Café y snacks',
      'descripcion': 'Bebidas ilimitadas',
      'precio': 800,
      'tipo': 'ejecutivos',
    },
    {
      'id': 4,
      'nombre': 'Servicio de limpieza',
      'descripcion': 'Limpieza post-evento',
      'precio': 1000,
      'tipo': 'ejecutivos',
    },
  ];

  List<Map<String, dynamic>> get serviciosFiltrados {
    if (tiposServicioSeleccionado == null ||
        tiposServicioSeleccionado == 'todos') {
      return serviciosDB;
    }
    return serviciosDB
        .where((s) => s['tipo'] == tiposServicioSeleccionado)
        .toList();
  }

  void toggleServicio(Map<String, dynamic> servicio) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.serviciosSeleccionados,
    );

    if (nuevaLista.any((s) => s['id'] == servicio['id'])) {
      nuevaLista.removeWhere((s) => s['id'] == servicio['id']);
    } else {
      nuevaLista.add(servicio);
    }

    widget.onServiciosChanged(nuevaLista);
  }

  bool isSelected(Map<String, dynamic> servicio) {
    return widget.serviciosSeleccionados.any((s) => s['id'] == servicio['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColores.background2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Filtrar por tipo:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                DropdownMenu<String>(
                  initialSelection: tiposServicioSeleccionado,
                  dropdownMenuEntries: isLoading
                      ? [
                          DropdownMenuEntry(
                            value: 'cargando',
                            label: 'Cargando...',
                          ),
                        ]
                      : [
                          DropdownMenuEntry(value: 'todos', label: 'Todos'),
                          ...tiposServicios.map(
                            (value) =>
                                DropdownMenuEntry(value: value, label: value),
                          ),
                        ],
                  onSelected: isLoading
                      ? null
                      : (String? nuevoValor) {
                          setState(() {
                            tiposServicioSeleccionado = nuevoValor;
                          });
                        },
                  label: const Text('Tipo de servicio'),
                ),
              ],
            ),
          ),

          if (widget.serviciosSeleccionados.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Servicios seleccionados (${widget.serviciosSeleccionados.length}):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: widget.serviciosSeleccionados.map((s) {
                  return Chip(
                    label: Text(s['nombre']),
                    deleteIcon: Icon(Icons.close, size: 16),
                    onDeleted: () => toggleServicio(s),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],

          Text(
            "Disponibles:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: serviciosFiltrados.length,
              itemBuilder: (context, index) {
                final servicio = serviciosFiltrados[index];
                final seleccionado = isSelected(servicio);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: seleccionado
                      ? AppColores.primary.withValues(alpha: 0.1)
                      : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: seleccionado,
                      onChanged: (_) => toggleServicio(servicio),
                    ),
                    title: Text(
                      servicio['nombre'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${servicio['descripcion']} - \$${servicio['precio']}",
                    ),
                    trailing: Text(
                      servicio['tipo'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
}
