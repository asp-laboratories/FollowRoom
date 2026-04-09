import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class TabTotalReservacion extends StatefulWidget {
  final Map<String, dynamic>? datosPaquete;
  final Map<String, dynamic> datosReservacion;
  final Map<String, String> datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<String, dynamic> montajesPorSalon;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;
  final List<Map<String, dynamic>> mobiliariosSeleccionados;

  const TabTotalReservacion({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.salonSeleccionado,
    required this.montajesPorSalon,
    required this.serviciosSeleccionados,
    required this.equipamientosSeleccionados,
    required this.mobiliariosSeleccionados,
    this.datosPaquete,
  });

  @override
  State<TabTotalReservacion> createState() => _TabTotalReservacionState();
}

class _TabTotalReservacionState extends State<TabTotalReservacion> {
  final ReservacionService _servicioReservaciones = ReservacionService();

  Map<String, dynamic> _datosFinalesParaEnviar() {

    final List<Map> idsServicios = widget.serviciosSeleccionados
        .map((servicio) => {"id": int.parse(servicio['id'].toString())})
        .toList();

    final List<Map<String, int>> equipos = widget.equipamientosSeleccionados
        .map((equipo) {
          return {
            "id": int.parse(equipo['id'].toString()),
            "cantidad": int.parse(equipo['cantidad'].toString()),
          };
        })
        .toList();

    final List<Map<String, int>> mobiliarios = widget.mobiliariosSeleccionados
        .map((mobilairio) {
          return {
            "id": int.parse(mobilairio['id'].toString()),
            "cantidad": int.parse(mobilairio['cantidad'].toString()),
          };
        })
        .toList();

    final Map<String, dynamic> datosEnviar = {
      "nombre": widget.datosReservacion['nombre'],
      "descripEvento": widget.datosReservacion['descripEvento'],
      "estimaAsistentes": int.parse(
        widget.datosReservacion['estimaAsistentes'].toString(),
      ),
      "fechaEvento": widget.datosReservacion['fechaEvento'],
      "horaInicio": widget.datosReservacion['horaInicio'],
      "horaFin": widget.datosReservacion['horaFin'],
      "cliente": widget.datosCliente['rfc'],
      "estado_reserva": 'SOLIC',
      "reserva_servicio": idsServicios,
      "reserva_equipa": equipos,
      "montaje": {
        "salon": int.parse(widget.salonSeleccionado!['id'].toString()),
        "tipo_montaje": int.parse(widget.montajesPorSalon['id'].toString()),
        "mobiliarios": mobiliarios,
      },
      "tipo_evento": int.parse(
        widget.datosReservacion['tipo_evento']['id'].toString(),
      ),
    };

    if (_paqueteOriginal) {
      datosEnviar['subtotal'] = _calcularSubtotal();
      datosEnviar['es_paquete'] = true;
    }

    return datosEnviar;
  }

  bool get _paqueteOriginal {
    if (widget.datosPaquete == null || widget.datosPaquete!.isEmpty) {
      return false;
    }

    if (widget.salonSeleccionado == null) return false;

    final montajeOg = widget.datosPaquete!['montaje'];
    if (montajeOg == null) return false;

    final idSalonOg = montajeOg['salon']['id'];

    final idSalonAc = widget.salonSeleccionado!['id'];

    return idSalonOg == idSalonAc;
  }

