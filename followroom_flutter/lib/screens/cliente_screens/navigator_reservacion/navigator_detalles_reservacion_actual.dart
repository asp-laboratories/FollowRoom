import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DetallesReservacionActual extends StatefulWidget {
  const DetallesReservacionActual({super.key});

  @override
  State<DetallesReservacionActual> createState() =>
      _DetallesReservacionActualState();
}

class _DetallesReservacionActualState extends State<DetallesReservacionActual> {
  final bool _cargando = false;

  final Map<String, dynamic> _datosReservacion = {
    'nombre': 'Cumpleaños de jorge',
    'fecha': '15 de Marzo 2026',
    'horario': '14:00 - 18:00',
    'tipo': 'Cumpleaños',
    'asistentes': 100,
    'salon': 'Salón Imperial',
    'precioSalon': 5000,
    'montaje': 'Herradura',
    'cliente': 'Juan Pérez',
    'telefono': '666 6666 66 66',
    'email': 'juanperez@correo.com',
    'servicios': [
      {'nombre': 'Guardias', 'precio': 500},
      {'nombre': 'Decoradores', 'precio': 1500},
    ],
    'equipos': [
      {'nombre': 'Microfono', 'precio': 300, 'cantidad': 2},
      {'nombre': 'Televisor', 'precio': 500, 'cantidad': 3},
    ],
  };

  @override
  Widget build(BuildContext context) {
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
                          _datosReservacion['nombre'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _datosReservacion['fecha'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _datosReservacion['horario'],
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
                      percent: 0.50,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "50%",
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
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: ContainerStyles.sombreado,
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Datos del evento",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tipo: ${_datosReservacion?['tipo'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Asistentes: ${_datosReservacion?['asistentes'] ?? 0}",
                          ),
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
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Salón",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Salón: ${_datosReservacion?['salon'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Precio: \$${_datosReservacion?['precioSalon'] ?? 0}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Montaje: ${_datosReservacion?['montaje'] ?? 'No seleccionado'}",
                          ),
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
                          Text(
                            "Nombre: ${_datosReservacion?['cliente'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Teléfono: ${_datosReservacion?['telefono'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Email: ${_datosReservacion?['email'] ?? 'No definido'}",
                          ),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          SizedBox(height: 5),
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
    final servicios = _datosReservacion?['servicios'] as List? ?? [];
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
    final equipos = _datosReservacion?['equipos'] as List? ?? [];
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
    int serviciosTotal = 0;
    int equiposTotal = 0;
    int salonPrecio = _datosReservacion?['precioSalon'] as int? ?? 0;

    if (_datosReservacion?['servicios'] != null) {
      serviciosTotal = (_datosReservacion?['servicios'] as List).fold(
        0,
        (sum, s) => sum + (s['precio'] as int),
      );
    }

    if (_datosReservacion?['equipos'] != null) {
      equiposTotal = (_datosReservacion?['equipos'] as List).fold(
        0,
        (sum, e) => sum + ((e['precio'] as int) * (e['cantidad'] as int)),
      );
    }

    return serviciosTotal + equiposTotal + salonPrecio;
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }
}
