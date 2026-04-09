import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class TabResumen extends StatefulWidget {
  final Map<String, dynamic> datosReservacion;
  final Map<String, String> datosCliente;
  final Map<String, dynamic>? salonSeleccionado;
  final Map<String, dynamic> montajesPorSalon;
  final List<Map<String, dynamic>> serviciosSeleccionados;
  final List<Map<String, dynamic>> equipamientosSeleccionados;
  final List<Map<String, dynamic>> mobiliariosSeleccionados;
  final List<Map<String, dynamic>>? mobiliariosPaquete;
  final List<Map<String, dynamic>>? serviciosPaquete;
  final Map<String, dynamic>? datosPaquete;
  final List<Map<String, dynamic>>? equipamientosPaquete;

  const TabResumen({
    super.key,
    required this.datosReservacion,
    required this.datosCliente,
    required this.salonSeleccionado,
    required this.montajesPorSalon,
    required this.serviciosSeleccionados,
    required this.equipamientosSeleccionados,
    required this.mobiliariosSeleccionados,
    this.mobiliariosPaquete,
    this.datosPaquete,
    this.serviciosPaquete,
    this.equipamientosPaquete,
  });

  @override
  State<TabResumen> createState() => _TabResumenState();
}

class _TabResumenState extends State<TabResumen> {
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

  bool get _paqueteOriginal {
    if (widget.datosPaquete == null || widget.datosPaquete!.isEmpty) {
      return false;
    }
    if (widget.salonSeleccionado == null) return false;

    final montajeOriginal = widget.datosPaquete!['montaje'];
    if (montajeOriginal == null) return false;

    final idSalon = montajeOriginal['salon']['id'];

    return idSalon == widget.salonSeleccionado!['id'];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
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
                      widget.datosReservacion['nombre'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Fecha:",
                      widget.datosReservacion['fechaEvento'] ?? 'No definida',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Horario:",
                      widget.datosReservacion['horario'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Tipo de evento:",
                      widget.datosReservacion['tipo_evento']?['nombre'] ??
                          'No seleccionado',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Asistentes:",
                      widget.datosReservacion['estimaAsistentes']?.toString() ?? '0',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                      widget.datosCliente['nombre'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Apellido del contacto:",
                      widget.datosCliente['apellidoPaterno'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Apellido materno:",
                      widget.datosCliente['apellidoMaterno'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "RFC:",
                      widget.datosCliente['rfc'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Nombre fiscal:",
                      widget.datosCliente['nombre_fiscal'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Telefono:",
                      widget.datosCliente['telefono'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Colonia:",
                      widget.datosCliente['dir_colonia'] ?? 'No definido',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Calle:",
                      widget.datosCliente['dir_calle'] ?? 'No defined',
                    ),
                    SizedBox(height: 2),
                    _buildLabelValue(
                      "Numero:",
                      widget.datosCliente['dir_numero'] ?? 'No definido',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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

                    if (_paqueteOriginal) ...[
                      _buildLabelValue(
                        "Paquete Base: ",
                        widget.datosPaquete!['nombreEvento'] ?? 'Plantilla',
                      ),
                      _buildLabelValue(
                        "Precio del Paquete: ",
                        "\$${widget.datosPaquete!['subtotal'] ?? '0.0'}",
                      ),
                    ],

                    if (widget.salonSeleccionado == null)
                      Text("Ningún salón seleccionado")
                    else ...[
                      _buildLabelValue(
                        "Salón:",
                        widget.salonSeleccionado!['nombre'].toString(),
                      ),

                      if (!_paqueteOriginal)
                        _buildLabelValue(
                          "Precio:",
                          "\$${widget.salonSeleccionado?['costo']}",
                        ),

                      _buildLabelValue(
                        "Montaje:",
                        widget.montajesPorSalon[widget.salonSeleccionado!['id']
                                .toString()]?['nombre'] ??
                            'No seleccionado',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [SizedBox(height: 8), _buildMobiliariosContainer()],
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

          if (widget.serviciosPaquete != null &&
              widget.serviciosPaquete!.isNotEmpty) ...[
            Text(
              "Incluidos en el paquete: ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            ...widget.serviciosPaquete!.map((servicio) {
              final nombre = servicio['servicio']?['nombre'] ?? 'Servicio';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "- $nombre",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "Incluido",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 16),
            Text(
              "Servicios elegidos:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],

          if (widget.serviciosSeleccionados.isEmpty)
            Text("Sin servicios elegidos", style: TextStyle(fontSize: 12))
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
                      "\$${s['costo']}",
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
                  "Total elegidos:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${widget.serviciosSeleccionados.fold<double>(0, (sum, s) => sum + (double.tryParse(s['costo']?.toString() ?? '0') ?? 0.0)).toStringAsFixed(2)}",
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

          if (widget.equipamientosPaquete != null &&
              widget.equipamientosPaquete!.isNotEmpty) ...[
            Text(
              "Equipos incluidos en el paquete: ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            ...widget.equipamientosPaquete!.map((equipo) {
              final nombre =
                  equipo['equipamiento']?['nombre'] ?? 'Equipamiento';
              final cantidad = equipo['cantidad'] ?? 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "- $nombre (x$cantidad)",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "Incluido",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 16),
            Text(
              "Equipamientos elegidos",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],

          if (widget.equipamientosSeleccionados.isEmpty)
            Text("Sin equipos elegidos", style: TextStyle(fontSize: 12))
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
                      "\$${((double.tryParse(e['costo']?.toString() ?? '0') ?? 0.0) * (int.tryParse(e['cantidad']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}",
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
                  "Total elegidos:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${widget.equipamientosSeleccionados.fold<double>(0, (sum, e) => sum + ((double.tryParse(e['costo']?.toString() ?? '0') ?? 0.0) * (int.tryParse(e['cantidad']?.toString() ?? '0') ?? 0))).toStringAsFixed(2)}",
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

          if (widget.mobiliariosPaquete != null &&
              widget.mobiliariosPaquete!.isNotEmpty) ...[
            Text(
              "Mobiliarios incluidos en el paquete: ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            ...widget.mobiliariosPaquete!.map((mobi) {
              final nombre = mobi['mobiliario']?['nombre'] ?? 'Mobiliario';
              final cantidad = mobi['cantidad'] ?? 1;

              return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "- $nombre (x$cantidad)",
                        style: TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      "Incluido",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 16),
            Text("Mobiliarios elegidos"),
          ],

          if (widget.mobiliariosSeleccionados.isEmpty)
            Text(
              "Mobiliarios no elegidos",
              style: TextStyle(fontSize: 12),
            )
          else
            ...widget.mobiliariosSeleccionados.map(
              (mob) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${mob['nombre']} (x${mob['cantidad']})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${((double.tryParse(mob['costo']?.toString() ?? '0') ?? 0.0) * (int.tryParse(mob['cantidad']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.mobiliariosSeleccionados.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total elegidos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${widget.mobiliariosSeleccionados.fold<double>(0, (sum, mob) => sum + ((double.tryParse(mob['costo']?.toString() ?? '0') ?? 0.0) * (int.tryParse(mob['cantidad']?.toString() ?? '0') ?? 0))).toStringAsFixed(2)}",
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
