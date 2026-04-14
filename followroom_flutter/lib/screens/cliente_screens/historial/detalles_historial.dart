import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class DetallesHistorial extends StatefulWidget {
  final int idReservacion;
  final Map<String, String>? datosReservacion;
  final Map<String, String>? datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<int, String>? montajesPorSalon;
  final List<Map<String, dynamic>>? serviciosSeleccionados;
  final List<Map<String, dynamic>>? equipamientosSeleccionados;

  const DetallesHistorial({
    super.key,
    required this.idReservacion,
    this.datosReservacion,
    this.datosCliente,
    this.salonSeleccionado,
    this.montajesPorSalon,
    this.serviciosSeleccionados,
    this.equipamientosSeleccionados,
  });

  @override
  State<DetallesHistorial> createState() => _DetallesHistorialState();
}

class _DetallesHistorialState extends State<DetallesHistorial> {
  final ReservacionService _reservacionService = ReservacionService();
  bool _cargando = true;
  double _progreso = 0.0;
  bool _encuestaEnviada = false;
  Map<String, dynamic>? _reservacion;

  int _calificacionPersonal = 0;
  int _calificacionEquipamiento = 0;
  int _calificacionServicios = 0;
  int _calificacionSalon = 0;
  int _calificacionMobiliario = 0;

  @override
  void initState() {
    super.initState();
    _cargarReservacion();
  }

  Future<void> _cargarReservacion() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = 'http://${IpConfig.ip}/api';

      // Fetch both endpoints in parallel
      final results = await Future.wait([
        dio.get('/reservacion/${widget.idReservacion}/'),
        _reservacionService.getProgresoReservacion(widget.idReservacion),
      ]);

      final response = results[0] as dynamic;
      final progresoData = results[1] as Map<String, dynamic>;

