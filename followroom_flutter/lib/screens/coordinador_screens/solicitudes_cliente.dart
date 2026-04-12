import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/estados_widgets.dart';
import 'package:followroom_flutter/services/solicitudes_extra_service.dart';

class ReservacionesVisualScreen extends StatefulWidget {
  const ReservacionesVisualScreen({super.key});

  @override
  State<ReservacionesVisualScreen> createState() =>
      _ReservacionesVisualScreenState();
}

class _ReservacionesVisualScreenState extends State<ReservacionesVisualScreen> {
  final SolicitudesExtraService _service = SolicitudesExtraService();

  List<Map<String, dynamic>> _reservaciones = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final solicitudes = await _service.getSolicitudesExtra();
      setState(() {
        _reservaciones = solicitudes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar solicitudes: $e';
        _loading = false;
      });
    }
  }

  final Set<int> _expandedItems = {};

  double _calcularTotal(Map<String, dynamic> reservacion) {
    double total = 0;
    for (var m in (reservacion['mobiliarios_extra'] as List?) ?? []) {
      total +=
          ((m['precio'] ?? 0) as num).toDouble() *
          ((m['cantidad'] ?? 0) as num).toDouble();
    }
    for (var e in (reservacion['equipamiento_extra'] as List?) ?? []) {
      total +=
          ((e['precio'] ?? 0) as num).toDouble() *
          ((e['cantidad'] ?? 0) as num).toDouble();
    }
    for (var s in (reservacion['servicios_extra'] as List?) ?? []) {
      total += (s['precio'] ?? 0) as num;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(mensaje: 'Cargando solicitudes...');
    }

    if (_error != null) {
      return ErrorDisplay.conexion(mensaje: _error!, onRetry: _cargarDatos);
    }

    if (_reservaciones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay solicitudes extras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'No hay reservaciones con solicitudes extras.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: AppColores.background2),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _reservaciones.length,
            itemBuilder: (context, index) {
              final reservacion = _reservaciones[index];
              final isExpanded = _expandedItems.contains(index);
              final total = _calcularTotal(reservacion);

              final mobiliarios =
                  (reservacion['mobiliarios_extra'] as List?) ?? [];
              final equipamentos =
                  (reservacion['equipamiento_extra'] as List?) ?? [];
              final servicios = (reservacion['servicios_extra'] as List?) ?? [];
              final totalItems =
                  mobiliarios.length + equipamentos.length + servicios.length;

              final todosCompletados =
                  mobiliarios.every((m) => m['completado'] == true) &&
                  equipamentos.every((e) => e['completado'] == true);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: ContainerStyles.sombreado,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedItems.remove(index);
                            } else {
                              _expandedItems.add(index);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reservacion['nombre'] ??
                                          'Reservación ${reservacion['id']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColores.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          reservacion['fecha'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.location_on,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          reservacion['salon_nombre'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          reservacion['cliente_nombre'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: todosCompletados
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.orange.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      todosCompletados
                                          ? 'Completado'
                                          : 'Pendiente',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: todosCompletados
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColores.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColores.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(),
                        secondChild: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              _buildSeccion(
                                titulo: "Mobiliario",
                                lista: mobiliarios,
                                icono: Icons.chair,
                              ),
                              if (mobiliarios.isNotEmpty &&
                                  (equipamentos.isNotEmpty ||
                                      servicios.isNotEmpty))
                                const SizedBox(height: 12),
                              _buildSeccion(
                                titulo: "Equipamiento",
                                lista: equipamentos,
                                icono: Icons.devices,
                              ),
                              if (equipamentos.isNotEmpty &&
                                  servicios.isNotEmpty)
                                const SizedBox(height: 12),
                              _buildSeccion(
                                titulo: "Servicios",
                                lista: servicios,
                                icono: Icons.room_service,
                              ),
                              if (totalItems > 0) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColores.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Extras:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '\$${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required List lista,
    required IconData icono,
  }) {
    if (lista.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: AppColores.primary),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColores.foreground,
              ),
            ),
            const Spacer(),
            Text(
              '${lista.length} items',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...lista.map((item) {
          final completado = item['completado'] ?? false;
          final precio = (item['precio'] ?? 0) as num;
          final cantidad = item['cantidad'] ?? 1;
          final subtotal = precio * cantidad;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: completado
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: completado
                  ? Border.all(color: Colors.green.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  completado ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: completado ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nombre'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColores.foreground.withValues(alpha: 0.8),
                          decoration: completado
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item['descripcion'] != null &&
                          item['descripcion'].toString().isNotEmpty)
                        Text(
                          item['descripcion'] ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      cantidad > 1 ? 'x$cantidad' : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColores.primary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${precio.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (cantidad > 1)
                      Text(
                        '=\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColores.primary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
