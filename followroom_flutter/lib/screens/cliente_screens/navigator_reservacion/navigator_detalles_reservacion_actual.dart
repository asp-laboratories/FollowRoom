import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class DetallesReservacionActual extends StatefulWidget {
  final Map<String, dynamic>? reservacion;

  const DetallesReservacionActual({super.key, this.reservacion});

  @override
  State<DetallesReservacionActual> createState() =>
      _DetallesReservacionActualState();
}

class _DetallesReservacionActualState extends State<DetallesReservacionActual> {
  bool _cargando = true;
  Map<String, dynamic>? _reservacion;
  double _progreso = 0.75;
  bool _encuestaEnviada = false;
  int _calificacionPersonal = 3;
  int _calificacionEquipamiento = 3;
  int _calificacionServicios = 3;
  int _calificacionSalon = 3;
  int _calificacionMobiliario = 3;
  String _comentario = '';

  @override
  void initState() {
    super.initState();
    _cargarReservacion();
  }

  Future<void> _cargarReservacion() async {
    if (widget.reservacion != null) {
      setState(() {
        _reservacion = widget.reservacion;
        _cargando = false;
        _calcularProgreso();
      });
      return;
    }
    setState(() {
      _cargando = false;
    });
  }

  void _calcularProgreso() {
    if (_reservacion == null) return;

    final progresoReal = _reservacion!['progreso_checklist'];
    if (progresoReal != null &&
        progresoReal is num &&
        progresoReal.toDouble() > 0) {
      _progreso = progresoReal.toDouble();
      return;
    }

    final estado = _reservacion!['estado_reserva'];
    String codigo = '';
    if (estado is Map) {
      codigo = estado['codigo']?.toString() ?? '';
    }
    switch (codigo) {
      case 'SOLIC':
        _progreso = 0.25;
        break;
      case 'PEN':
        _progreso = 0.5;
        break;
      case 'CONF':
        _progreso = 0.75;
        break;
      case 'TERMI':
        _progreso = 1.0;
        break;
      case 'CANCEL':
        _progreso = 0.0;
        break;
      default:
        _progreso = 0.75;
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

  List<dynamic> _getList(dynamic data, String key) {
    if (data == null) return [];
    if (data is! Map) return [];
    final value = data[key];
    if (value is List) return value;
    return [];
  }

  Map<String, dynamic>? _getMap(dynamic data, String key) {
    if (data == null) return null;
    if (data is! Map) return null;
    final value = data[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cliente = _getMap(_reservacion, 'cliente_datos');
    final montageData = _getMap(_reservacion, 'montaje_datos');
    final salon = _getMap(montageData, 'salon');
    final tipoMontaje = _getMap(montageData, 'tipo_montaje');
    final tipoEvento = _getMap(_reservacion, 'tipo_evento_datos');
    final servicios = _getList(_reservacion, 'servicios');
    final equipamentos = _getList(_reservacion, 'equipamentos');
    final mobiliarios = _getList(_reservacion, 'mobiliarios');

    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Reservación'),
        backgroundColor: AppColores.background2,
      ),
      backgroundColor: AppColores.background2,
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: AppColores.primary.withValues(alpha: 0.1),
                    child: Column(
                      children: [
                        Text(
                          "Próxima reservación",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColores.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _reservacion?['nombreEvento'] ?? 'Sin título',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatearFecha(_reservacion?['fechaEvento']),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_reservacion?['horaInicio'] != null)
                          Text(
                            '${_formatearHora(_reservacion?['horaInicio'])} - ${_formatearHora(_reservacion?['horaFin'])}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: _progreso,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(_progreso * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColores.primary,
                            ),
                          ),
                          Text(
                            "Completado",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.grey.shade300,
                      progressColor: AppColores.primary,
                      circularStrokeCap: CircularStrokeCap.round,
                      arcType: ArcType.HALF,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
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
                              tipoEvento,
                              'nombre',
                              defaultValue: 'No seleccionado',
                            ),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            (_reservacion?['estimaAsistentes'] ?? 0).toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
                            "Nombre del contacto:",
                            _getValue(cliente, 'nombre'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Apellido del contacto:",
                            _getValue(cliente, 'apellidoPaterno'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Apellido materno:",
                            _getValue(cliente, 'apelidoMaterno'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue("RFC:", _getValue(cliente, 'rfc')),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Nombre fiscal:",
                            _getValue(cliente, 'nombre_fiscal'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Telefono:",
                            _getValue(cliente, 'telefono'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Colonia:",
                            _getValue(cliente, 'dir_colonia'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Calle:",
                            _getValue(cliente, 'dir_calle'),
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Numero:",
                            _getValue(cliente, 'dir_numero'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          if (salon == null)
                            Text("Ningún salón seleccionado")
                          else ...[
                            _buildLabelValue(
                              "Salón:",
                              _getValue(salon, 'nombre'),
                            ),
                            _buildLabelValue(
                              "Precio:",
                              "\$${_reservacion?['total'] ?? 0}",
                            ),
                            _buildLabelValue(
                              "Montaje:",
                              _getValue(
                                tipoMontaje,
                                'nombre',
                                defaultValue: 'No seleccionado',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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
                              _buildServiciosContainer(servicios),
                              SizedBox(height: 16),
                              _buildEquipamientosContainer(equipamentos),
                              SizedBox(height: 16),
                              _buildMobiliariosContainer(mobiliarios),
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
                                  _buildServiciosContainer(servicios),
                                  SizedBox(height: 16),
                                  _buildMobiliariosContainer(mobiliarios),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildEquipamientosContainer(equipamentos),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  Widget _buildServiciosContainer(List<dynamic> servicios) {
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
                  "\$${_sumList(servicios, 'servicio__costo')}",
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

  Widget _buildEquipamientosContainer(List<dynamic> equipos) {
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
                        "- ${e['equipamiento__nombre'] ?? 'Equipo'} (x${e['cantidad'] ?? 1})",
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
                  "\$${_sumListWithQuantity(equipos, 'equipamiento__costo', 'cantidad')}",
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

  Widget _buildMobiliariosContainer(List<dynamic> mobiliarios) {
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
          if (mobiliarios.isEmpty)
            Text("Sin mobiliarios", style: TextStyle(fontSize: 12))
          else
            ...mobiliarios.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${m['mobiliario__nombre'] ?? 'Mobiliario'} (x${m['cantidad'] ?? 1})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${m['mobiliario__costo'] ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (mobiliarios.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${_sumListWithQuantity(mobiliarios, 'mobiliario__costo', 'cantidad')}",
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

  int _sumList(List<dynamic> list, String key) {
    int total = 0;
    for (var item in list) {
      if (item is Map) {
        final value = item[key];
        if (value is num) {
          total += value.toInt();
        }
      }
    }
    return total;
  }

  int _sumListWithQuantity(List<dynamic> list, String costKey, String qtyKey) {
    int total = 0;
    for (var item in list) {
      if (item is Map) {
        final cost = item[costKey];
        final qty = item[qtyKey];
        if (cost is num && qty is num) {
          total += cost.toInt() * qty.toInt();
        } else if (cost is num) {
          total += cost.toInt();
        }
      }
    }
    return total;
  }

  // Métodos para encuesta
  bool get _esReservacionTerminada => _progreso >= 1.0;

  Widget _buildBotonEncuesta() {
    if (_progreso < 1.0 || _encuestaEnviada) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _mostrarEncuesta,
          icon: const Icon(Icons.rate_review),
          label: const Text('Calificar experiencia'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColores.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void _mostrarEncuesta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Califica tu experiencia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildRatingRow(
                'Personal',
                _calificacionPersonal,
                (v) => setState(() => _calificacionPersonal = v),
              ),
              _buildRatingRow(
                'Equipamiento',
                _calificacionEquipamiento,
                (v) => setState(() => _calificacionEquipamiento = v),
              ),
              _buildRatingRow(
                'Servicios',
                _calificacionServicios,
                (v) => setState(() => _calificacionServicios = v),
              ),
              _buildRatingRow(
                'Salón',
                _calificacionSalon,
                (v) => setState(() => _calificacionSalon = v),
              ),
              _buildRatingRow(
                'Mobiliario',
                _calificacionMobiliario,
                (v) => setState(() => _calificacionMobiliario = v),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentarios adicionales (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Escribe tu experiencia...',
                ),
                onChanged: (v) => _comentario = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviarEncuesta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          ...List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                i < value ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
              onPressed: () => onChanged(i + 1),
            ),
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
          'comentario': _comentario,
          'reservacion': _reservacion?['id'],
        },
      );
      if (mounted) {
        Navigator.pop(context);
        setState(() => _encuestaEnviada = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu opinión!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar encuesta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
