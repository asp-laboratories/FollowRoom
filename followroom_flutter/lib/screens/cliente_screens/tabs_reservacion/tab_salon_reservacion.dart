import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_montaje_reservacion.dart';
import 'package:followroom_flutter/services/salon_service.dart';

class TabSalon extends StatefulWidget {
  final int cantidadAsistentes;
  final Map<String, dynamic> montajesPorSalon;
  final Map<String, dynamic>? salonSeleccionado;
  final Function(Map<String, dynamic>) onMontajeSelected;
  final Function(Map<String, dynamic>?) onSalonSelected;

  const TabSalon({
    super.key,
    required this.montajesPorSalon,
    required this.salonSeleccionado,
    required this.onMontajeSelected,
    required this.onSalonSelected,
    this.cantidadAsistentes = 0,
  });

  @override
  State<TabSalon> createState() => _TabSalonState();
}

class _TabSalonState extends State<TabSalon> {
  final SalonService _salonService = SalonService();

  late Future<List<Map<String, dynamic>>> _salones;

  Map<String, dynamic>? getMontajeDelSalon(int salonId) {
    if (widget.salonSeleccionado != null && widget.salonSeleccionado!['id'] == salonId) {
      if (widget.montajesPorSalon.isNotEmpty) {
        return widget.montajesPorSalon;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _salones = _salonService.getSalonesConEstado();
  }

  @override
  Widget build(BuildContext context) {
    final bool haySalonSeleccionado = widget.salonSeleccionado != null;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (haySalonSeleccionado)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: ContainerStyles.sombreado,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColores.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "SALÓN SELECCIONADO",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              widget.onSalonSelected(null);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.salonSeleccionado!['nombre'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColores.foreground,
                        ),
                      ),
                      Text(
                        "Precio: \$${widget.salonSeleccionado!['costo']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Capacidad: ${widget.salonSeleccionado!['maxCapacidad']} personas",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Divider(),
                      Text(
                        "Montaje: ${getMontajeDelSalon(widget.salonSeleccionado!['id'])?['nombre'] ?? 'No seleccionado'}",
                        style: TextStyle(
                          color:
                              getMontajeDelSalon(
                                    widget.salonSeleccionado!['id'],
                                  ) !=
                                  null
                              ? AppColores.foreground
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Catálogo de salones:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _salones,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Error al cargar los salones: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  );
                }

                final salones = snapshot.data ?? [];
                final saloneschidos = salones.where((salon) {
                  final int capacidad = salon['maxCapacidad'] as int;
                  return capacidad >= widget.cantidadAsistentes;
                }).toList();

                return saloneschidos.isEmpty
                    ? Center(
                        child: Text(
                          "No hay salones disponibles para la cantidad de asistentes",
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        itemCount: saloneschidos.length,
                        itemBuilder: (context, index) {
                          final salon = saloneschidos[index];
                          final int idSalon = salon['id'] as int;
                          final bool isSelected =
                              widget.salonSeleccionado?['id'] == idSalon;
                          final String estado = salon['estado_salon'] is Map
                              ? (salon['estado_salon']['nombre'] ??
                                    'Desconocido')
                              : (salon['estado_salon']?.toString() ??
                                    'Desconocido');

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: ContainerStyles.sombreado,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  widget.onSalonSelected(salon);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              salon['nombre'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColores.foreground,
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
                                          _getEstadoIcon(estado),
                                          SizedBox(width: 4),
                                          Text(
                                            estado,
                                            style: TextStyle(
                                              color: _getEstadoColor(estado),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "${salon['maxCapacidad']} personas",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "\$${salon['costo']}",
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
                                          final resultado =
                                              await Navigator.push<
                                                Map<String, dynamic>
                                              >(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NavigatorMontajeReservacion(
                                                        salon_id: salon['id'],
                                                      ),
                                                ),
                                              );
                                          if (resultado != null) {
                                            widget.onMontajeSelected(resultado);
                                          }
                                        },
                                        icon: Icon(Icons.grid_view),
                                        label: Text(
                                          (getMontajeDelSalon(
                                                idSalon,
                                              )?['nombre'] ??
                                              "Seleccionar montaje"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),

            SizedBox(height: 16),
          ],
        ),
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
