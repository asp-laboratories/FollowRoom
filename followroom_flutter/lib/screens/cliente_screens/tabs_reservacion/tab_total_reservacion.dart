import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class TabTotalReservacion extends StatefulWidget {
  final Map<String, String> datosReservacion;
  final Map<String, String> datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<int, String> montajesPorSalon;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;
  final List<Map<String, dynamic>> mobiliariosSeleccionados;
  final VoidCallback? onReservacionEnviada;

  const TabTotalReservacion({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.salonSeleccionado,
    required this.montajesPorSalon,
    required this.serviciosSeleccionados,
    required this.equipamientosSeleccionados,
    required this.mobiliariosSeleccionados,
    this.onReservacionEnviada,
  });

  @override
  State<TabTotalReservacion> createState() => _TabTotalReservacionState();
}

class _TabTotalReservacionState extends State<TabTotalReservacion> {
  int _calcularSubtotal() {
    int total = 0;

    if (widget.salonSeleccionado != null) {
      total += (widget.salonSeleccionado!['precio'] as num?)?.toInt() ?? 0;
    }

    for (var servicio in widget.serviciosSeleccionados) {
      total += (servicio['precio'] as num?)?.toInt() ?? 0;
    }

    for (var equipo in widget.equipamientosSeleccionados) {
      total +=
          ((equipo['precio'] as num?)?.toInt() ?? 0) *
          ((equipo['cantidad'] as num?)?.toInt() ?? 1);
    }

    for (var mob in widget.mobiliariosSeleccionados) {
      total +=
          ((mob['precio'] as num?)?.toInt() ?? 0) *
          ((mob['cantidad'] as num?)?.toInt() ?? 1);
    }

    return total;
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }

  String? validarReservacion() {
    // Validar datos del evento
    if (widget.datosReservacion['nombre'] == null ||
        widget.datosReservacion['nombre']!.isEmpty) {
      return "El nombre del evento es requerido";
    }
    if (widget.datosReservacion['fecha'] == null ||
        widget.datosReservacion['fecha']!.isEmpty) {
      return "La fecha del evento es requerida";
    }
    if (widget.datosReservacion['horario'] == null ||
        widget.datosReservacion['horario']!.isEmpty) {
      return "El horario del evento es requerido";
    }
    if (widget.datosReservacion['tipo'] == null ||
        widget.datosReservacion['tipo']!.isEmpty) {
      return "El tipo de evento es requerido";
    }
    if (widget.datosReservacion['asistentes'] == null ||
        widget.datosReservacion['asistentes']!.isEmpty) {
      return "El número de asistentes es requerido";
    }

    // Validar fecha no sea anterior a hoy
    final fechaStr = widget.datosReservacion['fecha'];
    if (fechaStr != null && fechaStr.isNotEmpty) {
      try {
        DateTime fechaEvento;
        if (fechaStr.contains('/')) {
          final partes = fechaStr.split('/');
          if (partes.length == 3) {
            final day = int.parse(partes[0]);
            final month = int.parse(partes[1]);
            final year = int.parse(partes[2]);
            fechaEvento = DateTime(year, month, day);
          } else {
            return "Formato de fecha inválido";
          }
        } else {
          fechaEvento = DateTime.parse(fechaStr);
        }
        final fechaActual = DateTime.now();
        final fechaHoy = DateTime(
          fechaActual.year,
          fechaActual.month,
          fechaActual.day,
        );
        if (fechaEvento.isBefore(fechaHoy)) {
          return "No se puede seleccionar una fecha anterior a hoy";
        }
      } catch (e) {
        return "Formato de fecha inválido";
      }
    }

    // Validar datos del cliente
    if (widget.datosCliente['nombre'] == null ||
        widget.datosCliente['nombre']!.isEmpty) {
      return "El nombre del cliente es requerido";
    }
    if (widget.datosCliente['apellidoPaterno'] == null ||
        widget.datosCliente['apellidoPaterno']!.isEmpty) {
      return "El apellido paterno del cliente es requerido";
    }
    if (widget.datosCliente['telefono'] == null ||
        widget.datosCliente['telefono']!.isEmpty) {
      return "El teléfono del cliente es requerido";
    }

    // Validar salón seleccionado
    if (widget.salonSeleccionado == null) {
      return "Debe seleccionar un salón";
    }

    // Validar montaje seleccionado
    final salonId = widget.salonSeleccionado!['id'];
    final montaje = widget.montajesPorSalon[salonId];
    if (montaje == null || montaje.isEmpty) {
      return "Debe seleccionar un montaje";
    }

    // Validar mobiliarios seleccionados
    if (widget.mobiliariosSeleccionados.isEmpty) {
      return "Debe seleccionar al menos un mobiliario";
    }

    return null; // Todo válido
  }

  Future<void> _enviarReservacion() async {
    final error = validarReservacion();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final salonId = widget.salonSeleccionado!['id'];
    final montagemId = widget.montajesPorSalon[salonId] != null
        ? salonId
        : null;

    final service = ReservacionService();
    final success = await service.crearReservacion(
      datosReservacion: widget.datosReservacion,
      datosCliente: widget.datosCliente,
      salonId: salonId,
      montageId: montagemId,
      servicios: widget.serviciosSeleccionados,
      equipamentos: widget.equipamientosSeleccionados,
      mobiliarios: widget.mobiliariosSeleccionados,
    );

    if (mounted) {
      Navigator.pop(context); // Quitar loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reservación enviada exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
        widget.onReservacionEnviada?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar la reservación"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      "Desglose de Precios",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),

                    if (widget.salonSeleccionado != null) ...[
                      _buildPriceRow(
                        "Salón: ${widget.salonSeleccionado!['nombre']}",
                        "\$${widget.salonSeleccionado!['precio']}",
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
                          "\$${s['precio']}",
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
                          "\$${((e['precio'] as num?)?.toInt() ?? 0) * ((e['cantidad'] as num?)?.toInt() ?? 1)}",
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildPriceRow(
                        "Subtotal Equipamientos",
                        "\$${_calcularSubtotalEquipamientos()}",
                        isBold: true,
                      ),
                    ],

                    if (widget.mobiliariosSeleccionados.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        "Mobiliarios:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColores.foreground,
                        ),
                      ),
                      ...widget.mobiliariosSeleccionados.map(
                        (m) => _buildPriceRow(
                          "- ${m['nombre']} (x${m['cantidad'] ?? 1})",
                          "\$${((m['precio'] as num?)?.toInt() ?? 0) * ((m['cantidad'] as num?)?.toInt() ?? 1)}",
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildPriceRow(
                        "Subtotal Mobiliarios",
                        "\$${_calcularSubtotalMobiliarios()}",
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
                    final error = validarReservacion();
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
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
                              Navigator.pop(context);
                              _enviarReservacion();
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

  int _calcularSubtotalServicios() {
    return widget.serviciosSeleccionados.fold<int>(
      0,
      (sum, s) => sum + ((s['precio'] as num?)?.toInt() ?? 0),
    );
  }

  int _calcularSubtotalEquipamientos() {
    return widget.equipamientosSeleccionados.fold<int>(
      0,
      (sum, e) =>
          sum +
          (((e['precio'] as num?)?.toInt() ?? 0) *
              ((e['cantidad'] as num?)?.toInt() ?? 1)),
    );
  }

  int _calcularSubtotalMobiliarios() {
    return widget.mobiliariosSeleccionados.fold<int>(
      0,
      (sum, m) =>
          sum +
          (((m['precio'] as num?)?.toInt() ?? 0) *
              ((m['cantidad'] as num?)?.toInt() ?? 1)),
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