      print('Progreso data: $progresoData');
      if (mounted) {
        setState(() {
          _reservacion = Map<String, dynamic>.from(response.data);
          _cargando = false;

          final progresoValor = progresoData['progreso_checklist'];
          if (progresoValor != null &&
              progresoValor is num &&
              progresoValor.toDouble() > 0) {
            _progreso = progresoValor.toDouble();
          } else {
            _progreso = 0.0;
          }

          if (_progreso > 1.0) _progreso = 1.0;
          if (_progreso < 0.0) _progreso = 0.0;
        });
      }
    } catch (e) {
      print('Error al cargar reservación: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  bool _esReservacionTerminada() {
    // Verifica por estado o por progreso 100%
    final progresoCompleto = _progreso >= 1.0;
    final estadoTerminado =
        _getValue(_reservacion?['estado_reserva_datos'], 'codigo') == 'CONF' ||
        _getValue(_reservacion?['estado_reserva_datos'], 'codigo') == 'TERMI';
    return estadoTerminado || progresoCompleto;
  }

  void _mostrarEncuesta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalEncuesta(),
    );
  }

  Widget _buildModalEncuesta() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Tu opinión nos importa',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Califica tu experiencia del 1 al 5',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 24),
                _buildPreguntaEncuesta('Personal', _calificacionPersonal, (v) {
                  setModalState(() => _calificacionPersonal = v);
                  setState(() {});
                }),
                _buildPreguntaEncuesta(
                  'Equipamiento',
                  _calificacionEquipamiento,
                  (v) {
                    setModalState(() => _calificacionEquipamiento = v);
                    setState(() {});
                  },
                ),
                _buildPreguntaEncuesta('Servicios', _calificacionServicios, (
                  v,
                ) {
                  setModalState(() => _calificacionServicios = v);
                  setState(() {});
                }),
                _buildPreguntaEncuesta('Salón', _calificacionSalon, (v) {
                  setModalState(() => _calificacionSalon = v);
                  setState(() {});
                }),
                _buildPreguntaEncuesta('Mobiliario', _calificacionMobiliario, (
                  v,
                ) {
                  setModalState(() => _calificacionMobiliario = v);
                  setState(() {});
                }),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _calificacionPersonal > 0 &&
                            _calificacionEquipamiento > 0 &&
                            _calificacionServicios > 0 &&
                            _calificacionSalon > 0 &&
                            _calificacionMobiliario > 0
                        ? _enviarEncuesta
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColores.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Enviar encuesta'),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreguntaEncuesta(
    String pregunta,
    int valor,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregunta,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final numero = index + 1;
              final isSelected = valor == numero;
              return GestureDetector(
                onTap: () => onChanged(numero),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColores.primary
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$numero',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarEncuesta() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = 'http://${IpConfig.ip}/api';

      await dio.post(
        '/encuesta/',
        data: {
          'personal': _calificacionPersonal,
          'equipamiento': _calificacionEquipamiento,
          'servicios': _calificacionServicios,
          'salon': _calificacionSalon,
          'mobiliario': _calificacionMobiliario,
          'reservacion': widget.idReservacion,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        setState(() => _encuestaEnviada = true);

        AnimatedSnackBar(
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '¡Gracias por tu opinión!',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar encuesta')));
      }
    }
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: AppColores.foreground),
          children: [
            TextSpan(
              text: "$label ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _getValue(
    dynamic data,
    String key, {
    String defaultValue = 'No definido',
  }) {
    if (data == null) return defaultValue;
    if (data is! Map) return defaultValue;
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is Map) return value['nombre']?.toString() ?? value.toString();
    return value.toString();
  }

  Map<String, dynamic>? _getMap(dynamic data, String key) {
    if (data == null) return null;
    if (data is! Map) return null;
    final value = data[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic> _getList(dynamic data, String key) {
    if (data == null) return [];
    if (data is int || data is double || data is String) return [];
    if (data is! Map) return [];
    final value = data[key];
    if (value is List) return value;
    return [];
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'No definida';
    try {
      final parts = fecha.split('-');
      if (parts.length == 3) {
        return '${parts[2]} de ${_mes(parts[1])} de ${parts[0]}';
      }
    } catch (e) {}
    return fecha;
  }

  String _formatearHora(String? hora) {
    if (hora == null) return '';
    try {
      final parts = hora.split(':');
      if (parts.length >= 2) {
        int h = int.parse(parts[0]);
        final m = parts[1];
        final period = h >= 12 ? 'PM' : 'AM';
        if (h > 12) h -= 12;
        if (h == 0) h = 12;
        return '$h:$m $period';
      }
    } catch (e) {}
    return hora;
  }

  String _mes(String m) {
    final meses = {
      '01': 'Enero',
      '02': 'Febrero',
      '03': 'Marzo',
      '04': 'Abril',
      '05': 'Mayo',
      '06': 'Junio',
      '07': 'Julio',
      '08': 'Agosto',
      '09': 'Septiembre',
      '10': 'Octubre',
      '11': 'Noviembre',
      '12': 'Diciembre',
    };
    return meses[m] ?? m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Reserva ${widget.idReservacion}'),
        backgroundColor: AppColores.background2,
      ),
      backgroundColor: AppColores.background2,
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 12.0,
                      percent: _progreso,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(_progreso * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColores.primary,
                            ),
                          ),
                          Text(
                            "Completado",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.grey.shade300,
                      progressColor: AppColores.primary,
                      circularStrokeCap: CircularStrokeCap.round,
                      arcType: ArcType.HALF,
                      arcBackgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Container(
                      decoration: ContainerStyles.sombreado,
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Datos de la Reservación",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildLabelValue(
                            "Nombre del evento:",
                            _reservacion?['nombreEvento'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Fecha:",
                            _formatearFecha(_reservacion?['fechaEvento']),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Horario:",
                            _reservacion?['horaInicio'] != null
                                ? '${_formatearHora(_reservacion?['horaInicio'])} - ${_formatearHora(_reservacion?['horaFin'])}'
                                : 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de evento:",
                            _getValue(
                              _reservacion?['tipo_evento_datos'],
                              'nombre',
                              defaultValue: 'No seleccionado',
                            ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            (_reservacion?['estimaAsistentes'] ?? 0).toString(),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Estado:",
                            _getValue(
                              _reservacion?['estado_reserva_datos'],
                              'nombre',
                              defaultValue: 'No definido',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: ContainerStyles.sombreado,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Datos del cliente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildLabelValue(
                            "Nombre:",
                            _getValue(
                                  _reservacion?['cliente_datos'],
                                  'nombre',
                                  defaultValue: 'No definido',
                                ) +
                                ' ' +
                                _getValue(
                                  _reservacion?['cliente_datos'],
                                  'apellidoPaterno',
                                  defaultValue: '',
                                ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Teléfono:",
                            _getValue(
                              _reservacion?['cliente_datos'],
                              'telefono',
                              defaultValue: 'No definido',
                            ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Email:",
                            _getValue(
                              _reservacion?['cliente_datos'],
                              'correo_electronico',
                              defaultValue: 'No definido',
                            ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "RFC:",
                            _getValue(
                              _reservacion?['cliente_datos'],
                              'rfc',
                              defaultValue: 'No definido',
                            ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Nombre fiscal:",
                            _getValue(
                              _reservacion?['cliente_datos'],
                              'nombre_fiscal',
                              defaultValue: 'No definido',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: ContainerStyles.sombreado,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Salón y Montaje",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (_getMap(_reservacion, 'montaje_datos') == null)
                            Text("Ningún salón seleccionado")
                          else ...[
                            _buildLabelValue(
                              "Salón:",
                              _getValue(
                                _getMap(
                                  _getMap(_reservacion, 'montaje_datos'),
                                  'salon',
                                ),
                                'nombre',
                                defaultValue: 'No definido',
                              ),
                            ),
                            _buildLabelValue(
                              "Precio:",
                              "\$${_reservacion?['total'] ?? 0}",
                            ),
                            _buildLabelValue(
                              "Montaje:",
                              _getValue(
                                _getMap(
                                  _getMap(_reservacion, 'montaje_datos'),
                                  'tipo_montaje',
                                ),
                                'nombre',
                                defaultValue: 'No seleccionado',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool esPantallaChica = constraints.maxWidth < 400;

                      if (esPantallaChica) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              _buildServiciosContainer(),
                              SizedBox(height: 16),
                              _buildEquipamientosContainer(),
                              SizedBox(height: 16),
                              _buildMobiliariosContainer(),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildServiciosContainer(),
                                  SizedBox(height: 16),
                                  _buildMobiliariosContainer(),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(child: _buildEquipamientosContainer()),
                          ],
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: ContainerStyles.sombreado,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total de la Reservación",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Subtotal:"),
                              Text("\$${_reservacion?['subtotal'] ?? 0}"),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("IVA (16%):"),
                              Text("\$${_reservacion?['IVA'] ?? 0}"),
                            ],
                          ),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$${_reservacion?['total'] ?? 0}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColores.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  _buildBotonEncuesta(),
                ],
              ),
            ),
    );
  }

  Widget _buildServiciosContainer() {
    final servicios = _getList(_reservacion, 'servicios');
    return Container(
      width: double.infinity,
      decoration: ContainerStyles.sombreado,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Servicios",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          if (servicios.isEmpty)
            Text("Sin servicios", style: TextStyle(fontSize: 12))
          else
            ...servicios.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${s['servicio__nombre'] ?? 'Servicio'}",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${s['servicio__costo'] ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (servicios.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${servicios.fold<num>(0, (sum, s) => sum + ((s['servicio__costo'] as num?)?.toInt() ?? 0))}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEquipamientosContainer() {
    final equipos = _getList(_reservacion, 'equipamentos');
    return Container(
      width: double.infinity,
      decoration: ContainerStyles.sombreado,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Equipamientos",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          if (equipos.isEmpty)
            Text("Sin equipos", style: TextStyle(fontSize: 12))
          else
            ...equipos.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${e['equipamiento__nombre'] ?? 'Equipo'} (x${e['cantidad']})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${e['equipamiento__costo'] ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (equipos.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${equipos.fold<num>(0, (sum, e) => sum + (((e['equipamiento__costo'] as num?)?.toInt() ?? 0) * ((e['cantidad'] as num?)?.toInt() ?? 1)))}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobiliariosContainer() {
    final mobiliariosList = _getList(
      _getMap(_reservacion, 'montaje_datos'),
      'montaje_mobiliario',
    );

    return Container(
      width: double.infinity,
      decoration: ContainerStyles.sombreado,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mobiliarios",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          if (mobiliariosList.isEmpty)
            Text("Sin mobiliarios", style: TextStyle(fontSize: 12))
          else
            ...mobiliariosList.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${m['nombre'] ?? 'Mobiliario'} (x${m['cantidad']})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${m['costo'] ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (mobiliariosList.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${mobiliariosList.fold<num>(0, (sum, m) => sum + ((m['costo'] as num?)?.toInt() ?? 0) * ((m['cantidad'] as num?)?.toInt() ?? 1))}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _calcularSubtotal() {
    return 1;
    // int serviciosTotal = 0;
    // int equiposTotal = 0;
    // int salonPrecio = _datosReservacion?['precioSalon'] as int? ?? 0;

    // if (_datosReservacion?['servicios'] != null) {
    //   serviciosTotal = (_datosReservacion?['servicios'] as List).fold(
    //     0,
    //     (sum, s) => sum + (s['precio'] as int),
    //   );
    // }

    // if (_datosReservacion?['equipos'] != null) {
    //   equiposTotal = (_datosReservacion?['equipos'] as List).fold(
    //     0,
    //     (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)),
    //   );
    // }

    // return serviciosTotal + equiposTotal + salonPrecio;
  }

  Widget _buildBotonEncuesta() {
    if (!_esReservacionTerminada() || _encuestaEnviada) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _mostrarEncuesta,
          icon: Icon(Icons.rate_review),
          label: Text('Calificar experiencia'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColores.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }
}
