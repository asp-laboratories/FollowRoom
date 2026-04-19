import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/components/widget_cantidades_elementos.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/mobiliario_service.dart';
import 'package:followroom_flutter/services/equipamiento_service.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'package:followroom_flutter/services/session_data.dart';
import 'package:followroom_flutter/services/solicitudes_extra_service.dart';

class SolicitudesScreen extends StatefulWidget {
  final int? reservacionId;
  final Map<String, dynamic>? reservacionInfo;
  final VoidCallback? onVolver;

  const SolicitudesScreen({
    super.key,
    this.reservacionId,
    this.reservacionInfo,
    this.onVolver,
  });

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  bool _mostrandoTabs = false;
  final MobiliarioService _mobiliarioService = MobiliarioService();
  final EquipamientoService _equipamientoService = EquipamientoService();
  final ReservacionService _reservacionService = ReservacionService();
  final SolicitudesExtraService _solicitudesExtraService =
      SolicitudesExtraService();

  List<Map<String, dynamic>> _mobiliario = [];
  List<Map<String, dynamic>> _equipamiento = [];
  List<Map<String, dynamic>> _servicios = [];
  List<Map<String, dynamic>> _tiposMobiliario = [];
  List<Map<String, dynamic>> _tiposEquipamiento = [];
  List<Map<String, dynamic>> _tiposServicio = [];
  List<Map<String, dynamic>> _reservacionesActivas = [];
  List<Map<String, dynamic>> _misSolicitudesExtra = [];

  List<Map<String, dynamic>> get _reservacionesENPRO => _reservacionesActivas
      .where((r) => r['estado_codigo']?.toString().toUpperCase() == 'ENPRO')
      .toList();

  List<Map<String, dynamic>> get _reservacionesOtras => _reservacionesActivas
      .where((r) => r['estado_codigo']?.toString().toUpperCase() != 'ENPRO')
      .toList();

  String? _tipoMobiliarioSeleccionado;
  String? _tipoEquipamientoSeleccionado;
  String? _tipoServicioSeleccionado;

  bool _loading = true;
  bool _noReservacionesActivas = false;
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

      final email = SessionData.email;
      if (email == null) {
        setState(() {
          _error = 'No hay sesión activa';
          _loading = false;
        });
        return;
      }

      final results = await Future.wait([
        _mobiliarioService.getMobiliarios(),
        _equipamientoService.getEquipamientos(),
        _equipamientoService.getServicios(),
        _mobiliarioService.getTiposMobil(),
        _equipamientoService.getServicios(),
        _reservacionService.getMisReservaciones(email),
        _solicitudesExtraService.getMisSolicitudesExtra(email),
      ]);