  void _registrarReservacion() async {
    Map<String, dynamic> info = _datosFinalesParaEnviar();

    try {
      final resultad = await _servicioReservaciones.crearReservacion(info);

      print("Reservacion hecha con el id: ${resultad.data['id']}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  double _calcularSubtotal() {
    double total = 0;

    if (_paqueteOriginal) {
      total +=
          double.tryParse(
            widget.datosPaquete!['subtotal']?.toString() ?? '0',
          ) ??
          0;
    } else if (widget.salonSeleccionado != null) {
      total += double.parse(widget.salonSeleccionado!['costo'].toString());
    }

    for (var servicio in widget.serviciosSeleccionados) {
      total += double.parse(servicio['costo'].toString());
    }

    for (var equipo in widget.equipamientosSeleccionados) {
      total +=
          (double.parse(equipo['costo'].toString()) *
          ((equipo['cantidad'] ?? 1) as num));
    }

    for (var mobiliario in widget.mobiliariosSeleccionados) {
      total +=
          (double.parse((mobiliario['costo'] ?? 0).toString()) *
          (mobiliario['cantidad'] as num));
    }

    return total;
  }

  double _calcularIVA() {
    return (_calcularSubtotal() * 0.16);
  }

  double _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Desglose de costos",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_paqueteOriginal) ...[
                      _buildPriceRow(
                        "Precio paquete: ${widget.datosPaquete!['nombreEvento'] ?? 'Plantilla'}",
                        "\$${widget.datosPaquete!['subtotal'] ?? '0.00'}",
                      ),
                    ] else if (widget.salonSeleccionado != null) ...[
                      _buildPriceRow(
                        "Salón: ${widget.salonSeleccionado!['nombre']}",
                        "\$${widget.salonSeleccionado!['costo']}",
                      ),
                      if (widget.datosPaquete != null &&
                          widget.datosPaquete!.isNotEmpty)
                        Text(
                          "* Se ha modificado el salon del paquete orignial. Se aplicaran los precios bases individuales. *",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],

                    if (widget.mobiliariosSeleccionados.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        "Mobiliarios: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColores.foreground,
                        ),
                      ),
                      ...widget.mobiliariosSeleccionados.map(
                        (mob) => _buildPriceRow(
                          "- ${mob["nombre"]} (x${mob['cantidad'] ?? 1})",
                          "\$${double.parse((mob['costo'] ?? 0).toString()) * ((mob['cantidad'] ?? 1) as num)}",
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildPriceRow(
                        "Subtotal Mobiliarios",
                        "\$${_calcularSubtotalMobiliarios()}",
                        isBold: true,
                      ),
                    ],

                    if (widget.serviciosSeleccionados.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        "Servicios:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColores.foreground,
                        ),
                      ),
                      ...widget.serviciosSeleccionados.map(
                        (s) => _buildPriceRow(
                          "- ${s['nombre']}",
                          "\$${s['costo']}",
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildPriceRow(
                        "Subtotal Servicios",
                        "\$${_calcularSubtotalServicios()}",
                        isBold: true,
                      ),
                    ],

                    if (widget.equipamientosSeleccionados.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        "Equipamientos:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColores.foreground,
                        ),
                      ),
                      ...widget.equipamientosSeleccionados.map(
                        (e) => _buildPriceRow(
                          "- ${e['nombre']} (x${e['cantidad'] ?? 1})",
                          "\$${double.parse((e['costo'] ?? 0).toString()) * ((e['cantidad'] ?? 1) as num)}",
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildPriceRow(
                        "Subtotal Equipamientos",
                        "\$${_calcularSubtotalEquipamientos()}",
                        isBold: true,
                      ),
                    ],

                    Divider(height: 24),

                    _buildPriceRow(
                      "Subtotal",
                      "\$${_calcularSubtotal()}",
                      isBold: true,
                    ),
                    SizedBox(height: 4),
                    _buildPriceRow("IVA (16%)", "\$${_calcularIVA()}"),
                    Divider(height: 24),
                    _buildPriceRow(
                      "Total",
                      "\$${_calcularTotal()}",
                      isBold: true,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Información de Pago",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Métodos de pago disponibles:",
                      style: TextStyle(color: AppColores.foreground),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.credit_card, color: AppColores.primary),
                        SizedBox(width: 8),
                        Text(
                          "Tarjeta de crédito/débito",
                          style: TextStyle(color: AppColores.foreground),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.account_balance, color: AppColores.primary),
                        SizedBox(width: 8),
                        Text(
                          "Transferencia bancaria",
                          style: TextStyle(color: AppColores.foreground),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.money_off, color: AppColores.primary),
                        SizedBox(width: 8),
                        Text(
                          "Efectivo",
                          style: TextStyle(color: AppColores.foreground),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirmar Reservación"),
                        content: Text(
                          "¿Está seguro de confirmar su reservación?\n\n"
                          "Total a pagar: \$${_calcularTotal()}\n\n"
                          "Se enviará un correo de confirmación.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _registrarReservacion();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Reservación confirmada exitosamente",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColores.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Confirmar"),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Confirmar Reservación",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double _calcularSubtotalServicios() {
    return widget.serviciosSeleccionados.fold<double>(
      0,
      (sum, s) => sum + double.parse((s['costo'] ?? 0).toString()),
    );
  }

  double _calcularSubtotalEquipamientos() {
    return widget.equipamientosSeleccionados.fold<double>(
      0,
      (sum, e) =>
          sum +
          (double.parse((e['costo'] ?? 0).toString()) *
              ((e['cantidad'] ?? 1) as num)),
    );
  }

  double _calcularSubtotalMobiliarios() {
    return widget.mobiliariosSeleccionados.fold<double>(
      0,
      (sum, mob) =>
          sum +
          (double.parse((mob['costo'] ?? 0).toString()) *
              ((mob['cantidad'] ?? 1) as num)),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 18 : 14,
                color: isTotal ? AppColores.primary : AppColores.foreground,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? AppColores.primary : AppColores.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
