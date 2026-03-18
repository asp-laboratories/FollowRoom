import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:followroom_flutter/core/texto_styles.dart';

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

  Map<String, dynamic>? _datosCompletos;
  final TextEditingController _precioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    await Future.delayed(const Duration(seconds: 1));

    final datoPruebas = {
      'descripcionEvento': "fiesta para mi sobrino que cumple 18",
      'invitados': 100,
      'fechaEvento': "18-12-2027",
      'horainicio': "12:00 PM",
      'cliente': 'Juan Pérez',
      'tipoCliente': "Persona fisica",
      'telefono': "666 6666 66 66",
      'email': "juanperez@correo.com",
      'tipoMontaje': "Herradura",
      'nombreSalon': "Salón Imperial",
      'precioTotal': 15000,
      'servicios': [
        {'nombre': 'Guardias', 'precio': 500},
        {'nombre': 'Decoradores', 'precio': 1500},
        {'nombre': 'Meseros', 'precio': 800},
        {'nombre': 'Limpieza', 'precio': 600},
      ],
      'equipos': [
        {'nombre': 'Microfono', 'precio': 300, 'cantidad': 2},
        {'nombre': 'Equipo Audiovisual', 'precio': 2000, 'cantidad': 1},
        {'nombre': 'Televisor', 'precio': 500, 'cantidad': 3},
      ],
    };

    if (!mounted) return;

    setState(() {
      _datosCompletos = datoPruebas;
      _precioController.text = (datoPruebas['precioTotal'] ?? 0).toString();
      _cargando = false;
    });

    _timerPuntos?.cancel();
  }

  void _actualizarPrecio() {
    final nuevoPrecio = int.tryParse(_precioController.text) ?? 0;
    setState(() {
      _datosCompletos?['precioTotal'] = nuevoPrecio;
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
      ),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Nombre del evento: ${_datosCompletos?['descripcionEvento'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Fecha: ${_datosCompletos?['fechaEvento'] ?? 'No definida'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Hora: ${_datosCompletos?['horainicio'] ?? 'No definida'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Asistentes: ${_datosCompletos?['invitados'] ?? 0}",
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
                            "Nombre: ${_datosCompletos?['cliente'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Tipo: ${_datosCompletos?['tipoCliente'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Teléfono: ${_datosCompletos?['telefono'] ?? 'No definido'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Email: ${_datosCompletos?['email'] ?? 'No definido'}",
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
                            "Salón y Montaje",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Salón: ${_datosCompletos?['nombreSalon'] ?? 'Ningún salón'}",
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Montaje: ${_datosCompletos?['tipoMontaje'] ?? 'No seleccionado'}",
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
                    padding: const EdgeInsets.all(16.0),
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
                    padding: const EdgeInsets.all(16.0),
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
                                "\$${_datosCompletos?['precioTotal'] ?? 0}",
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
}
