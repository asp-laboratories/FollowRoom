import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/core/estados_widgets.dart';
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
    {'Firma de contrato / Aceptación de términos': false},
    {'Anticipo recibido (primer pago)': false},
    {'Trabajadores asignados': false},
    {'Definición del montaje': false},
    {'Servicios adicionales definidos': false},
    {'Equipamiento requerido definido': false},
    {'Montaje de mobiliario completado': false},
    {'Orden de Servicio (BEO) distribuida': false},
    {'Checklist de Montaje': false},
    {'Prueba de Equipos': false},
    {'Recepción del Cliente': false},
    {'Liquidación de Saldo': false},
    {'Evento en curso': false},
    {'Cierre de Inventario': false},
  ];

  Map<String, bool> _checklistCoordinador = {};
  Map<String, bool> _checklistAlmacenista = {};
  double _progresoChecklist = 0.0;
  bool _checklistAlmacenistaCompleto = false;
  String? _error;
  Map<String, dynamic>? _encuesta;
  bool _cargandoEncuesta = false;

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

      // Cargar datos de la reservación
      setState(() {
        _datosCompletos = data;
        _precioController.text = (_datosCompletos?['total'] ?? 0).toString();
        _cargando = false;
      });

      // Cargar checklist del coordinador desde endpoint específico
      try {
        final checklistCoordinadorData = await _reservacionService
            .getChecklistCoordinador(int.parse(widget.idReservacion));
        final checklistData =
            checklistCoordinadorData['checklist_coordinador']
                as Map<String, dynamic>? ??
            {};
        _checklistCoordinador = checklistData.map(
          (k, v) => MapEntry(k, v == true || v == 'true'),
        );
        _progresoChecklist =
            (checklistCoordinadorData['progreso_checklist'] ?? 0.0).toDouble();

        if (mounted) setState(() {});
      } catch (e) {
        print('Error al cargar checklist coordinador: $e');
      }

      // Cargar checklist del almacenista
      try {
        final checklistAlmacenistaData = await _reservacionService
            .getChecklistAlmacenista(int.parse(widget.idReservacion));
        final almacenistaMap =
            checklistAlmacenistaData['checklist_almacenista']
                as Map<String, dynamic>? ??
            {};
        _checklistAlmacenista = almacenistaMap.map(
          (k, v) => MapEntry(k, v == true || v == 'true'),
        );
        // Verificar si todos los items del almacenista están completos
        _checklistAlmacenistaCompleto =
            _checklistAlmacenista.isNotEmpty &&
            _checklistAlmacenista.values.every((v) => v == true);

        if (mounted) setState(() {});
      } catch (e) {
        print('Error al cargar checklist almacenista: $e');
      }

      // Cargar checklist del almacenista
      try {
        final checklistAlmacenistaData = await _reservacionService
            .getChecklistAlmacenista(int.parse(widget.idReservacion));
        final almacenistaMap =
            checklistAlmacenistaData['checklist_almacenista']
                as Map<String, dynamic>? ??
            {};
        _checklistAlmacenista = almacenistaMap.map(
          (k, v) => MapEntry(k, v == true || v == 'true'),
        );
        // Verificar si todos los items del almacenista están completos
        _checklistAlmacenistaCompleto =
            _checklistAlmacenista.isNotEmpty &&
            _checklistAlmacenista.values.every((v) => v == true);
      } catch (e) {
        print('Error al cargar checklist almacenista: $e');
      }

      _timerPuntos?.cancel();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _cargarEncuesta() async {
    if (_encuesta != null || _cargandoEncuesta) return;
    setState(() {
      _cargandoEncuesta = true;
    });

    try {
      final encuestaData = await _reservacionService.getEncuesta(
        int.parse(widget.idReservacion),
      );
      if (mounted) {
        setState(() {
          _encuesta = encuestaData;
          _cargandoEncuesta = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoEncuesta = false;
        });
      }
    }
  }

  bool _puedeMarcarChecklist(String key) {
    final keys = _checklist.map((e) => e.keys.first).toList();
    final index = keys.indexOf(key);
    if (index <= 0) return true;

    // El item 9 (Checklist de Montaje - índice 8) está marcado cuando el almacenista completa su checklist
    final esItemMontaje = index == 8;
    if (esItemMontaje && _checklistAlmacenistaCompleto) {
      return true;
    }

    // Solo puede marcar si el anterior está completado (considerando el item 9 del almacenista)
    final anteriorKey = keys[index - 1];
    final esAnteriorItemMontaje = (index - 1) == 8;

    if (esAnteriorItemMontaje) {
      // Si el anterior era el item 9 (Checklist de Montaje), depende del almacenista
      return _checklistAlmacenistaCompleto;
    }

    return _checklistCoordinador[anteriorKey] == true;
  }

  Future<void> _guardarChecklist() async {
    // Verificar si se está marcando "Evento en curso" (índice 12) o "Cierre de Inventario" (índice 13)
    final keys = _checklist.map((e) => e.keys.first).toList();
    final eventoEnCursoKey = keys[12]; // "Evento en curso"
    final cierreInventarioKey = keys[13]; // "Cierre de Inventario"

    // Si se marca "Evento en curso", cambiar estado a ENPRO
    if (_checklistCoordinador[eventoEnCursoKey] == true) {
      // === VALIDACIÓN DE HORAS COMENTADA PARA PRUEBAS ===
      // final fechaEvento = _datosCompletos?['fechaEvento'];
      // final horaInicio = _datosCompletos?['horaInicio'];
      // final horaFin = _datosCompletos?['horaFin'];
      // final ahora = DateTime.now();
      // final inicio = DateTime.parse('$fechaEvento $horaInicio');
      // final fin = DateTime.parse('$fechaEvento $horaFin');
      // if (ahora.isBefore(inicio) || ahora.isAfter(fin)) {
      //   print('WARNING: La hora actual no coincide con el horario del evento');
      // }
      // === FIN VALIDACIÓN ===
      try {
        await _reservacionService.cambiarEstado(
          int.parse(widget.idReservacion),
          'ENPRO',
        );
        print('DEBUG: Estado cambiado a ENPRO');
      } catch (e) {
        print('Error al cambiar estado a ENPRO: $e');
      }
    }

    // Si se marca "Cierre de Inventario", cambiar estado a FIN
    if (_checklistCoordinador[cierreInventarioKey] == true) {
      try {
        await _reservacionService.cambiarEstado(
          int.parse(widget.idReservacion),
          'FIN',
        );
        print('DEBUG: Estado cambiado a FIN');
      } catch (e) {
        print('Error al cambiar estado a FIN: $e');
      }
    }

    try {
      final result = await _reservacionService.updateChecklist(
        int.parse(widget.idReservacion),
        'coordinador',
        _checklistCoordinador,
      );

      if (mounted) {
        final checklistFromServer =
            result['checklist_coordinador'] as Map<String, dynamic>? ?? {};
        setState(() {
          _checklistCoordinador = checklistFromServer.map(
            (k, v) => MapEntry(k, v == true || v == 'true'),
          );
          _progresoChecklist = (result['progreso_checklist'] ?? 0.0).toDouble();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checklist guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _calcularSubtotal() {
    num serviciosTotal = 0;
    num equiposTotal = 0;

    // El serializer devuelve: servicio__costo, equipamiento__costo, mobiliario__costo
    if (_datosCompletos?['servicios'] != null) {
      serviciosTotal = (_datosCompletos?['servicios'] as List).fold<num>(
        0,
        (sum, s) =>
            sum +
            ((s['servicio__costo'] ?? s['costo'] ?? s['precio'] ?? 0) as num),
      );
    }

    if (_datosCompletos?['equipamentos'] != null) {
      equiposTotal = (_datosCompletos?['equipamentos'] as List).fold<num>(
        0,
        (sum, e) =>
            sum +
            (((e['equipamiento__costo'] ?? e['costo'] ?? e['precio'] ?? 0)
                    as num) *
                ((e['cantidad'] ?? 1) as num)),
      );
    }

    if (_datosCompletos?['mobiliarios'] != null) {
      final mobiliariosTotal = (_datosCompletos?['mobiliarios'] as List)
          .fold<num>(
            0,
            (sum, m) =>
                sum +
                (((m['mobiliario__costo'] ?? m['costo'] ?? m['precio'] ?? 0)
                        as num) *
                    ((m['cantidad'] ?? 1) as num)),
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
    final nombreEvento =
        _datosCompletos?['nombreEvento'] ??
        'Reservación ${widget.idReservacion}';
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreEvento),
        backgroundColor: AppColores.background2,
      ),
      backgroundColor: AppColores.background2,
      body: _cargando
          ? const LoadingWidget(mensaje: 'Cargando reservación...')
          : _error != null
          ? ErrorDisplay.conexion(
              mensaje: _error!,
              onRetry: () {
                setState(() {
                  _error = null;
                  _cargando = true;
                });
                _descargarDatos();
              },
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _scrollToBottom,
                        icon: Icon(Icons.arrow_downward),
                        label: Text("Ir abajo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
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
                            _datosCompletos?['nombreEvento'] ?? 'No definido',
                          ),
                          _buildLabelValue(
                            'Descripcion del evento:',
                            _datosCompletos?['descripEvento'] ??
                                'Sin descripcion',
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
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     left: 16,
                  //     right: 16,
                  //     bottom: 16,
                  //   ),
                  //   child: Container(
                  //     decoration: ContainerStyles.sombreado,
                  //     width: double.infinity,
                  //     padding: EdgeInsets.all(12),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Descripción del Evento",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //         SizedBox(height: 8),
                  //         Text(
                  //           _datosCompletos?['descripEvento'] ??
                  //               'Sin descripción',
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             color: AppColores.foreground.withValues(
                  //               alpha: 0.8,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
                            "Apellido:",
                            _datosCompletos?['cliente_datos']?['apellidoPaterno'] ??
                                '',
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
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "RFC:",
                            _datosCompletos?['cliente_datos']?['rfc'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Nombre fiscal:",
                            _datosCompletos?['cliente_datos']?['nombre_fiscal'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Colonia:",
                            _datosCompletos?['cliente_datos']?['dir_colonia'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Calle:",
                            _datosCompletos?['cliente_datos']?['dir_calle'] ??
                                'No definido',
                          ),
                          SizedBox(height: 2),
                          _buildLabelValue(
                            "Número:",
                            _datosCompletos?['cliente_datos']?['dir_numero']
                                    ?.toString() ??
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
                          // Mostrar progreso
                          Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColores.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${(_progresoChecklist * 100).toInt()}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColores.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(_checklist.length, (index) {
                            final item = _checklist[index];
                            final key = item.keys.first;
                            // El item #9 "Checklist de Montaje" (índice 8) depende del checklist del almacenista
                            final esItemMontaje = index == 8;
                            final puedeMarcar = esItemMontaje
                                ? _checklistAlmacenistaCompleto
                                : _puedeMarcarChecklist(key);

                            // Cuando el almacenista completa su checklist, marcar automáticamente el item del coordinador
                            final valorItem =
                                esItemMontaje && _checklistAlmacenistaCompleto
                                ? true
                                : (_checklistCoordinador[key] ?? false);

                            return CheckboxListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      key,
                                      style: TextStyle(
                                        color: esItemMontaje
                                            ? (_checklistAlmacenistaCompleto
                                                  ? Colors.black
                                                  : Colors.grey)
                                            : !puedeMarcar &&
                                                  !(_checklistCoordinador[key] ??
                                                      false)
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (esItemMontaje) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _checklistAlmacenistaCompleto
                                            ? Colors.green.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.orange.withValues(
                                                alpha: 0.2,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _checklistAlmacenistaCompleto
                                            ? 'Almacenista concluyó'
                                            : 'Almacenista debe completar',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _checklistAlmacenistaCompleto
                                              ? Colors.green[800]
                                              : Colors.orange[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              value: valorItem,
                              onChanged: puedeMarcar
                                  ? (value) {
                                      setState(() {
                                        _checklistCoordinador[key] =
                                            value ?? false;
                                      });
                                    }
                                  : null,
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _guardarChecklist,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColores.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Checklist'),
                            ),
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
                                _datosCompletos?['subtotal']?.toString() ?? '0',
                              ),
                              Text(
                                _datosCompletos?['subtotal']?.toString() ?? '0',
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabelValue(
                                "IVA:",
                                _datosCompletos?['IVA']?.toString() ?? '0',
                              ),
                              Text(_datosCompletos?['IVA']?.toString() ?? '0'),
                            ],
                          ),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabelValue(
                                "Total:",
                                "${_datosCompletos?['total'] ?? 0}",
                              ),
                              Text(
                                "${_datosCompletos?['total'] ?? 0}",
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _scrollToTop,
                        icon: Icon(Icons.arrow_upward),
                        label: Text("Ir arriba"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  if (_progresoChecklist >= 1.0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: ContainerStyles.sombreado,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Calificación del Cliente",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_encuesta == null && !_cargandoEncuesta)
                                  TextButton(
                                    onPressed: _cargarEncuesta,
                                    child: Text("Ver encuesta"),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (_cargandoEncuesta)
                              Center(child: CircularProgressIndicator())
                            else if (_encuesta != null) ...[
                              _buildEncuestaDisplay(),
                            ] else
                              Text(
                                "Aún no hay encuesta disponible",
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEncuestaDisplay() {
    if (_encuesta == null) return SizedBox.shrink();

    final personal = (_encuesta!['personal'] ?? 0).toInt();
    final equipamiento = (_encuesta!['equipamiento'] ?? 0).toInt();
    final servicios = (_encuesta!['servicios'] ?? 0).toInt();
    final salon = (_encuesta!['salon'] ?? 0).toInt();
    final mobiliario = (_encuesta!['mobiliario'] ?? 0).toInt();

    final promedio =
        (personal + equipamiento + servicios + salon + mobiliario) / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColores.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: AppColores.primary, size: 28),
              SizedBox(width: 8),
              Text(
                promedio.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColores.primary,
                ),
              ),
              Text(' / 5', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Calificaciones:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(height: 4),
        _buildRatingRow('Personal', personal),
        _buildRatingRow('Equipamiento', equipamiento),
        _buildRatingRow('Servicios', servicios),
        _buildRatingRow('Salón', salon),
        _buildRatingRow('Mobiliario', mobiliario),
        if (_encuesta!['comentario'] != null &&
            _encuesta!['comentario'].toString().isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            'Comentario:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            _encuesta!['comentario'] ?? '',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
        SizedBox(height: 8),
        Text(
          'Fecha: ${_encuesta!['fecha_creacion'] ?? ''}',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRatingRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12)),
          ...List.generate(
            5,
            (i) => Icon(
              i < value ? Icons.star : Icons.star_border,
              size: 14,
              color: Colors.amber,
            ),
          ),
        ],
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
