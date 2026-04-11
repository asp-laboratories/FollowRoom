import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class PantallaDetallesCoordinador extends StatefulWidget {
  final String idReservacion;

  const PantallaDetallesCoordinador({super.key, required this.idReservacion});

  @override
  State<PantallaDetallesCoordinador> createState() =>
      _PantallaDetallesCoordinadorState();
}

class _PantallaDetallesCoordinadorState
    extends State<PantallaDetallesCoordinador> {
  bool _cargando = true;
  String _puntos = ".";
  Timer? _timerPuntos;
  final ReservacionService _reservacionService = ReservacionService();

  Map<String, dynamic>? _datosCompletos;
  final TextEditingController _precioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  final List<Map<String, bool>> _checklist = [
    {'Confirmar reservación': false},
    {'Verificar pago': false},
    {'Contactar cliente': false},
    {'Asignar salón': false},
    {'Asignar montaje': false},
    {'Confirmar servicios': false},
    {'Confirmar equipamentos': false},
  ];

  @override
  void initState() {
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
      final data = await _reservacionService.getDetalleReservacion(
        int.parse(widget.idReservacion),
      );

      if (!mounted) return;

      print('DEBUG - Datos recibidos: $data');

      setState(() {
        _datosCompletos = data;
        _precioController.text = (_datosCompletos?['total'] ?? 0).toString();
        _cargando = false;
      });

      _timerPuntos?.cancel();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      }
    }
  }

  int _calcularSubtotal() {
    num serviciosTotal = 0;
    num equiposTotal = 0;

    if (_datosCompletos?['servicios'] != null) {
      serviciosTotal = (_datosCompletos?['servicios'] as List).fold<num>(
        0,
        (sum, s) => sum + ((s['precio'] ?? 0) as num),
      );
    }

    if (_datosCompletos?['equipamentos'] != null) {
      equiposTotal = (_datosCompletos?['equipamentos'] as List).fold<num>(
        0,
        (sum, e) =>
            sum + (((e['precio'] ?? 0) as num) * ((e['cantidad'] ?? 1) as num)),
      );
    }

    if (_datosCompletos?['mobiliarios'] != null) {
      final mobiliariosTotal = (_datosCompletos?['mobiliarios'] as List)
          .fold<num>(
            0,
            (sum, m) =>
                sum +
                (((m['precio'] ?? 0) as num) * ((m['cantidad'] ?? 1) as num)),
          );
      equiposTotal += mobiliariosTotal;
    }

    return (serviciosTotal + equiposTotal).toInt();
  }

  int _calcularIVA() {
    return (_calcularSubtotal() * 0.16).round();
  }

  void _actualizarPrecio() {
    final nuevoPrecio = int.tryParse(_precioController.text) ?? 0;
    setState(() {
      _datosCompletos?['total'] = nuevoPrecio;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Precio actualizado a \$$nuevoPrecio')),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timerPuntos?.cancel();
    _precioController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          ? Center(
              child: Text(
                'Cargando$_puntos',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _scrollToBottom,
                          icon: Icon(Icons.arrow_downward),
                          label: Text("Ir abajo"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
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
                            _datosCompletos?['descripEvento'] ??
                                _datosCompletos?['nombreEvento'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Fecha:",
                            _datosCompletos?['fechaEvento'] ?? 'No definida',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Horario:",
                            "${_datosCompletos?['horaInicio'] ?? 'No definida'} - ${_datosCompletos?['horaFin'] ?? ''}",
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de evento:",
                            _datosCompletos?['tipo_evento_datos']?['nombre'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Asistentes:",
                            (_datosCompletos?['estimaAsistentes'] ?? 0)
                                .toString(),
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
                            _datosCompletos?['cliente_datos']?['nombre'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Tipo de cliente:",
                            _datosCompletos?['cliente_tipo'] ?? 'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Teléfono del contacto:",
                            _datosCompletos?['cliente_datos']?['telefono'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Correo electrónico:",
                            _datosCompletos?['cliente_datos']?['correo_electronico'] ??
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
                      decoration: ContainerStyles.sombreado,
                      padding: EdgeInsets.all(12),
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
                          _buildLabelValue(
                            "Salón:",
                            _datosCompletos?['montaje_datos']?['salon']?['nombre'] ??
                                'Ningún salón',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Montaje:",
                            _datosCompletos?['montaje_datos']?['tipo_montaje']?['nombre'] ??
                                'No seleccionado',
                          ),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 2, color: AppColores.primary),
                  ),
                  Text(
                    "Seguimiento de la preparación",
                    style: TextEstilos.encabezados,
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
                      decoration: ContainerStyles.sombreado,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Checklist de Preparación",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...List.generate(_checklist.length, (index) {
                            final item = _checklist[index];
                            final key = item.keys.first;
                            return CheckboxListTile(
                              title: Text(key),
                              value: item[key],
                              onChanged: (value) {
                                setState(() {
                                  _checklist[index][key] = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            );
                          }),
                        ],
                      ),
                    ),
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
                      decoration: ContainerStyles.sombreado,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Actualizar Precio",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _precioController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Precio total",
                                    prefixText: "\$ ",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _actualizarPrecio,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColores.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Actualizar"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                              _buildLabelValue(
                                "Subtotal:",
                                "\$${_calcularSubtotal()}",
                              ),
                              Text("\$${_calcularSubtotal()}"),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabelValue(
                                "IVA (16%):",
                                "\$${_calcularIVA()}",
                              ),
                              Text("\$${_calcularIVA()}"),
                            ],
                          ),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabelValue(
                                "Total:",
                                "\${_datosCompletos?['total'] ?? 0}",
                              ),
                              Text(
                                "\${_datosCompletos?['total'] ?? 0}",
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
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _scrollToTop,
                          icon: Icon(Icons.arrow_upward),
                          label: Text("Ir arriba"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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
                  "\$${(_datosCompletos?['equipamentos'] as List).fold<int>(0, (sum, e) => sum + (((e['precio'] ?? 0) as int) * ((e['cantidad'] ?? 1) as int)))}",
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