      final mobiliariosAPI = (results[0] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final equipamentosAPI = (results[1] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final serviciosAPI = (results[2] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final tiposMobiliarioAPI = (results[3] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final tiposServicioAPI = (results[4] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final reservaciones = (results[5] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final misSolicitudesExtra = (results[6] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final int? reservacionIdFiltro = widget.reservacionId;

      final Set<int> serviciosSolicitados = {};
      final Map<int, int> mobiliariosCantidad = {};
      final Map<int, int> equipamentosCantidad = {};

      if (reservacionIdFiltro != null) {
        final solicitudReservacion = misSolicitudesExtra
            .where((s) => s['reservacion_id'] == reservacionIdFiltro)
            .toList();

        for (var solicitud in solicitudReservacion) {
          for (var s in (solicitud['servicios_extra'] as List?) ?? []) {
            serviciosSolicitados.add(s['servicio_id'] as int);
          }
          for (var m in (solicitud['mobiliarios_extra'] as List?) ?? []) {
            mobiliariosCantidad[m['mobiliario_id'] as int] =
                m['cantidad'] as int;
          }
          for (var e in (solicitud['equipamiento_extra'] as List?) ?? []) {
            equipamentosCantidad[e['equipamiento_id'] as int] =
                e['cantidad'] as int;
          }
        }
      } else {
        for (var solicitud in misSolicitudesExtra) {
          for (var s in (solicitud['servicios_extra'] as List?) ?? []) {
            serviciosSolicitados.add(s['servicio_id'] as int);
          }
          for (var m in (solicitud['mobiliarios_extra'] as List?) ?? []) {
            mobiliariosCantidad[m['mobiliario_id'] as int] =
                m['cantidad'] as int;
          }
          for (var e in (solicitud['equipamiento_extra'] as List?) ?? []) {
            equipamentosCantidad[e['equipamiento_id'] as int] =
                e['cantidad'] as int;
          }
        }
      }

      final reservacionesActivas = reservaciones.where((r) {
        final estado = r['estado_codigo']?.toString().toUpperCase();
        print('Reservacion ${r['id']}: estado_codigo = $estado');
        return estado == 'SOLIC' ||
            estado == 'PEN' ||
            estado == 'CONF' ||
            estado == 'CON' ||
            estado == 'PROC';
      }).toList();

      setState(() {
        _mobiliario = mobiliariosAPI.map((m) {
          final id = m['id'] as int;
          final cantidadPrev = mobiliariosCantidad[id] ?? 0;
          return {
            ...m,
            'cantidad': cantidadPrev,
            'cantidad_original': cantidadPrev,
            'ya_solicitado': cantidadPrev > 0,
          };
        }).toList();
        _equipamiento = equipamentosAPI.map((e) {
          final id = e['id'] as int;
          final cantidadPrev = equipamentosCantidad[id] ?? 0;
          return {
            ...e,
            'cantidad': cantidadPrev,
            'cantidad_original': cantidadPrev,
            'ya_solicitado': cantidadPrev > 0,
          };
        }).toList();
        _servicios = serviciosAPI.map((s) {
          final id = s['id'] as int;
          return {
            ...s,
            'seleccionado': false,
            'ya_solicitado': serviciosSolicitados.contains(id),
          };
        }).toList();
        _tiposMobiliario = tiposMobiliarioAPI;
        _tiposEquipamiento = [
          {'id': 1, 'nombre': 'audio'},
          {'id': 2, 'nombre': 'video'},
          {'id': 3, 'nombre': 'iluminacion'},
        ];
        _tiposServicio = tiposServicioAPI;
        _reservacionesActivas = reservacionesActivas;
        _misSolicitudesExtra = misSolicitudesExtra;
        _noReservacionesActivas = reservacionesActivas.isEmpty;
        print(
          'Reservaciones activas encontradas: ${reservacionesActivas.length}',
        );
        print('IDs: ${reservacionesActivas.map((r) => r['id']).toList()}');
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _mobiliarioFiltrado {
    if (_tipoMobiliarioSeleccionado == null ||
        _tipoMobiliarioSeleccionado == 'todos') {
      return _mobiliario;
    }
    return _mobiliario
        .where((m) => m['tipo_nombre'] == _tipoMobiliarioSeleccionado)
        .toList();
  }

  List<Map<String, dynamic>> get _equipamientoFiltrado {
    if (_tipoEquipamientoSeleccionado == null ||
        _tipoEquipamientoSeleccionado == 'todos') {
      return _equipamiento;
    }
    return _equipamiento.where((e) {
      final tipoId = e['tipo_equipa'];
      final tipoNombre =
          e['tipo_nombre']?.toString().toLowerCase() ??
          e['tipo_equipa']?.toString().toLowerCase() ??
          '';

      print(
        'Equipamiento: ${e['nombre']}, tipo_equipa: $tipoId, tipo_nombre: $tipoNombre, filtro: $_tipoEquipamientoSeleccionado',
      );

      if (_tipoEquipamientoSeleccionado == 'audio') {
        return tipoNombre.contains('audio');
      }
      if (_tipoEquipamientoSeleccionado == 'video') {
        return tipoNombre.contains('video');
      }
      if (_tipoEquipamientoSeleccionado == 'iluminacion') {
        return tipoNombre.contains('ilumin');
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _serviciosFiltrados {
    if (_tipoServicioSeleccionado == null ||
        _tipoServicioSeleccionado == 'todos') {
      return _servicios;
    }
    return _servicios.where((s) {
      final tipoId = s['tipo_servicio'];
      final tipoNombre = s['tipo_servicio']?.toString().toLowerCase() ?? '';

      print(
        'Servicio: ${s['nombre']}, tipo_servicio: $tipoId, filtro: $_tipoServicioSeleccionado',
      );

      return tipoId.toString() == _tipoServicioSeleccionado ||
          tipoNombre.contains(_tipoServicioSeleccionado!.toLowerCase());
    }).toList();
  }

  void _actualizarCantidad(
    List<Map<String, dynamic>> lista,
    int index,
    int nuevaCantidad,
  ) {
    if (nuevaCantidad < 0) return;
    setState(() {
      lista[index]['cantidad'] = nuevaCantidad;
    });
  }

  void _toggleServicio(int index) {
    setState(() {
      _servicios[index]['seleccionado'] = !_servicios[index]['seleccionado'];
    });
  }

  List<Map<String, dynamic>> get _seleccionados {
    return [
      ..._mobiliario.where(
        (e) =>
            (e['cantidad'] as int) > 0 &&
            (!e['ya_solicitado'] ||
                (e['cantidad'] as int) != (e['cantidad_original'] as int)),
      ),
      ..._equipamiento.where(
        (e) =>
            (e['cantidad'] as int) > 0 &&
            (!e['ya_solicitado'] ||
                (e['cantidad'] as int) != (e['cantidad_original'] as int)),
      ),
      ..._servicios.where((e) => e['seleccionado'] == true),
    ];
  }

  double get _total {
    double total = 0;
    for (var m in _mobiliario) {
      total +=
          (m['cantidad'] as int) *
          ((m['precio'] ?? m['costo'] ?? 0) as num).toDouble();
    }
    for (var e in _equipamiento) {
      total += (e['cantidad'] as int) * ((e['costo'] ?? 0) as num).toDouble();
    }
    for (var s in _servicios.where((e) => e['seleccionado'] == true)) {
      total += ((s['costo'] ?? 0) as num).toDouble();
    }
    return total;
  }

  void _mostrarDialogoReservacion() {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay elementos seleccionados')),
      );
      return;
    }

    if (_reservacionesActivas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay reservaciones activas')),
      );
      return;
    }

    int? reservacionIdSeleccionada;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona la reservación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_reservacionesENPRO.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EN PROCESO',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    ..._reservacionesENPRO.map(
                      (r) => RadioListTile<int>(
                        value: r['id'],
                        groupValue: reservacionIdSeleccionada,
                        onChanged: (value) {
                          setModalState(() {
                            reservacionIdSeleccionada = value;
                          });
                        },
                        title: Text(r['nombre'] ?? 'Reservación ${r['id']}'),
                        subtitle: Text(
                          '${r['fecha'] ?? ''} - ${r['salon_nombre'] ?? ''}',
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                  ..._reservacionesOtras.map(
                    (r) => RadioListTile<int>(
                      value: r['id'],
                      groupValue: reservacionIdSeleccionada,
                      onChanged: (value) {
                        setModalState(() {
                          reservacionIdSeleccionada = value;
                        });
                      },
                      title: Text(r['nombre'] ?? 'Reservación ${r['id']}'),
                      subtitle: Text(
                        '${r['fecha'] ?? ''} - ${r['salon_nombre'] ?? ''}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: reservacionIdSeleccionada != null
                          ? () =>
                                _confirmarSolicitud(reservacionIdSeleccionada!)
                          : null,
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarSolicitud(int reservacionId) async {
    Navigator.pop(context);
    
    setState(() {
      _mostrandoTabs = true;
    });

    final mobiliarios = _mobiliario
        .where(
          (m) =>
              (m['cantidad'] as int) > 0 &&
              (!m['ya_solicitado'] ||
                  (m['cantidad'] as int) != (m['cantidad_original'] as int)),
        )
        .map((m) => {'id': m['id'], 'cantidad': m['cantidad']})
        .toList();

    final equipamentos = _equipamiento
        .where(
          (e) =>
              (e['cantidad'] as int) > 0 &&
              (!e['ya_solicitado'] ||
                  (e['cantidad'] as int) != (e['cantidad_original'] as int)),
        )
        .map((e) => {'id': e['id'], 'cantidad': e['cantidad']})
        .toList();

    final servicios = _servicios
        .where((s) => s['seleccionado'] == true)
        .map((s) => {'id': s['id']})
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _reservacionService.agregarExtrasAReservacion(
      reservacionId: reservacionId,
      mobiliarios: mobiliarios,
      equipamentos: equipamentos,
      servicios: servicios,
    );

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud extra enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarResumen() {
    final seleccionados = _seleccionados;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (seleccionados.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No hay solicitudes seleccionadas')),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Resumen de solicitud',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...seleccionados.map(
                (e) => ListTile(
                  title: Text(e['nombre']),
                  subtitle: Text(e['descripcion'] ?? e['descripEvento'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e['ya_solicitado'] == true &&
                          (e['cantidad'] as int) !=
                              (e['cantidad_original'] as int))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACT',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (e['ya_solicitado'] == true &&
                          (e['cantidad'] as int) ==
                              (e['cantidad_original'] as int))
                        const SizedBox()
                      else
                        e['cantidad'] != null
                            ? Text('x${e['cantidad']}')
                            : const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
                            const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColores.primary,
                ),
                onPressed: () {
                  if (_seleccionados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona al menos un elemento')),
                    );
                    return;
                  }
                  if (widget.reservacionId != null) {
                    _confirmarSolicitud(widget.reservacionId!);
                  } else {
                    Navigator.pop(context);
                    _mostrarDialogoReservacion();
                  }
                },
                child: const Text('Confirmar Solicitud'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.reservacionId != null)
                  Container(
                    color: AppColores.background2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            if (widget.onVolver != null) {
                              widget.onVolver!();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                          },
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text('Volver'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.reservacionInfo?['nombre'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.reservacionInfo?['fecha'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildMainContent()),
              ],
            ),
    );
  }

  Widget _buildMainContent() {
    if (widget.reservacionId == null && !_mostrandoTabs && _reservacionesActivas.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarDialogoReservacion();
      });
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDatos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_noReservacionesActivas) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No tienes reservaciones activas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Para solicitar mobiliarios, equipamiento o servicios extras, necesitas tener una reservación confirmada o en proceso.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          ButtonsTabBar(
            backgroundColor: AppColores.primary,
            unselectedBackgroundColor: Colors.white,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            radius: 50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            tabs: const [
              Tab(text: "Mobiliario"),
              Tab(text: "Equipamiento"),
              Tab(text: "Servicios"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMobiliarioLista(),
                _buildEquipamientoLista(),
                _buildServiciosLista(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _mostrarResumen,
                child: Text(
                  'Solicitar (Total: \$${_total.toStringAsFixed(2)})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobiliarioLista() {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text(
                      'Filtrar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _tipoMobiliarioSeleccionado,
                        hint: const Text('Todos'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: 'todos',
                            child: Text('Todos'),
                          ),
                          ..._tiposMobiliario.map(
                            (value) => DropdownMenuItem(
                              value: value['nombre'],
                              child: Text(value['nombre'] ?? ''),
                            ),
                          ),
                        ],
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _tipoMobiliarioSeleccionado = nuevoValor;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Catálogo de mobiliario:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _mobiliarioFiltrado.length,
              itemBuilder: (context, index) {
                final item = _mobiliarioFiltrado[index];
                final cantidad = item['cantidad'] as int;
                final yaSolicitado = item['ya_solicitado'] as bool? ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['nombre'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: yaSolicitado
                                            ? Colors.grey
                                            : AppColores.foreground,
                                      ),
                                    ),
                                  ),
                                  if (yaSolicitado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'x$cantidad',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                item['descripcion'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  if (item['caracteristicas'] != null)
                                    ...item['caracteristicas'].take(2).map((
                                      carac,
                                    ) {
                                      return Text(
                                        "- $carac ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColores.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['tipo_nombre'] ??
                                          item['tipo_movil']?.toString() ??
                                          '',
                                      style: const TextStyle(
                                        color: AppColores.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${item['precio'] ?? item['costo'] ?? 0}',
                                    style: const TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            WidgetCantidadElementos(
                              cantidadActual: cantidad,
                              stockMaximo:
                                  item['stockDisponible'] ?? item['stock'] ?? 0,
                              onChange: (nuevaCantidad) {
                                final originalIndex = _mobiliario.indexOf(item);
                                _actualizarCantidad(
                                  _mobiliario,
                                  originalIndex,
                                  nuevaCantidad,
                                );
                              },
                            ),
                            // IconButton(
                            //   onPressed: cantidad > 0
                            //       ? () {
                            //           final originalIndex = _mobiliario.indexOf(
                            //             item,
                            //           );
                            //           _actualizarCantidad(
                            //             _mobiliario,
                            //             originalIndex,
                            //             cantidad - 1,
                            //           );
                            //         }
                            //       : null,
                            //   icon: Icon(
                            //     Icons.remove_circle_outline,
                            //     color: cantidad > 0
                            //         ? AppColores.primary
                            //         : Colors.grey,
                            //   ),
                            // ),
                            // Text(
                            //   '$cantidad',
                            //   style: const TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 16,
                            //   ),
                            // ),
                            // IconButton(
                            //   onPressed: () {
                            //     final originalIndex = _mobiliario.indexOf(item);
                            //     _actualizarCantidad(
                            //       _mobiliario,
                            //       originalIndex,
                            //       cantidad + 1,
                            //     );
                            //   },
                            //   icon: const Icon(
                            //     Icons.add_circle_outline,
                            //     color: AppColores.primary,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipamientoLista() {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text(
                      'Filtrar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _tipoEquipamientoSeleccionado,
                        hint: const Text('Todos'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: 'todos',
                            child: Text('Todos'),
                          ),
                          ..._tiposEquipamiento.map(
                            (value) => DropdownMenuItem(
                              value: value['nombre'],
                              child: Text(value['nombre'] ?? ''),
                            ),
                          ),
                        ],
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _tipoEquipamientoSeleccionado = nuevoValor;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Catálogo de equipamiento:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _equipamientoFiltrado.length,
              itemBuilder: (context, index) {
                final item = _equipamientoFiltrado[index];
                final cantidad = item['cantidad'] as int;
                final yaSolicitado = item['ya_solicitado'] as bool? ?? false;

                String tipoNombre = '';
                final tipoId = item['tipo_equipa'];
                if (tipoId == 1)
                  tipoNombre = 'audio';
                else if (tipoId == 2)
                  tipoNombre = 'video';
                else if (tipoId == 3)
                  tipoNombre = 'iluminacion';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['nombre'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: yaSolicitado
                                            ? Colors.grey
                                            : AppColores.foreground,
                                      ),
                                    ),
                                  ),
                                  if (yaSolicitado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'x$cantidad',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                item['descripcion'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColores.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tipoNombre,
                                      style: const TextStyle(
                                        color: AppColores.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${item['costo'] ?? 0}',
                                    style: const TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            WidgetCantidadElementos(
                              cantidadActual: cantidad,
                              stockMaximo:
                                  item['stockDisponible'] ?? item['stock'] ?? 0,
                              onChange: (nuevaCantidad) {
                                final originalIndex = _equipamiento.indexOf(
                                  item,
                                );
                                _actualizarCantidad(
                                  _equipamiento,
                                  originalIndex,
                                  nuevaCantidad,
                                );
                              },
                            ),
                            // IconButton(
                            //   onPressed: cantidad > 0
                            //       ? () {
                            //           final originalIndex = _equipamiento
                            //               .indexOf(item);
                            //           _actualizarCantidad(
                            //             _equipamiento,
                            //             originalIndex,
                            //             cantidad - 1,
                            //           );
                            //         }
                            //       : null,
                            //   icon: Icon(
                            //     Icons.remove_circle_outline,
                            //     color: cantidad > 0
                            //         ? AppColores.primary
                            //         : Colors.grey,
                            //   ),
                            // ),
                            // Text(
                            //   '$cantidad',
                            //   style: const TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 16,
                            //   ),
                            // ),
                            // IconButton(
                            //   onPressed: () {
                            //     final originalIndex = _equipamiento.indexOf(
                            //       item,
                            //     );
                            //     _actualizarCantidad(
                            //       _equipamiento,
                            //       originalIndex,
                            //       cantidad + 1,
                            //     );
                            //   },
                            //   icon: const Icon(
                            //     Icons.add_circle_outline,
                            //     color: AppColores.primary,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiciosLista() {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text(
                      'Filtrar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _tipoServicioSeleccionado,
                        hint: const Text('Todos'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: 'todos',
                            child: Text('Todos'),
                          ),
                          ..._tiposServicio.map(
                            (value) => DropdownMenuItem(
                              value: value['id'].toString(),
                              child: Text(value['nombre'] ?? ''),
                            ),
                          ),
                        ],
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _tipoServicioSeleccionado = nuevoValor;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Catálogo de servicios:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _serviciosFiltrados.length,
              itemBuilder: (context, index) {
                final item = _serviciosFiltrados[index];
                final seleccionado = item['seleccionado'] as bool;
                final yaSolicitado = item['ya_solicitado'] as bool? ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: ListTile(
                    enabled: !yaSolicitado,
                    leading: Checkbox(
                      value: yaSolicitado ? true : seleccionado,
                      onChanged: yaSolicitado
                          ? null
                          : (value) {
                              final originalIndex = _servicios.indexOf(item);
                              _toggleServicio(originalIndex);
                            },
                      activeColor: AppColores.primary,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['nombre'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: yaSolicitado
                                  ? Colors.grey
                                  : AppColores.foreground,
                              decoration: yaSolicitado
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (yaSolicitado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Ya solicitado',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      item['descripcion'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Text(
                      '\$${item['costo'] ?? 0}',
                      style: const TextStyle(
                        color: AppColores.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
