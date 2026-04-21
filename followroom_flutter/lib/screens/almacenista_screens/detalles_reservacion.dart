import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'dart:async';
import 'detalles_montaje.dart';

class PantallaDetalles extends StatefulWidget {
  final String idReservacion;

  const PantallaDetalles({super.key, required this.idReservacion});

  @override
  State<PantallaDetalles> createState() => _PantallaDetallesState();
}

class _PantallaDetallesState extends State<PantallaDetalles> {
  final ReservacionService _reservacionService = ReservacionService();

  bool _cargando = true;
  String _puntos = ".";
  Timer? _timerPuntos;

  Map<String, dynamic>? _datosCompletos;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    _iniciarAnimacion();
    _descargarDatos();
  }

  void _iniciarAnimacion() {
    _timerPuntos = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_puntos == "...") {
          _puntos = ".";
        } else {
          _puntos += ".";
        }
      });
    });
  }

  Future<void> _descargarDatos() async {
    try {
      final idReservacion = int.tryParse(widget.idReservacion);
      if (idReservacion == null) {
        throw Exception('ID de reservación inválido');
      }

      final data = await _reservacionService.getDetalleReservacion(
        idReservacion,
      );

      if (!mounted) return;

      setState(() {
        _datosCompletos = data;
        _cargando = false;
      });

      _timerPuntos?.cancel();
    } catch (e) {
      print('Error al descargar datos: $e');
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    //TODO: implement dispose
    _timerPuntos?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Usamos widget.idReservacion para mostrar el ID en el título
        title: Text('Detalles de Reserva ${widget.idReservacion}'),
      ),

      // Todo lo que ya tenías hecho, lo metemos en el 'body'
      body: _cargando
          ? Center(
              child: Text(
                'Cargando $_puntos',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          : SingleChildScrollView(
              //AQUI
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMobiliariosContainer(),
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
                      } else {
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
                      }
                    },
                  ),
                  SizedBox(height: 10),

                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     left: 16,
                  //     right: 16,
                  //     bottom: 16,
                  //   ),
                  //   child: Container(
                  //     width: double.infinity,
                  //     padding: EdgeInsets.all(12),
                  //     decoration: ContainerStyles.sombreado,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Total de la Reservación",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //         SizedBox(height: 8),
                  //         _buildLabelValue(
                  //           "Subtotal:",
                  //           "\$${_calcularSubtotal()}",
                  //         ),
                  //         SizedBox(height: 2),
                  //         _buildLabelValue("IVA (16%):", "\$${_calcularIVA()}"),
                  //         Divider(height: 16),
                  //         _buildLabelValue("Total:", "\$${_calcularTotal()}"),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
          if (_datosCompletos?['servicios'] == null ||
              (_datosCompletos?['servicios'] as List).isEmpty)
            Text("Sin servicios", style: TextStyle(fontSize: 12))
          else
            ...(_datosCompletos?['servicios'] as List).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${s['servicio__nombre'] ?? s['nombre'] ?? 'Sin nombre'}",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${s['servicio__costo'] ?? s['costo'] ?? s['precio'] ?? 0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_datosCompletos?['servicios'] != null &&
              (_datosCompletos?['servicios'] as List).isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${(_datosCompletos?['servicios'] as List).fold<int>(0, (sum, s) => sum + ((s['precio'] ?? 0) as int))}",
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
          if (_datosCompletos?['equipamentos'] == null ||
              (_datosCompletos?['equipamentos'] as List).isEmpty)
            Text("Sin equipos", style: TextStyle(fontSize: 12))
          else
            ...(_datosCompletos?['equipamentos'] as List).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${e['equipamiento__nombre'] ?? e['nombre'] ?? 'Sin nombre'} (x${e['cantidad'] ?? 1})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${((e['equipamiento__costo'] ?? e['costo'] ?? e['precio'] ?? 0) * (e['cantidad'] ?? 1)).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_datosCompletos?['equipamentos'] != null &&
              (_datosCompletos?['equipamentos'] as List).isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${(_datosCompletos?['equipamentos'] as List).fold<num>(0, (sum, e) => sum + ((e['equipamiento__costo'] ?? e['costo'] ?? e['precio'] ?? 0) * (e['cantidad'] ?? 1))).toStringAsFixed(2)}",
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
    num serviciosTotal = 0;
    num equiposTotal = 0;

    if (_datosCompletos?['servicios'] != null) {
      serviciosTotal = (_datosCompletos?['servicios'] as List).fold<num>(
        0,
        (sum, s) =>
            sum + (s['servicio__costo'] ?? s['costo'] ?? s['precio'] ?? 0),
      );
    }

    if (_datosCompletos?['equipamentos'] != null) {
      equiposTotal = (_datosCompletos?['equipamentos'] as List).fold<num>(
        0,
        (sum, e) =>
            sum +
            ((e['equipamiento__costo'] ?? e['costo'] ?? e['precio'] ?? 0) *
                (e['cantidad'] ?? 1)),
      );
    }

    return (serviciosTotal + equiposTotal).toInt();
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }

  Widget _buildMobiliariosContainer() {
    final mobiliariosList = _datosCompletos?['mobiliarios'] as List? ?? [];

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
          if (mobiliariosList.isEmpty)
            Text("Sin mobiliarios", style: TextStyle(fontSize: 12))
          else
            ...mobiliariosList.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${m['mobiliario__nombre'] ?? m['nombre'] ?? 'Mobiliario'} (x${m['cantidad'] ?? 1})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${((m['mobiliario__costo'] ?? m['costo'] ?? m['precio'] ?? 0) as num).toDouble().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (mobiliariosList.isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${mobiliariosList.fold<num>(0, (sum, m) => sum + (((m['mobiliario__costo'] ?? m['costo'] ?? m['precio'] ?? 0) as num).toDouble() * ((m['cantidad'] ?? 1) as num).toDouble()))}",
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
