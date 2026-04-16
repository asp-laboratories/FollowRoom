import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_montaje_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_mobiliario_reservacion.dart';
import 'package:followroom_flutter/services/salon_service.dart';

class TabSalon extends StatefulWidget {
  final Map<int, String> montajesPorSalon;
  final Map<String, dynamic>? salonSeleccionado;
  final Function(int, String) onMontajeSelected;
  final Function(Map<String, dynamic>?) onSalonSelected;
  final Map<int, List<Map<String, dynamic>>> mobiliariosPorSalon;
  final Function(int, List<Map<String, dynamic>>) onMobiliariosChanged;
  final String? fechaSeleccionada;
  final int? asistentes;

  const TabSalon({
    super.key,
    required this.montajesPorSalon,
    required this.salonSeleccionado,
    required this.onMontajeSelected,
    required this.onSalonSelected,
    required this.mobiliariosPorSalon,
    required this.onMobiliariosChanged,
    this.fechaSeleccionada,
    this.asistentes,
  });

  @override
  State<TabSalon> createState() => _TabSalonState();
}

class _TabSalonState extends State<TabSalon>
    with AutomaticKeepAliveClientMixin {
  final SalonService _salonService = SalonService();
  List<Map<String, dynamic>> salonesDB = [];
  bool _cargando = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print('TabSalon: initState - fecha: ${widget.fechaSeleccionada}');
    _cargarSalones();
  }

  @override
  void didUpdateWidget(TabSalon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fechaSeleccionada != oldWidget.fechaSeleccionada) {
      _cargarSalones();
    }

    if (widget.salonSeleccionado != null) {
      if (widget.asistentes != oldWidget.asistentes) {
        final capacidadSalon =
            int.tryParse(widget.salonSeleccionado!['capacidad'].toString()) ??
            0;

        if (_comprobarCapacidad(capacidadSalon)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Se deseleccionó el salón debido al cambio de asistentes",
                ),
                backgroundColor: Colors.orange,
              ),
            );
            widget.onSalonSelected(null);
          });
        }
      }
    }
  }

  Future<void> _cargarSalones() async {
    setState(() {
      _cargando = true;
    });
    try {
      List<Map<String, dynamic>> data;
      // print('TabSalon: Cargando salones para fecha: ${widget.fechaSeleccionada}');

      if (widget.fechaSeleccionada != null &&
          widget.fechaSeleccionada!.isNotEmpty) {
        data = await _salonService.getSalonesDisponibles(
          widget.fechaSeleccionada!,
        );
      } else {
        data = await _salonService.getSalonesConEstado();
      }

      if (mounted) {
        setState(() {
          salonesDB = data.map((salon) {
            // print('TabSalon: Salon ${salon['nombre']} - disponible: ${salon['disponible']} - estado: ${salon['estado']}');
            final estadoSalon = salon['estado'];
            String estadoNombre = '';
            if (estadoSalon is Map) {
              estadoNombre = estadoSalon['nombre']?.toString() ?? '';
            } else {
              estadoNombre = estadoSalon?.toString() ?? '';
            }
            return {
              ...salon,
              'precio': salon['costo'] ?? salon['precio'] ?? 0,
              'capacidad': salon['maxCapacidad'] ?? salon['capacidad'] ?? 0,
              'estado': estadoNombre,
              'dimensiones': salon['dimensiones'] ?? 'No disponible',
              'mtrCuad':
                  salon['metrosCuadrados']?.toString() ?? "No disponible",
            };
          }).toList();
          _cargando = false;
        });

        if (widget.salonSeleccionado != null) {
          final salonAcutalizado = salonesDB.firstWhere(
            (s) => s['id'] == widget.salonSeleccionado!['id'],
            orElse: () => {},
          );
          if (salonAcutalizado.isEmpty || _estaBloqueado(salonAcutalizado)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "El salón seleccionado no está disponible en esta nueva fecha",
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              widget.onSalonSelected(null);
            });
          }
        }
      }
    } catch (e) {
      // print('Error al cargar salones: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  String? getMontajeDelSalon(int salonId) {
    return widget.montajesPorSalon[salonId];
  }

  List<Map<String, dynamic>> getMobiliariosDelSalon(int salonId) {
    return widget.mobiliariosPorSalon[salonId] ?? [];
  }

  bool _estaBloqueado(Map<String, dynamic> salon) {
    // Si la API retorna un campo 'disponible' (bool), lo priorizamos
    if (salon['estado'] != null && salon['estado'] == 'Disponible') {
      return false;
    }

    // Si no, fallback al nombre del estado
    final estado = salon['estado_codigo']?.toString().toUpperCase() ?? '';
    return estado != 'DISPONIBLE' || estado != 'DISP' || estado != 'DIS';
  }

  bool _comprobarCapacidad(int capacidadSalon) {
    if (widget.asistentes == null) {
      return false;
    }
    return capacidadSalon < widget.asistentes!;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // print('TabSalon: building - fechaSeleccionada: ${widget.fechaSeleccionada}');
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
                            onPressed: () => widget.onSalonSelected(null),
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
                        "Precio: \$${widget.salonSeleccionado!['precio']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Capacidad: ${widget.salonSeleccionado!['capacidad']} personas",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Divider(),
                      Text(
                        "Montaje: ${getMontajeDelSalon(widget.salonSeleccionado!['id']) ?? 'No seleccionado'}",
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
            if (_cargando)
              Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount: salonesDB.length,
                itemBuilder: (context, index) {
                  final salon = salonesDB[index];
                  final int salonId = salon['id'];
                  final bool isSelected =
                      widget.salonSeleccionado?['id'] == salonId;
                  final String? montaje = getMontajeDelSalon(salonId);
                  final List<Map<String, dynamic>> mobiliariosDelSalon =
                      getMobiliariosDelSalon(salonId);
                  // print(salon);

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: ContainerStyles.sombreado,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _estaBloqueado(salon)
                            ? null
                            : _comprobarCapacidad(
                                int.parse(salon['capacidad'].toString()),
                              )
                            ? null
                            : () => widget.onSalonSelected(salon),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Opacity(
                            opacity: _estaBloqueado(salon)
                                ? 0.5
                                : _comprobarCapacidad(
                                    int.parse(salon['capacidad'].toString()),
                                  )
                                ? 0.75
                                : 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (_estaBloqueado(salon))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'NO DISPONIBLE EL DIA SELECCIONADO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    else if (_comprobarCapacidad(
                                      int.parse(salon['capacidad'].toString()),
                                    ))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange,
                                          ),
                                        ),
                                        child: Text(
                                          'NO RECOMENDABLE PARA \nLA CANTIDAD DE ASISTENTES',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    _getEstadoIcon(
                                      salon['estado'] ?? 'Disponible',
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      salon['estado'] ?? 'Disponible',
                                      style: TextStyle(
                                        color: _getEstadoColor(
                                          salon['estado'] ?? 'Disponible',
                                        ),
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
                                      "${salon['capacidad'] ?? 0} personas",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      "\$${salon['precio'] ?? 0}",
                                      style: TextStyle(
                                        color: AppColores.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (salon['dimensiones'] !=
                                        'No disponible') ...[
                                      Icon(
                                        Icons.square_foot,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "${salon['dimensiones']}",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        " - ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${salon['mtrCuad']}m²",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _estaBloqueado(salon)
                                          ? null
                                          : _comprobarCapacidad(
                                              int.parse(
                                                salon['capacidad'].toString(),
                                              ),
                                            )
                                          ? null
                                          : () async {
                                              final resultado =
                                                  await Navigator.push<
                                                    Map<String, dynamic>
                                                  >(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          NavigatorMontajeReservacion(
                                                            idSalon: salonId,
                                                          ),
                                                    ),
                                                  );
                                              if (resultado != null) {
                                                widget.onMontajeSelected(
                                                  salonId,
                                                  '${resultado['nombre'] ?? ''}-${resultado['id'] ?? ''}',
                                                );
                                                final mobiliariosSugeridos =
                                                    (resultado['mobiliarios_sugeridos']
                                                            as List?)
                                                        ?.map(
                                                          (e) =>
                                                              Map<
                                                                String,
                                                                dynamic
                                                              >.from(e),
                                                        )
                                                        .toList() ??
                                                    [];

                                                final mobiliarios =
                                                    await Navigator.push<
                                                      List<Map<String, dynamic>>
                                                    >(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            NavigatorMobiliarioReservacion(
                                                              mobiliariosIniciales:
                                                                  getMobiliariosDelSalon(
                                                                    salonId,
                                                                  ),
                                                              mobiliariosSugeridos:
                                                                  mobiliariosSugeridos,
                                                            ),
                                                      ),
                                                    );
                                                if (mobiliarios != null) {
                                                  widget.onMobiliariosChanged(
                                                    salonId,
                                                    mobiliarios,
                                                  );
                                                }
                                              }
                                            },
                                      icon: Icon(Icons.grid_view),
                                      label: Text(
                                        montaje ?? "Seleccionar montaje",
                                      ),
                                    ),
                                  ],
                                ),
                                if (mobiliariosDelSalon.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mobiliarios seleccionados",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        ...mobiliariosDelSalon.map(
                                          (m) => Text(
                                            "${m['nombre']} x${m['cantidad']}",
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        Text(
                                          "Total: \$${mobiliariosDelSalon.fold<int>(0, (sum, m) => sum + ((m['precio'] as int? ?? 0) * (m['cantidad'] as int? ?? 1)))}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColores.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
