import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class TabTotalReservacion extends StatefulWidget {
  final Map<String, String> datosReservacion;
  final Map<String, String> datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<int, String> montajesPorSalon;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;

  const TabTotalReservacion({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.salonSeleccionado,
    required this.montajesPorSalon,
    required this.serviciosSeleccionados,
    required this.equipamientosSeleccionados,
  });

  @override
  State<TabTotalReservacion> createState() => _TabTotalReservacionState();
}

class _TabTotalReservacionState extends State<TabTotalReservacion> {
  int _calcularSubtotal() {
    int total = 0;

    if (widget.salonSeleccionado != null) {
      total += widget.salonSeleccionado!['precio'] as int? ?? 0;
    }

    for (var servicio in widget.serviciosSeleccionados) {
      total += servicio['precio'] as int? ?? 0;
    }

    for (var equipo in widget.equipamientosSeleccionados) {
      total +=
          (equipo['precio'] as int? ?? 0) * (equipo['cantidad'] as int? ?? 1);
    }

    return total;
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: AppColores.background2,
        ),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          "\$${((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)}",
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  int _calcularSubtotalServicios() {
    return widget.serviciosSeleccionados.fold<int>(
      0,
      (sum, s) => sum + ((s['precio'] ?? 0) as int),
    );
  }

  int _calcularSubtotalEquipamientos() {
    return widget.equipamientosSeleccionados.fold<int>(
      0,
      (sum, e) =>
          sum + (((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)),
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
