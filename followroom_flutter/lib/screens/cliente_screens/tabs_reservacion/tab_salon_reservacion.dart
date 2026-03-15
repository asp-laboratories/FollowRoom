import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_montaje_reservacion.dart';

class TabSalon extends StatefulWidget {
  final Map<int, String> montajesPorSalon;
  final Map<String, dynamic>? salonSeleccionado;
  final Function(int, String) onMontajeSelected;
  final Function(Map<String, dynamic>?) onSalonSelected;

  const TabSalon({
    super.key,
    required this.montajesPorSalon,
    required this.salonSeleccionado,
    required this.onMontajeSelected,
    required this.onSalonSelected,
  });

  @override
  State<TabSalon> createState() => _TabSalonState();
}

class _TabSalonState extends State<TabSalon> {
  final List<Map<String, dynamic>> salonesDB = [
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

  String? getMontajeDelSalon(int salonId) {
    return widget.montajesPorSalon[salonId];
  }

  @override
  Widget build(BuildContext context) {
    final bool haySalonSeleccionado = widget.salonSeleccionado != null;

    return Container(
      color: AppColores.background2,
      child: Column(
        children: [
          if (haySalonSeleccionado)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColores.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColores.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Salón seleccionado:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          widget.onSalonSelected(null);
                        },
                      ),
                    ],
                  ),
                  Text(
                    widget.salonSeleccionado!['nombre'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Precio: \$${widget.salonSeleccionado!['precio']}"),
                  Text(
                    "Capacidad: ${widget.salonSeleccionado!['capacidad']} personas",
                  ),
                  Divider(),
                  Text(
                    "Montaje: ${getMontajeDelSalon(widget.salonSeleccionado!['id']) ?? 'No seleccionado'}",
                    style: TextStyle(
                      color:
                          getMontajeDelSalon(widget.salonSeleccionado!['id']) !=
                              null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "Selecciona un salón de la lista",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Selecciona un salón:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: salonesDB.length,
              itemBuilder: (context, index) {
                final salon = salonesDB[index];
                final int salonId = salon['id'];
                final bool isSelected =
                    widget.salonSeleccionado?['id'] == salonId;
                final String? montaje = getMontajeDelSalon(salonId);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: isSelected
                      ? AppColores.primary.withValues(alpha: 0.1)
                      : null,
                  child: InkWell(
                    onTap: () {
                      widget.onSalonSelected(salon);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  salon['nombre'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColores.primary,
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              _getEstadoIcon(salon['estado']),
                              SizedBox(width: 4),
                              Text(
                                salon['estado'],
                                style: TextStyle(
                                  color: _getEstadoColor(salon['estado']),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.people, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                "${salon['capacidad']} personas",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.grey,
                              ),
                              Text(
                                "\$${salon['precio']}",
                                style: TextStyle(
                                  color: AppColores.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final resultado = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NavigatorMontajeReservacion(),
                                ),
                              );
                              if (resultado != null) {
                                widget.onMontajeSelected(salonId, resultado);
                              }
                            },
                            icon: Icon(Icons.grid_view),
                            label: Text(montaje ?? "Seleccionar montaje"),
                          ),
                        ],
                      ),
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
