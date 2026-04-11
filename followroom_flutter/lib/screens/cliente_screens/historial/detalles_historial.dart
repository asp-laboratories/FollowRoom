import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/encuesta_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/modificacino_reservacion.dart';

class DetallesHistorial extends StatefulWidget {
  final int idReservacion;

  const DetallesHistorial({super.key, required this.idReservacion});

  @override
  State<DetallesHistorial> createState() => _DetallesHistorialState();
}

class _DetallesHistorialState extends State<DetallesHistorial> {
  final ReservacionService _servicioReservacion = ReservacionService();
  final EncuestaService _servicioEncuesta = EncuestaService();

  bool _loading = true;
  bool _error = false;
  bool _encuestaEnviada = false;

  Map<String, dynamic> datosReservacion = {};

  int _calificacionPersonal = 0;
  int _calificacionEquipamiento = 0;
  int _calificacionServicios = 0;
  int _calificacionSalon = 0;
  int _calificacionMobiliario = 0;

  bool _esReservacionTerminada() {
    final estado = datosReservacion['estado_reserva']?['codigo'] ?? '';
    return estado == 'FINAL';
  }

  @override
  void initState() {
    super.initState();
    _cargarInfoReservacion();
  }

  Future<void> _cargarInfoReservacion() async {
    try {
      final datos = await _servicioReservacion.getDetalleReservacion(
        widget.idReservacion,
      );
      final voto = await _servicioEncuesta.verificarEncuestaExistente(
        widget.idReservacion,
      );
      setState(() {
        datosReservacion = datos;
        _loading = false;
        _encuestaEnviada = voto['realizada'] ?? false;
      });
    } catch (e) {
      print("Error al jalar la info de la reservacion: $e");
      setState(() {
        _loading = false;
        _error = true;
      });
    }
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
      await _servicioEncuesta.enviarEncuesta({
        'personal': _calificacionPersonal,
        'equipamiento': _calificacionEquipamiento,
        'servicios': _calificacionServicios,
        'salon': _calificacionSalon,
        'mobiliario': _calificacionMobiliario,
        'reservacion': widget.idReservacion,
      });

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
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    "Error al cargar la reservación.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Revisa la consola para más detalles.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 12.0,
                      percent: _progresoReservacion(),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(_progresoReservacion() * 100).toInt()}%",
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
                            datosReservacion['nombreEvento'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Fecha:",
                            datosReservacion['fechaEvento'] ?? 'No definida',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Horario:",
                            "${datosReservacion['horaInicio'] ?? "No definido"} - ${datosReservacion['horaFin'] ?? "No definido"}",
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de evento:",
                            datosReservacion['tipo_evento']?['nombre'] ??
                                'No seleccionado',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            datosReservacion['estimaAsistentes'].toString(),
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
                            datosReservacion['cliente']?['nombre'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Apellido:",
                            datosReservacion['cliente']?['apellidoPaterno'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Teléfono:",
                            datosReservacion['cliente']?['telefono'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Email:",
                            datosReservacion['cliente']?['correo_electronico'] ??
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
                      child: Builder(
                        builder: (context) {
                          final montaje = datosReservacion?['montaje'];
                          final salon = montaje?['salon'];
                          final tipoMontaje = montaje?['tipo_montaje'];

                          final mobiliarios =
                              montaje?['montaje_mobiliario'] ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Salón y Montaje",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (salon == null)
                                const Text("Ningún salón seleccionado")
                              else ...[
                                _buildLabelValue(
                                  "Salón:",
                                  salon['nombre'] ?? '',
                                ),
                                _buildLabelValue(
                                  "Precio:",
                                  "\$${salon['costo'] ?? '0'}",
                                ),
                                _buildLabelValue(
                                  "Montaje:",
                                  tipoMontaje?['nombre'] ?? 'No seleccionado',
                                ),

                                _buildMobiliarioLista(mobiliarios),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final servicios =
                          datosReservacion['reserva_servicio'] ?? [];
                      final equipos = datosReservacion['reserva_equipa'] ?? [];

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
                              _buildEquipamientosContainer(equipos),
                              SizedBox(height: 16),
                              _buildServiciosContainer(servicios),
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
                              child: _buildServiciosContainer(servicios),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildEquipamientosContainer(equipos),
                            ),
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
                  _buildBotoneditarReservacion(),
                ],
              ),
            ),
    );
  }

  Widget _buildServiciosContainer(List<dynamic> servicios) {
    return Container(
      width: double.infinity,
      decoration: ContainerStyles.sombreado,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Servicios",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (servicios.isEmpty)
            const Text(
              "Sin servicios",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            ...servicios.map((s) {
              final nombre = s['servicio']?['nombre'] ?? 'Servicio';
              final costo =
                  double.tryParse(s['servicio']?['costo']?.toString() ?? '0') ??
                  0;
              final bool esExtra = s['extra'] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "- $nombre",
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (esExtra) _buildBadgeExtra(),
                        ],
                      ),
                    ),
                    Text(
                      "\$$costo",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEquipamientosContainer(List<dynamic> equipos) {
    return Container(
      width: double.infinity,
      decoration: ContainerStyles.sombreado,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Equipamientos",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (equipos.isEmpty)
            const Text(
              "Sin equipos",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            ...equipos.map((e) {
              final nombre = e['equipamiento']?['nombre'] ?? 'Equipo';
              final cantidad = e['cantidad'] ?? 1;
              final costoUnitario =
                  double.tryParse(
                    e['equipamiento']?['costo']?.toString() ?? '0',
                  ) ??
                  0;
              final costoTotal = costoUnitario * cantidad;

              final bool esExtra = e['extra'] ?? false;
              final bool completado = e['completado'] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            completado
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 14,
                            color: completado ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "$nombre (x$cantidad)",
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (esExtra) _buildBadgeExtra(),
                        ],
                      ),
                    ),
                    Text(
                      "\$$costoTotal",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMobiliarioLista(List<dynamic> mobiliarios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        const Text(
          "Mobiliario Asignado:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (mobiliarios.isEmpty)
          const Text(
            "Sin mobiliario",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        else
          ...mobiliarios.map((m) {
            final nombre = m['mobiliario']?['nombre'] ?? 'Mobiliario';
            final cantidad = m['cantidad'] ?? 1;
            final bool esExtra = m['extra'] ?? false;
            final bool completado = m['completado'] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    completado
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14,
                    color: completado ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "$nombre (x$cantidad)",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (esExtra) _buildBadgeExtra(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBadgeExtra() {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "EXTRA",
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _buildBotoneditarReservacion() {
    final estado = datosReservacion['estado_reserva']?['codigo'] ?? '';
    if (!(estado == 'SOLIC' ||
        estado == 'PENDI' ||
        estado == 'PAGAD' ||
        estado == 'LIQUI')) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModificarReservacionScreen(
                  reservacion: datosReservacion,
                  // (Map<String, dynamic> datosActualizados) {},
                ),
              ),
            );
          },
          icon: Icon(Icons.rate_review),
          label: Text('Modificar reservacion:'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColores.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
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

  String _calcularSubtotal() {
    final valor =
        double.tryParse(datosReservacion['subtotal']?.toString() ?? '0') ?? 0.0;
    return valor.toStringAsFixed(2);
  }

  String _calcularIVA() {
    final valor =
        double.tryParse(datosReservacion['IVA']?.toString() ?? '0') ?? 0.0;
    return valor.toStringAsFixed(2);
  }

  String _calcularTotal() {
    final valor =
        double.tryParse(datosReservacion['total']?.toString() ?? '0') ?? 0.0;
    return valor.toStringAsFixed(2);
  }

  double _progresoReservacion() {
    if (datosReservacion.isEmpty) return 0.0;
    final estado = datosReservacion['estado_reserva']?['codigo'] ?? '';
    if (estado == 'SOLIC' || estado == 'CANCE') return 0.0;
    if (estado == 'FINAL') return 1.0;

    double progreso = 0.0;

    if (estado == 'LIQUI' || estado == 'ENPRO') {
      progreso = 0.30;
    } else if (estado == 'PAGAD') {
      progreso = 0.15;
    }

    final equipos = datosReservacion['reserva_equipa'] as List<dynamic>? ?? [];
    final mobiliarios =
        datosReservacion['montaje']?['montaje_mobiliario'] as List<dynamic>? ??
        [];

    int totalItems = equipos.length + mobiliarios.length;
    double progresoItems = 0.0;

    if (totalItems > 0) {
      int itemsCompletados = 0;
      for (var equipo in equipos) {
        if (equipo['completado'] == true) itemsCompletados++;
      }
      for (var mob in mobiliarios) {
        if (mob['completado'] == true) itemsCompletados++;
      }

      progresoItems = (itemsCompletados / totalItems) * 0.70;
    } else {
      progresoItems = 0.75;
    }
    double total = progreso + progresoItems;

    return total > 1.0 ? 1.0 : total;
  }
}
