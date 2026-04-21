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
  final Set<int> _seleccionados = {};

  void _toggleSeleccion(int itemId) {
    setState(() {
      if (_seleccionados.contains(itemId)) {
        _seleccionados.remove(itemId);
      } else {
        _seleccionados.add(itemId);
      }
    });
  }

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
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar solicitudes: $e';
        _loading = false;
      });
    }
  }

  final Set<int> _expandedItems = {};

  List<Map<String, dynamic>> get _reservacionesENPRO => _reservaciones
      .where((r) => r['estado_codigo']?.toString().toUpperCase() == 'ENPRO')
      .toList();

  List<Map<String, dynamic>> get _reservacionesOtras => _reservaciones
      .where((r) => r['estado_codigo']?.toString().toUpperCase() != 'ENPRO')
      .toList();

  List<Map<String, dynamic>> get _reservacionesOrdenadas => [
    ..._reservacionesENPRO,
    ..._reservacionesOtras,
  ];

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
            itemCount: _reservacionesOrdenadas.length,
            itemBuilder: (context, index) {
              final reservacion = _reservacionesOrdenadas[index];
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
                                  _buildEstadoBadge(reservacion),
                                  const SizedBox(height: 4),
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
                                seleccionable: false,
                              ),
                              if (mobiliarios.isNotEmpty &&
                                  (equipamentos.isNotEmpty ||
                                      servicios.isNotEmpty))
                                const SizedBox(height: 12),
                              _buildSeccion(
                                titulo: "Equipamiento",
                                lista: equipamentos,
                                icono: Icons.devices,
                                seleccionable: false,
                              ),
                              if (equipamentos.isNotEmpty &&
                                  servicios.isNotEmpty)
                                const SizedBox(height: 12),
                              _buildSeccion(
                                titulo: "Servicios",
                                lista: servicios,
                                icono: Icons.room_service,
                                seleccionable: true,
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
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: totalItems > 0
                                        ? () => _aceptarSolicitud(
                                            reservacion,
                                            mobiliarios,
                                            equipamentos,
                                            servicios,
                                          )
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('Aceptar solicitudes'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: totalItems > 0
                                        ? () => _mostrarModalRechazar(
                                            reservacion,
                                            mobiliarios,
                                            equipamentos,
                                            servicios,
                                          )
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Rechazar solicitudes'),
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
    bool seleccionable = false,
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
          final itemId = item['id'] as int;
          final seleccionado = !completado && _seleccionados.contains(itemId);
          final precio = (item['precio'] ?? 0) as num;
          final cantidad = item['cantidad'] ?? 1;
          final subtotal = precio * cantidad;

          return GestureDetector(
            onTap: () {
              if (!completado && seleccionable) {
                _toggleSeleccion(itemId);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: completado
                    ? Colors.green.withValues(alpha: 0.05)
                    : seleccionado
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: completado
                    ? Border.all(color: Colors.green.withValues(alpha: 0.2))
                    : seleccionado
                        ? Border.all(color: Colors.blue.withValues(alpha: 0.3))
                        : null,
              ),
              child: Row(
                children: [
                  if (seleccionable && !completado)
                    Checkbox(
                      value: seleccionado,
                      onChanged: (_) => _toggleSeleccion(itemId),
                      activeColor: Colors.blue,
                    )
                  else
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
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEstadoBadge(Map<String, dynamic> reservacion) {
    final estadoCodigo =
        reservacion['estado_codigo']?.toString().toUpperCase() ?? '';
    final estadoNombre =
        reservacion['estado_nombre']?.toString() ?? estadoCodigo;

    Color badgeColor;
    String label;

    switch (estadoCodigo) {
      case 'ENPRO':
        badgeColor = Colors.blue;
        label = 'EN PROCESO';
        break;
      case 'PROC':
        badgeColor = Colors.orange;
        label = 'PROCESANDO';
        break;
      case 'CON':
        badgeColor = Colors.green;
        label = 'CONFIRMADO';
        break;
      case 'CONF':
        badgeColor = Colors.green;
        label = 'CONFIRMADO';
        break;
      case 'PEN':
        badgeColor = Colors.orange;
        label = 'PENDIENTE';
        break;
      case 'SOLIC':
        badgeColor = Colors.purple;
        label = 'SOLICITADO';
        break;
      default:
        badgeColor = Colors.grey;
        label = estadoNombre.isNotEmpty ? estadoNombre : 'DESCONOCIDO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Future<void> _aceptarSolicitud(
    Map<String, dynamic> reservacion,
    List mobiliarios,
    List equipamentos,
    List servicios,
  ) async {
    try {
      // Conversión segura de IDs - solo los seleccionados
      final mobiliariosIds = mobiliarios
          .where((m) => _seleccionados.contains(int.parse(m['id'].toString())))
          .map((m) => int.parse(m['id'].toString()))
          .toList();
      final equipamentosIds = equipamentos
          .where((e) => _seleccionados.contains(int.parse(e['id'].toString())))
          .map((e) => int.parse(e['id'].toString()))
          .toList();
      final serviciosIds = servicios
          .where((s) => _seleccionados.contains(int.parse(s['id'].toString())))
          .map((s) => int.parse(s['id'].toString()))
          .toList();
      final reservacionId = int.parse(reservacion['id'].toString());

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aceptar solicitudes'),
          content: const Text(
            '¿Está seguro de aceptar las solicitudes extra? Esto aumentará el precio total de la reservación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() {
        _loading = true;
      });

      print('Llamando aceptarSolicitud para reservación $reservacionId');
      print('mobiliariosIds: $mobiliariosIds');
      print('equipamentosIds: $equipamentosIds');
      print('serviciosIds: $serviciosIds');

      final result = await _service.aceptarSolicitud(
        reservacionId: reservacionId,
        mobiliariosIds: mobiliariosIds,
        equipamentosIds: equipamentosIds,
        serviciosIds: serviciosIds,
      );

      print('Resultado: $result');

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitudes aceptadas. Total adicional: \$${result['total_adicional']?.toStringAsFixed(2) ?? '0'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _cargarDatos();
        _seleccionados.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aceptar solicitudes en el servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Excepción en _aceptarSolicitud: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de sistema: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _mostrarModalRechazar(
    Map<String, dynamic> reservacion,
    List mobiliarios,
    List equipamentos,
    List servicios,
  ) async {
    final Set<int> _rechazados = {};
    final reservacionId = int.parse(reservacion['id'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Seleccionar elementos a rechazar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecciona los elementos que deseas rechazar:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            if (mobiliarios.isNotEmpty) ...[
                              const Text('Mobiliario',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...mobiliarios.map((m) => CheckboxListTile(
                                    value: _rechazados.contains(int.parse(m['id'].toString())),
                                    onChanged: (sel) {
                                      setModalState(() {
                                        if (sel == true) {
                                          _rechazados.add(int.parse(m['id'].toString()));
                                        } else {
                                          _rechazados.remove(int.parse(m['id'].toString()));
                                        }
                                      });
                                    },
                                    title: Text(m['nombre'] ?? ''),
                                    subtitle: Text('x${m['cantidad'] ?? 1}'),
                                  )),
                              const Divider(),
                            ],
                            if (equipamentos.isNotEmpty) ...[
                              const Text('Equipamiento',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...equipamentos.map((e) => CheckboxListTile(
                                    value: _rechazados.contains(int.parse(e['id'].toString())),
                                    onChanged: (sel) {
                                      setModalState(() {
                                        if (sel == true) {
                                          _rechazados.add(int.parse(e['id'].toString()));
                                        } else {
                                          _rechazados.remove(int.parse(e['id'].toString()));
                                        }
                                      });
                                    },
                                    title: Text(e['nombre'] ?? ''),
                                    subtitle: Text('x${e['cantidad'] ?? 1}'),
                                  )),
                              const Divider(),
                            ],
                            if (servicios.isNotEmpty) ...[
                              const Text('Servicios',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...servicios.map((s) => CheckboxListTile(
                                    value: _rechazados.contains(int.parse(s['id'].toString())),
                                    onChanged: (sel) {
                                      setModalState(() {
                                        if (sel == true) {
                                          _rechazados.add(int.parse(s['id'].toString()));
                                        } else {
                                          _rechazados.remove(int.parse(s['id'].toString()));
                                        }
                                      });
                                    },
                                    title: Text(s['nombre'] ?? ''),
                                  )),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _rechazados.isEmpty
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await _rechazarSolicitud(
                                    reservacionId,
                                    _rechazados.toList(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.cancel),
                          label: Text(
                              'Rechazar ${_rechazados.length} elementos'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _rechazarSolicitud(int reservacionId, List<int> rechazados) async {
    setState(() => _loading = true);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar rechazo'),
        content: Text(
            '¿Estás seguro de rechazar ${rechazados.length} elementos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      setState(() => _loading = false);
      return;
    }

    try {
      final result = await _service.rechazarSolicitud(
        reservacionId: reservacionId,
        rechazados: rechazados,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rechazados.length} elementos rechazados'),
            backgroundColor: Colors.red,
          ),
        );
        await _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al rechazar en el servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
