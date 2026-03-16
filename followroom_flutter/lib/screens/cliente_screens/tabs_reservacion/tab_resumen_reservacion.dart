import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class TabResumen extends StatefulWidget {
  final Map<String, String> datosReservacion;
  final Map<String, String> datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<int, String> montajesPorSalon;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;

  const TabResumen({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.salonSeleccionado,
    required this.montajesPorSalon,
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
                      "Datos de la Reservación",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nombre del evento: ${widget.datosReservacion['nombre'] ?? 'No definido'}",
                    ),
                    SizedBox(height: 5),
        
                    Text(
                      "Fecha: ${widget.datosReservacion['fecha'] ?? 'No definida'}",
                    ),
                    SizedBox(height: 5),
        
                    Text(
                      "Horario: ${widget.datosReservacion['horario'] ?? 'No definido'}",
                    ),
                    SizedBox(height: 5),
        
                    Text(
                      "Tipo de evento: ${widget.datosReservacion['tipo'] ?? 'No seleccionado'}",
                    ),
                    SizedBox(height: 5),
        
                    Text(
                      "Asistentes: ${widget.datosReservacion['asistentes'] ?? '0'}",
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
        
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: ContainerStyles.sombreado,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      Text(
                        "Nombre del contacto: ${widget.datosCliente['nombre'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Apellido del contacto: ${widget.datosCliente['apellidoPaterno'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Apellido materno del contacto: ${widget.datosCliente['apellidoMaterno'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "RFC: ${widget.datosReservacion['rfc'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Nombre fiscal: ${widget.datosCliente['nombreFiscal'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Telefono del contacto: ${widget.datosCliente['telefono'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Correo electronico del contacto: ${widget.datosCliente['correoElectronico'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Colonia: ${widget.datosCliente['colonia'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Calle: ${widget.datosCliente['calle'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
        
                      Text(
                        "Numero: ${widget.datosCliente['numero'] ?? 'No definido'}",
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
        
            SizedBox(height: 10),
        
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: ContainerStyles.sombreado,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Salón y Montaje",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    if (widget.salonSeleccionado == null)
                      Text("Ningún salón seleccionado")
                    else ...[
                      Text("Salón: ${widget.salonSeleccionado!['nombre']}"),
                      Text("Precio: \$${widget.salonSeleccionado!['precio']}"),
                      Text(
                        "Montaje: ${widget.montajesPorSalon[widget.salonSeleccionado!['id']] ?? 'No seleccionado'}",
                      ),
                    ],
                  ],
                ),
              ),
            ),
        
            SizedBox(height: 10),
        
            LayoutBuilder(
              builder: (context, constraints) {
                final bool esPantallaChica = constraints.maxWidth < 400;
        
                if (esPantallaChica) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildServiciosContainer(),
                        SizedBox(height: 10),
                        _buildEquipamientosContainer(),
                      ],
                    ),
                  );
                }
        
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildServiciosContainer()),
                      SizedBox(width: 8),
                      Expanded(child: _buildEquipamientosContainer()),
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

  Widget _buildServiciosContainer() {
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
          if (widget.serviciosSeleccionados.isEmpty)
            Text("Sin servicios", style: TextStyle(fontSize: 12))
          else
            ...widget.serviciosSeleccionados.map(
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
          if (widget.serviciosSeleccionados.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${widget.serviciosSeleccionados.fold(0, (sum, s) => sum + (s['precio'] as int))}",
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
          if (widget.equipamientosSeleccionados.isEmpty)
            Text("Sin equipos", style: TextStyle(fontSize: 12))
          else
            ...widget.equipamientosSeleccionados.map(
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
          if (widget.equipamientosSeleccionados.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${widget.equipamientosSeleccionados.fold<int>(0, (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)))}",
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
}
