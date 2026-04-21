import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/components/widget_cantidades_elementos.dart';
import 'package:followroom_flutter/services/solicitudes_extra_service.dart';

class AlmacenistaSolicitudesScreen extends StatefulWidget {
  const AlmacenistaSolicitudesScreen({super.key});

  @override
  State<AlmacenistaSolicitudesScreen> createState() =>
      _AlmacenistaSolicitudesScreenState();
}

class _AlmacenistaSolicitudesScreenState
    extends State<AlmacenistaSolicitudesScreen> {
  final SolicitudesExtraService _service = SolicitudesExtraService();

  List<Map<String, dynamic>> _reservaciones = [];
  bool _loading = true;
  String? _error;

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

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarSolicitudes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
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
                'No hay reservaciones con solicitudes extras pendientes.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarSolicitudes,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: AppColores.background2),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _reservacionesOrdenadas.length,
            itemBuilder: (context, index) {
              final item = _reservacionesOrdenadas[index];
              final totalItems =
                  ((item['mobiliarios_extra'] as List?)?.length ?? 0) +
                  ((item['equipamiento_extra'] as List?)?.length ?? 0);
              final pendientes =
                  ((item['mobiliarios_extra'] as List?)
                          ?.where((m) => m['completado'] != true)
                          ?.length ??
                      0) +
                  ((item['equipamiento_extra'] as List?)
                          ?.where((e) => e['completado'] != true)
                          ?.length ??
                      0);

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
                          builder: (context) => SolicitudesDetalle(
                            reservacion: item,
                            onActualizar: _cargarSolicitudes,
                          ),
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
                              _buildEstadoBadge(item),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['nombre'] ?? 'Reservación ${item['id']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: pendientes > 0
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pendientes > 0
                                      ? '$pendientes pendientes'
                                      : 'Completado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: pendientes > 0
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColores.foreground.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['fecha'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColores.foreground.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColores.foreground.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['salon_nombre'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColores.foreground.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cliente: ${item['cliente_nombre'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColores.foreground.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 16,
                                color: AppColores.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$totalItems items extras',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColores.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColores.primary,
                              ),
                            ],
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
      ),
    );
  }
}

class SolicitudesDetalle extends StatefulWidget {
  final Map<String, dynamic> reservacion;
  final VoidCallback onActualizar;

  const SolicitudesDetalle({
    super.key,
    required this.reservacion,
    required this.onActualizar,
  });

  @override
  State<SolicitudesDetalle> createState() => _SolicitudesDetalleState();
}

class _SolicitudesDetalleState extends State<SolicitudesDetalle> {
  final SolicitudesExtraService _service = SolicitudesExtraService();

  late List<Map<String, dynamic>> _mobiliarios;
  late List<Map<String, dynamic>> _equipamientos;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _mobiliarios = List<Map<String, dynamic>>.from(
      (widget.reservacion['mobiliarios_extra'] as List?) ?? [],
    );
    _equipamientos = List<Map<String, dynamic>>.from(
      (widget.reservacion['equipamiento_extra'] as List?) ?? [],
    );
  }

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);

    final success = await _service.completarItems(
      reservacionId: widget.reservacion['id'],
      mobiliarios: _mobiliarios,
      equipamentos: _equipamientos,
    );

    if (mounted) {
      setState(() => _guardando = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onActualizar();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar cambios'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreReservacion = widget.reservacion['nombre'] ?? 'Reservación';

    return Scaffold(
      backgroundColor: AppColores.background2,
      appBar: AppBar(
        title: Text(nombreReservacion),
        backgroundColor: AppColores.background2,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: AppColores.background2),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ContainerStyles.sombreado,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreReservacion,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.reservacion['fecha'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.reservacion['salon_nombre'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.reservacion['cliente_nombre'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _seccion(
                titulo: 'Mobiliario Extra',
                icono: Icons.chair,
                items: _mobiliarios,
                onChanged: (index, completado, cantidad) {
                  setState(() {
                    _mobiliarios[index]['completado'] = completado;
                    _mobiliarios[index]['cantidad_entregada'] = cantidad;
                  });
                },
              ),
              const SizedBox(height: 16),
              _seccion(
                titulo: 'Equipamiento Extra',
                icono: Icons.devices,
                items: _equipamientos,
                onChanged: (index, completado, cantidad) {
                  setState(() {
                    _equipamientos[index]['completado'] = completado;
                    _equipamientos[index]['cantidad_entregada'] = cantidad;
                  });
                },
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
                  onPressed: _guardando ? null : _guardarCambios,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirmar Entrega'),
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
    required List<Map<String, dynamic>> items,
    required Function(int, bool, int) onChanged,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: ContainerStyles.sombreado,
        child: Row(
          children: [
            Icon(icono, color: AppColores.primary),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              'Sin solicitudes',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

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
              const Spacer(),
              Text(
                '${items.length} items',
                style: const TextStyle(
                  color: AppColores.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final completado = item['completado'] ?? false;
            final cantidadTotal = item['cantidad'] ?? 1;
            final cantidadEntregada =
                item['cantidad_entregada'] ??
                (completado ? cantidadTotal : 0);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    completado
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border:
                    completado
                        ? Border.all(color: Colors.green.withValues(alpha: 0.3))
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cant: ',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        SizedBox(
                          width: 100,
                          height: 35,
                          child: WidgetCantidadElementos(
                            cantidadActual: cantidadEntregada,
                            stockMaximo: cantidadTotal,
                            onChange: (nuevaCantidad) {
                              onChanged(index, nuevaCantidad > 0, nuevaCantidad);
                            },
                          ),
                        ),
                        Text(
                          ' /$cantidadTotal',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    value: completado,
                    activeColor: Colors.green,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      item['nombre'] ?? '',
                      style: TextStyle(
                        decoration:
                            completado ? TextDecoration.lineThrough : null,
                        color: completado ? Colors.grey : AppColores.foreground,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      item['descripcion'] ?? '',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    onChanged: (bool? value) {
                      final nuevoValor = value ?? false;
                      onChanged(
                        index,
                        nuevoValor,
                        nuevoValor ? cantidadTotal : 0,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
