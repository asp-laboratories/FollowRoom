import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'dart:async';
import 'detalles_montaje.dart';

class PantallaDetalles extends StatefulWidget {
  final String idReservacion;

  const PantallaDetalles({super.key, required this.idReservacion});

  @override
  State<PantallaDetalles> createState() => _PantallaDetallesState();
}

class _PantallaDetallesState extends State<PantallaDetalles> {
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
    // Logica pa recibir los datos de la base de datos
    await Future.delayed(const Duration(seconds: 1));

    final datoPruebas = {
      'descripcionEvento': "fiesta pa mi sobrino q cumple 18",
      'invitados': 100,
      'fechaEvento': "18-12-2027",
      'horainicio': "12:00 AM",
      'cliente': 'Mi papa',
      'tipoCliente': "Persona fisica",
      'telefono': "666 6666 66 66",
      'email': "mimamamemima@hotmail.com",
      'tipoMontaje': "Herradura",
      'nombreSalon': "paquito",
      'servicios': [
        {'nombre': 'Guardias'},
        {'nombre': "Decoradores"},
        {'nombre': "Meseros"},
        {'nombre': "Limpieza"},
      ],
      'equipos': [
        {'nombre': "Microfono"},
        {'nombre': "Equipo Audiovisual"},
        {'nombre': "Televisor"},
      ],
    };

    if (!mounted) return;

    setState(() {
      _datosCompletos = datoPruebas;
      _cargando = false;
    });

    _timerPuntos?.cancel();
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
                          SizedBox(height: 8),
                          _buildLabelValue(
                            "Nombre del evento:",
                            _datosCompletos?['descripcionEvento'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Fecha:",
                            _datosCompletos?['fechaEvento'] ?? 'No definida',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Hora:",
                            _datosCompletos?['horainicio'] ?? 'No definida',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de evento:",
                            _datosCompletos?['tipoMontaje'] ??
                                'No seleccionado',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            (_datosCompletos?['invitados'] ?? 0).toString(),
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
                            "Nombre del contacto:",
                            _datosCompletos?['cliente'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de cliente:",
                            _datosCompletos?['tipoCliente'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Telefono del contacto:",
                            _datosCompletos?['telefono'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Correo electronico del contacto:",
                            _datosCompletos?['email'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "RFC:",
                            _datosCompletos?['rfc'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Nombre fiscal:",
                            _datosCompletos?['nombreFiscal'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Colonia:",
                            _datosCompletos?['colonia'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Calle:",
                            _datosCompletos?['calle'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Numero:",
                            _datosCompletos?['numero'] ?? 'No definido',
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detalles(
                              numeroReservacion: widget.idReservacion,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: ContainerStyles.sombreado,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Salón y Montaje",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "Detalles >",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildLabelValue(
                              "Salón:",
                              _datosCompletos?['nombreSalon'] ??
                                  'Ningún salón seleccionado',
                            ),
                            SizedBox(height: 2),
                            _buildLabelValue(
                              "Tipo de montaje:",
                              _datosCompletos?['tipoMontaje'] ??
                                  'No seleccionado',
                            ),
                          ],
                        ),
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
                            "Total de la Reservación",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildLabelValue(
                            "Subtotal:",
                            "\$${_calcularSubtotal()}",
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue("IVA (16%):", "\$${_calcularIVA()}"),
                          Divider(height: 16),
                          _buildLabelValue("Total:", "\$${_calcularTotal()}"),
                        ],
                      ),
                    ),
                  ),
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
                        "- ${s['nombre'] ?? 'Sin nombre'}",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${s['precio'] ?? 0}",
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
          if (_datosCompletos?['equipos'] == null ||
              (_datosCompletos?['equipos'] as List).isEmpty)
            Text("Sin equipos", style: TextStyle(fontSize: 12))
          else
            ...(_datosCompletos?['equipos'] as List).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "- ${e['nombre'] ?? 'Sin nombre'} (x${e['cantidad'] ?? 1})",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_datosCompletos?['equipos'] != null &&
              (_datosCompletos?['equipos'] as List).isNotEmpty) ...[
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "\$${(_datosCompletos?['equipos'] as List).fold<int>(0, (sum, e) => sum + (((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)))}",
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

    if (_datosCompletos?['servicios'] != null) {
      serviciosTotal = (_datosCompletos?['servicios'] as List).fold<int>(
        0,
        (sum, s) => sum + ((s['precio'] ?? 0) as int),
      );
    }

    if (_datosCompletos?['equipos'] != null) {
      equiposTotal = (_datosCompletos?['equipos'] as List).fold<int>(
        0,
        (sum, e) =>
            sum + (((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)),
      );
    }

    return serviciosTotal + equiposTotal;
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  int _calcularTotal() {
    return _calcularSubtotal() + _calcularIVA();
  }
}
