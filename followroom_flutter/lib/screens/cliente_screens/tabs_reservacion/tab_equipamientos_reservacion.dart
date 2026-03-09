import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabEquipamientosReservacion extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onEquipamientosChanged;
  final List<Map<String, dynamic>> equipamientosSeleccionados;

  const TabEquipamientosReservacion({
    super.key,
    required this.onEquipamientosChanged,
    required this.equipamientosSeleccionados,
  });

  @override
  State<TabEquipamientosReservacion> createState() =>
      _TabEquipamientosReservacionState();
}

class _TabEquipamientosReservacionState
    extends State<TabEquipamientosReservacion> {
  final List<String> tiposEquipamiento = ['sillas', 'mesas'];
  String? tiposEquipamientoSeleccionado;

  final List<Map<String, dynamic>> equipamientosDB = [
    {
      'id': 1,
      'nombre': 'Silla de madera',
      'tipo': 'sillas',
      'descripcion': 'Sillas estándar',
      'precio': 50,
      'stock': 100,
    },
    {
      'id': 2,
      'nombre': 'Silla tijera',
      'tipo': 'sillas',
      'descripcion': 'Sillas elegantes',
      'precio': 80,
      'stock': 50,
    },
    {
      'id': 3,
      'nombre': 'Mesa redonda',
      'tipo': 'mesas',
      'descripcion': 'Mesas redondas',
      'precio': 100,
      'stock': 30,
    },
    {
      'id': 4,
      'nombre': 'Mesa rectangular',
      'tipo': 'mesas',
      'descripcion': 'Mesas para banquetes',
      'precio': 150,
      'stock': 25,
    },
  ];

  List<Map<String, dynamic>> get equipamientosFiltrados {
    if (tiposEquipamientoSeleccionado == null ||
        tiposEquipamientoSeleccionado == 'todos') {
      return equipamientosDB;
    }
    return equipamientosDB
        .where((equipa) => equipa['tipo'] == tiposEquipamientoSeleccionado)
        .toList();
  }

  void actualizarCantidad(Map<String, dynamic> equipamiento, int cantidad) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.equipamientosSeleccionados,
    );

    if (cantidad == 0) {
      nuevaLista.removeWhere((e) => e['id'] == equipamiento['id']);
    } else {
      final index = nuevaLista.indexWhere((e) => e['id'] == equipamiento['id']);
      if (index >= 0) {
        nuevaLista[index] = {...equipamiento, 'cantidad': cantidad};
      } else {
        nuevaLista.add({...equipamiento, 'cantidad': cantidad});
      }
    }

    widget.onEquipamientosChanged(nuevaLista);
  }

  int getCantidad(Map<String, dynamic> equipamiento) {
    final found = widget.equipamientosSeleccionados.where(
      (e) => e['id'] == equipamiento['id'],
    );
    if (found.isEmpty) return 0;
    return found.first['cantidad'] as int;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.equipamientosSeleccionados.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Equipamientos seleccionados:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.equipamientosSeleccionados.map((e) {
                return Chip(
                  label: Text("${e['nombre']} (x${e['cantidad']})"),
                  deleteIcon: Icon(Icons.close, size: 16),
                  onDeleted: () => actualizarCantidad(e, 0),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total equipamiento:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${widget.equipamientosSeleccionados.fold<int>(0, (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)))}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text("Filtrar:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              DropdownButton<String>(
                value: tiposEquipamientoSeleccionado,
                hint: Text("Todos"),
                items: [
                  DropdownMenuItem(value: 'todos', child: Text("Todos")),
                  DropdownMenuItem(value: 'sillas', child: Text("Sillas")),
                  DropdownMenuItem(value: 'mesas', child: Text("Mesas")),
                ],
                onChanged: (value) {
                  setState(() {
                    tiposEquipamientoSeleccionado = value;
                  });
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Catálogo de equipamiento:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: equipamientosFiltrados.length,
            itemBuilder: (context, index) {
              final equipamiento = equipamientosFiltrados[index];
              final cantidad = getCantidad(equipamiento);

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipamiento['nombre'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              equipamiento['descripcion'],
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "\$${equipamiento['precio']} c/u - Stock: ${equipamiento['stock']}",
                              style: TextStyle(
                                color: AppColores.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: cantidad > 0
                                ? () => actualizarCantidad(
                                    equipamiento,
                                    cantidad - 1,
                                  )
                                : null,
                            icon: Icon(Icons.remove_circle_outline),
                            color: cantidad > 0
                                ? AppColores.primary
                                : Colors.grey,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              "$cantidad",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: cantidad < (equipamiento['stock'] as int)
                                ? () => actualizarCantidad(
                                    equipamiento,
                                    cantidad + 1,
                                  )
                                : null,
                            icon: Icon(Icons.add_circle_outline),
                            color: cantidad < (equipamiento['stock'] as int)
                                ? AppColores.primary
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
