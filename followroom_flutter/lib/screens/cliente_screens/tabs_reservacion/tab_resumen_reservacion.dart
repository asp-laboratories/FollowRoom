import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabResumen extends StatefulWidget {
  final Map<String, String> datosReservacion;
  final Map<String, String> datosCliente;
  final String? montajeSeleccionado;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;

  const TabResumen({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.montajeSeleccionado,
    required this.serviciosSeleccionados,
    required this.equipamientosSeleccionados,
  });

  @override
  State<TabResumen> createState() => _TabResumenState();
}

class _TabResumenState extends State<TabResumen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColores.secundary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Datos de la Reservación",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Nombre del evento: ${widget.datosReservacion['nombre'] ?? 'No definido'}",
                ),
                Text(
                  "Fecha: ${widget.datosReservacion['fecha'] ?? 'No definida'}",
                ),
                Text(
                  "Horario: ${widget.datosReservacion['horario'] ?? 'No definido'}",
                ),
                Text(
                  "Tipo de evento: ${widget.datosReservacion['tipo'] ?? 'No seleccionado'}",
                ),
                Text(
                  "Asistentes: ${widget.datosReservacion['asistentes'] ?? '0'}",
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColores.secundary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Datos del cliente",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Nombre del contacto: ${widget.datosCliente['nombre'] ?? 'No definido'}",
                ),
                Text(
                  "Apellido del contacto: ${widget.datosCliente['apellidoPaterno'] ?? 'No definido'}",
                ),
                Text(
                  "Apellido materno del contacto: ${widget.datosCliente['apellidoMaterno'] ?? 'No definido'}",
                ),
                Text("RFC: ${widget.datosReservacion['rfc'] ?? 'No definido'}"),
                Text(
                  "Nombre fiscal: ${widget.datosCliente['nombreFiscal'] ?? 'No definido'}",
                ),
                Text(
                  "Telefono del contacto: ${widget.datosCliente['telefono'] ?? 'No definido'}",
                ),
                Text(
                  "Correo electronico del contacto: ${widget.datosCliente['correoElectronico'] ?? 'No definido'}",
                ),
                Text(
                  "Colonia: ${widget.datosCliente['colonia'] ?? 'No definido'}",
                ),

                Text(
                  "Calle: ${widget.datosCliente['calle'] ?? 'No definido'}",
                ),
                Text(
                  "Numero: ${widget.datosCliente['numero'] ?? 'No definido'}",
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColores.secundary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Montaje Seleccionado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  widget.montajeSeleccionado ?? "Ningún montaje seleccionado",
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: AppColores.secundary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Servicios seleccionados",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (widget.serviciosSeleccionados.isEmpty)
                          Text("Ningún servicio seleccionado")
                        else
                          ...widget.serviciosSeleccionados.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("- ${s['nombre']}"),
                                  Text(
                                    "\$${s['precio']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.serviciosSeleccionados.isNotEmpty) ...[
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total servicios:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$${widget.serviciosSeleccionados.fold(0, (sum, s) => sum + (s['precio'] as int))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: AppColores.secundary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Equipamientos",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (widget.equipamientosSeleccionados.isEmpty)
                          Text("Ningún equipamiento")
                        else
                          ...widget.equipamientosSeleccionados.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("- ${e['nombre']} (x${e['cantidad']})"),
                                  Text(
                                    "\$${(e['precio'] as int) * (e['cantidad'] as int)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.equipamientosSeleccionados.isNotEmpty) ...[
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$${widget.equipamientosSeleccionados.fold<int>(0, (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
