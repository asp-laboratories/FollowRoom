import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }
}
