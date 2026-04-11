import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'package:followroom_flutter/services/tipo_evento_service.dart';
import 'package:followroom_flutter/services/mobiliario_service.dart';
import 'package:followroom_flutter/services/servicio_service.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Pantalla para modificar una reservacion existente.
/// Recibe el JSON completo del API y devuelve los datos listos para PATCH.
class ModificarReservacionScreen extends StatefulWidget {
  final Map<String, dynamic> reservacion;

  const ModificarReservacionScreen({super.key, required this.reservacion});

  @override
  State<ModificarReservacionScreen> createState() =>
      _ModificarReservacionScreenState();
}

class _ModificarReservacionScreenState
    extends State<ModificarReservacionScreen> {
  // ─── Services ─────────────────────────────────────────────────────────────
  final TipoEventoService _tipoEventoService = TipoEventoService();
  final MobiliarioService _mobiliarioService = MobiliarioService();
  final ServicioService _servicioService = ServicioService();
  final ReservacionService _servicioReservacion = ReservacionService();

  late Future<List<dynamic>> _tiposEventos;

  // ─── Datos del evento ──────────────────────────────────────────────────────
  late final TextEditingController _nombreEventoController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _asistentesController;
  Map<String, dynamic>? _tipoEventoSeleccionado;

  // ─── Listas editables ─────────────────────────────────────────────────────
  late List<Map<String, dynamic>> _servicios;
  late List<Map<String, dynamic>> _mobiliarios;
  late List<Map<String, dynamic>> _equipamientos;

  // ─── Catálogos para agregar ───────────────────────────────────────────────
  List<Map<String, dynamic>> _catalogoMobiliarios = [];
  List<Map<String, dynamic>> _catalogoServicios = [];
  List<Map<String, dynamic>> _catalogoEquipamientos = [];
  bool _cargandoCatalogos = true;

  bool _hayCambios = false;

  // ─── Getters del JSON ─────────────────────────────────────────────────────
  Map<String, dynamic> get _salon =>
      (widget.reservacion['montaje']?['salon'] as Map<String, dynamic>?) ?? {};
  String get _nombreSalon => _salon['nombre'] ?? 'No definido';
  String get _fechaEvento => widget.reservacion['fechaEvento'] ?? 'No definida';
  String get _horario {
    final i = widget.reservacion['horaInicio'] ?? '';
    final f = widget.reservacion['horaFin'] ?? '';
    return (i.isEmpty && f.isEmpty) ? 'No definido' : '$i — $f';
  }

  @override
  void initState() {
    super.initState();
    _tiposEventos = _tipoEventoService.getTiposEventos();

    _nombreEventoController = TextEditingController(
      text: widget.reservacion['nombreEvento'] ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.reservacion['descripEvento'] ?? '',
    );
    _asistentesController = TextEditingController(
      text: widget.reservacion['estimaAsistentes']?.toString() ?? '',
    );
    _tipoEventoSeleccionado =
        widget.reservacion['tipo_evento'] as Map<String, dynamic>?;

    // Poblar listas desde el JSON
    _servicios = (widget.reservacion['reserva_servicio'] as List? ?? [])
        .map(
          (s) => {
            'id': s['servicio']?['id'] ?? s['id'],
            'nombre': s['servicio']?['nombre'] ?? '',
            'costo': s['servicio']?['costo'] ?? 0,
          },
        )
        .toList();

    _mobiliarios =
        ((widget.reservacion['montaje']?['montaje_mobiliario']) as List? ?? [])
            .map(
              (m) => {
                'id': m['mobiliario']?['id'] ?? m['id'],
                'nombre': m['mobiliario']?['nombre'] ?? '',
                'costo': m['mobiliario']?['costo'] ?? 0,
                'cantidad': m['cantidad'] ?? 1,
              },
            )
            .toList();

    _equipamientos = (widget.reservacion['reserva_equipa'] as List? ?? [])
        .map(
          (e) => {
            'id': e['equipamiento']?['id'] ?? e['id'],
            'nombre': e['equipamiento']?['nombre'] ?? '',
            'costo': e['equipamiento']?['costo'] ?? 0,
            'cantidad': e['cantidad'] ?? 1,
          },
        )
        .toList();

    for (final c in _controllers()) {
      c.addListener(_onCambio);
    }
    _cargarCatalogos();
  }

  List<TextEditingController> _controllers() => [
    _nombreEventoController,
    _descripcionController,
    _asistentesController,
  ];

  void _onCambio() {
    if (!_hayCambios) setState(() => _hayCambios = true);
  }

  Future<void> _cargarCatalogos() async {
    try {
      final results = await Future.wait([
        _mobiliarioService.getMobiliarios(),
        _servicioService.getServicios(),
        _loadEquipamientos(),
      ]);
      if (!mounted) return;
      setState(() {
        _catalogoMobiliarios = (results[0]).cast<Map<String, dynamic>>();
        _catalogoServicios = (results[1]).cast<Map<String, dynamic>>();
        _catalogoEquipamientos = (results[2]).cast<Map<String, dynamic>>();
        _cargandoCatalogos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoCatalogos = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadEquipamientos() async {
    final response = await http.get(
      Uri.parse('http://${IpConfig.ip}/api/equipamiento/'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data
          .map(
            (e) => {
              'id': e['id'],
              'nombre': e['nombre'] ?? '',
              'descripcion': e['descripcion'] ?? '',
              'costo': e['costo'] ?? 0,
              'stock': e['stock'] ?? 0,
            },
          )
          .toList();
    }
    throw Exception('Error al cargar equipamientos');
  }

  void onGuardar(Map<String, dynamic> datosParaApi) async {
    try {
      _servicioReservacion.modificarReservacion(
        widget.reservacion['id'],
        datosParaApi,
      );
    } catch (e) {
      print("Error en la conexion alal modificar reservacion: $e");
    }
  }

  @override
  void dispose() {
    for (final c in _controllers()) {
      c.removeListener(_onCambio);
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _datosParaApi() => {
    'nombreEvento': _nombreEventoController.text,
    'descripEvento': _descripcionController.text,
    'estimaAsistentes': int.tryParse(_asistentesController.text) ?? 0,
    'tipo_evento': _tipoEventoSeleccionado?['id'],
    'reserva_servicio': _servicios
        .map((s) => {'id': int.parse(s['id'].toString())})
        .toList(),
    'reserva_equipa': _equipamientos
        .map(
          (e) => {
            'id': int.parse(e['id'].toString()),
            'cantidad': int.parse(e['cantidad'].toString()),
          },
        )
        .toList(),
    'mobiliarios': _mobiliarios
        .map(
          (m) => {
            'id': int.parse(m['id'].toString()),
            'cantidad': int.parse(m['cantidad'].toString()),
          },
        )
        .toList(),
  };

  void _guardar() {
    onGuardar(_datosParaApi());
    Navigator.pop(context);
  }

  // ─── Helpers de cantidad ──────────────────────────────────────────────────
  void _actualizarCantidadMobiliario(int index, int cantidad) {
    setState(() {
      if (cantidad == 0) {
        _mobiliarios.removeAt(index);
      } else {
        _mobiliarios[index]['cantidad'] = cantidad;
      }
      _hayCambios = true;
    });
  }

  void _actualizarCantidadEquipamiento(int index, int cantidad) {
    setState(() {
      if (cantidad == 0) {
        _equipamientos.removeAt(index);
      } else {
        _equipamientos[index]['cantidad'] = cantidad;
      }
      _hayCambios = true;
    });
  }

  // ─── Bottom sheets para agregar ───────────────────────────────────────────
  void _mostrarDialogoAgregar({
    required String titulo,
    required List<Map<String, dynamic>> catalogo,
    required List<Map<String, dynamic>> seleccionados,
    required void Function(Map<String, dynamic> item) onAgregar,
  }) {
    final disponibles = catalogo
        .where((c) => !seleccionados.any((s) => s['id'] == c['id']))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColores.background2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(titulo, style: TextEstilos.subtitulos),
            ),
            Expanded(
              child: disponibles.isEmpty
                  ? const Center(child: Text('No hay más items disponibles'))
                  : ListView.builder(
                      controller: controller,
                      itemCount: disponibles.length,
                      itemBuilder: (_, i) {
                        final item = disponibles[i];
                        return ListTile(
                          title: Text(item['nombre'] ?? ''),
                          subtitle: Text('\$${item['costo']}'),
                          trailing: Icon(
                            Icons.add_circle,
                            color: AppColores.primary,
                          ),
                          onTap: () {
                            onAgregar(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Secciones de listas ──────────────────────────────────────────────────
  Widget _buildServiciosSeccion() {
    return _buildSeccion('Servicios', [
      if (_servicios.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sin servicios seleccionados',
            style: TextStyle(color: Colors.grey),
          ),
        )
      else
        ..._servicios.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['nombre'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${s['costo']}',
                        style: TextStyle(
                          color: AppColores.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() {
                    _servicios.removeAt(i);
                    _hayCambios = true;
                  }),
                ),
              ],
            ),
          );
        }),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _cargandoCatalogos
            ? null
            : () => _mostrarDialogoAgregar(
                titulo: 'Agregar servicio',
                catalogo: _catalogoServicios,
                seleccionados: _servicios,
                onAgregar: (item) => setState(() {
                  _servicios.add({
                    'id': item['id'],
                    'nombre': item['nombre'],
                    'costo': item['costo'],
                  });
                  _hayCambios = true;
                }),
              ),
        icon: Icon(Icons.add, color: AppColores.primary),
        label: Text(
          'Agregar servicio',
          style: TextStyle(color: AppColores.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColores.primary),
        ),
      ),
    ]);
  }

  Widget _buildMobiliariosSeccion() {
    return _buildSeccion('Mobiliarios', [
      if (_mobiliarios.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sin mobiliarios seleccionados',
            style: TextStyle(color: Colors.grey),
          ),
        )
      else
        ..._mobiliarios.asMap().entries.map((entry) {
          final i = entry.key;
          final mob = entry.value;
          final int cantidad = int.tryParse(mob['cantidad'].toString()) ?? 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mob['nombre'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${double.parse(mob['costo'].toString()) * cantidad}  (\$${mob['costo']} c/u)',
                        style: TextStyle(
                          color: AppColores.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCantidadControl(
                  cantidad,
                  (n) => _actualizarCantidadMobiliario(i, n),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() {
                    _mobiliarios.removeAt(i);
                    _hayCambios = true;
                  }),
                ),
              ],
            ),
          );
        }),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _cargandoCatalogos
            ? null
            : () => _mostrarDialogoAgregar(
                titulo: 'Agregar mobiliario',
                catalogo: _catalogoMobiliarios,
                seleccionados: _mobiliarios,
                onAgregar: (item) => setState(() {
                  _mobiliarios.add({
                    'id': item['id'],
                    'nombre': item['nombre'],
                    'costo': item['costo'],
                    'cantidad': 1,
                  });
                  _hayCambios = true;
                }),
              ),
        icon: Icon(Icons.add, color: AppColores.primary),
        label: Text(
          'Agregar mobiliario',
          style: TextStyle(color: AppColores.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColores.primary),
        ),
      ),
    ]);
  }

  Widget _buildEquipamientosSeccion() {
    return _buildSeccion('Equipamientos', [
      if (_equipamientos.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sin equipamientos seleccionados',
            style: TextStyle(color: Colors.grey),
          ),
        )
      else
        ..._equipamientos.asMap().entries.map((entry) {
          final i = entry.key;
          final eq = entry.value;
          final int cantidad = int.tryParse(eq['cantidad'].toString()) ?? 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eq['nombre'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${double.parse(eq['costo'].toString()) * cantidad}  (\$${eq['costo']} c/u)',
                        style: TextStyle(
                          color: AppColores.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCantidadControl(
                  cantidad,
                  (n) => _actualizarCantidadEquipamiento(i, n),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() {
                    _equipamientos.removeAt(i);
                    _hayCambios = true;
                  }),
                ),
              ],
            ),
          );
        }),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _cargandoCatalogos
            ? null
            : () => _mostrarDialogoAgregar(
                titulo: 'Agregar equipamiento',
                catalogo: _catalogoEquipamientos,
                seleccionados: _equipamientos,
                onAgregar: (item) => setState(() {
                  _equipamientos.add({
                    'id': item['id'],
                    'nombre': item['nombre'],
                    'costo': item['costo'],
                    'cantidad': 1,
                  });
                  _hayCambios = true;
                }),
              ),
        icon: Icon(Icons.add, color: AppColores.primary),
        label: Text(
          'Agregar equipamiento',
          style: TextStyle(color: AppColores.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColores.primary),
        ),
      ),
    ]);
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────
  Widget _buildCantidadControl(int cantidad, ValueChanged<int> onChange) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, color: AppColores.primary),
          onPressed: cantidad > 1 ? () => onChange(cantidad - 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$cantidad',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: AppColores.primary),
          onPressed: () => onChange(cantidad + 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextEstilos.indicador),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          decoration:
              createAppDecoration(
                hintText: value,
                prefixIcon: Icon(icon, color: Colors.grey),
              ).copyWith(
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.08),
              ),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Este campo no es editable',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String hintText = '',
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextEstilos.indicador),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLines: maxLines,
          decoration: createAppDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> campos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextEstilos.subtitulos),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: ContainerStyles.sombreado,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: campos,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      appBar: AppBar(
        title: const Text('Modificar Reservación'),
        backgroundColor: AppColores.background2,
        foregroundColor: AppColores.foreground,
        elevation: 0,
        actions: [
          if (_hayCambios)
            TextButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
              style: TextButton.styleFrom(foregroundColor: AppColores.primary),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Datos del evento ─────────────────────────────────────────
            _buildSeccion('Datos del evento', [
              _buildField(
                'Nombre del evento',
                _nombreEventoController,
                hintText: 'Ej. Lanzamiento de producto',
                icon: Icons.event,
              ),
              _buildField(
                'Descripción',
                _descripcionController,
                hintText: 'Describe el evento...',
                icon: Icons.notes,
                maxLines: 3,
              ),
              _buildField(
                'Cantidad de asistentes',
                _asistentesController,
                hintText: 'Número de personas',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              Text('Tipo de evento', style: TextEstilos.indicador),
              const SizedBox(height: 6),
              FutureBuilder<List<dynamic>>(
                future: _tiposEventos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DropdownButtonFormField(
                      initialValue: null,
                      items: const [],
                      onChanged: null,
                      decoration: createAppDecoration(hintText: 'Cargando...'),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  final tipos = (snapshot.data ?? [])
                      .map((t) => t as Map<String, dynamic>)
                      .toList();
                  final valorActual = tipos
                      .cast<Map<String, dynamic>?>()
                      .firstWhere(
                        (t) => t?['id'] == _tipoEventoSeleccionado?['id'],
                        orElse: () => null,
                      );
                  return DropdownButtonFormField<Map<String, dynamic>>(
                    initialValue: valorActual,
                    decoration: createAppDecoration(
                      hintText: 'Selecciona tipo',
                    ),
                    hint: const Text('Elige un tipo de evento'),
                    items: tipos
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t['nombre'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() {
                      _tipoEventoSeleccionado = val;
                      _hayCambios = true;
                    }),
                  );
                },
              ),
              const SizedBox(height: 14),
            ]),

            // ── Solo lectura ─────────────────────────────────────────────
            _buildSeccion('Salón y horario (no editables)', [
              _buildReadOnlyField(
                'Salón',
                _nombreSalon,
                Icons.meeting_room_outlined,
              ),
              _buildReadOnlyField(
                'Fecha del evento',
                _fechaEvento,
                Icons.calendar_today_outlined,
              ),
              _buildReadOnlyField(
                'Horario',
                _horario,
                Icons.access_time_outlined,
              ),
            ]),

            // ── Servicios, mobiliarios, equipamientos ────────────────────
            _buildServiciosSeccion(),
            _buildMobiliariosSeccion(),
            _buildEquipamientosSeccion(),

            // ── Botón guardar ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hayCambios ? _guardar : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Guardar cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
