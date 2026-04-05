import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class DetallesHistorial extends StatefulWidget {
  final String idReservacion;
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
  final bool _cargando = false;
  final double _progreso = 0.75;
  bool _encuestaEnviada = false;

  int _calificacionPersonal = 0;
  int _calificacionEquipamiento = 0;
  int _calificacionServicios = 0;
  int _calificacionSalon = 0;
  int _calificacionMobiliario = 0;

  bool _esReservacionTerminada() {
    final estado = widget.datosReservacion?['estado']?.toLowerCase() ?? '';
    return estado == 'concluido' ||
        estado == 'finalizado' ||
        estado == 'finalizada' ||
        estado == 'terminado';
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
          'reservacion': int.tryParse(widget.idReservacion) ?? 0,
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
                            widget.datosReservacion?['nombre'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Fecha:",
                            widget.datosReservacion?['fecha'] ?? 'No definida',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Horario:",
                            widget.datosReservacion?['horario'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de evento:",
                            widget.datosReservacion?['tipo'] ??
                                'No seleccionado',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            widget.datosReservacion?['asistentes'] ?? '0',
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
                            widget.datosCliente?['nombre'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Apellido:",
                            widget.datosCliente?['apellidoPaterno'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Teléfono:",
                            widget.datosCliente?['telefono'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Email:",
                            widget.datosCliente?['correoElectronico'] ??
                                'No definido',
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
                          if (widget.salonSeleccionado == null)
                            Text("Ningún salón seleccionado")
                          else ...[
                            _buildLabelValue(
                              "Salón:",
                              widget.salonSeleccionado!['nombre'].toString(),
                            ),
                            _buildLabelValue(
                              "Precio:",
                              "\$${widget.salonSeleccionado!['precio']}",
                            ),
                            _buildLabelValue(
                              "Montaje:",
                              widget.montajesPorSalon?[widget
                                      .salonSeleccionado!['id']] ??
                                  'No seleccionado',
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
                            Expanded(child: _buildServiciosContainer()),
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
                              Text("\$${_calcularSubtotal()}"),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("IVA (16%):"),
                              Text("\$${_calcularIVA()}"),
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
                                "\$${_calcularTotal()}",
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
    final servicios = widget.serviciosSeleccionados ?? [];
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
                        "- ${s['nombre']}",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${s['precio']}",
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
                  "\$${servicios.fold(0, (sum, s) => sum + (s['precio'] as int))}",
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
    final equipos = widget.equipamientosSeleccionados ?? [];
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
                        "- ${e['nombre']} (x${e['cantidad']})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${(e['precio'] as int) * (e['cantidad'] as int)}",
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
                  "\$${equipos.fold<int>(0, (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)))}",
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
