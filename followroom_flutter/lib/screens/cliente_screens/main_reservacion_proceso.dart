import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_cliente_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_datos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_equipamientos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_resumen_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_salon_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_servicios_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_total_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_mobiliarios_reservacion.dart';

class ReservacionProceso extends StatefulWidget {
  final Map<String, dynamic>? datosReservacion;
  const ReservacionProceso({super.key, this.datosReservacion});

  @override
  State<ReservacionProceso> createState() => _ReservacionProcesoState();
}

class _ReservacionProcesoState extends State<ReservacionProceso> {
  Map<String, dynamic> datosReservacion = {};
  Map<String, String> datosCliente = {};
  Map<String, dynamic> montajesPorSalon = {};
  Map<String, dynamic>? salonSeleccionado;
  List<Map<String, dynamic>> serviciosSeleccionados = [];
  List<Map<String, dynamic>> serviciosPaquete = [];
  List<Map<String, dynamic>> mobiliariosSeleccionados = [];
  List<Map<String, dynamic>> mobiliariosPaquete = [];
  List<Map<String, dynamic>> equipamientosSeleccionados = [];
  List<Map<String, dynamic>> equipamientosPaquete = [];

  // control de paquete
  bool _paqueteOriginal = false;

  // Datos de la reservacion
  late TextEditingController _nombreEventoController;
  final TextEditingController _descripcionEventoController =
      TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  late TextEditingController _asistentesController;

  // Datos del cliente
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController =
      TextEditingController();
  final TextEditingController _apellidoMaternoController =
      TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _nombreFiscalController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();

  @override
  void initState() {
    super.initState();

    String nombreEvento =
        widget.datosReservacion?['nombreEvento']?.toString() ?? '';
    String asistentesIdeales =
        widget.datosReservacion?['estimaAsistentes']?.toString() ?? '';

    _nombreEventoController = TextEditingController(text: nombreEvento);
    _asistentesController = TextEditingController(text: asistentesIdeales);

    if (widget.datosReservacion != null) {
      datosReservacion.addAll(widget.datosReservacion!);

      if (widget.datosReservacion!['montaje'] != null) {
        salonSeleccionado = widget.datosReservacion!['montaje']['salon'];
        montajesPorSalon = widget.datosReservacion!['montaje']['tipo_montaje'];
        mobiliariosPaquete = List<Map<String, dynamic>>.from(
          widget.datosReservacion!['montaje']['montaje_mobiliario'],
        );
      }

      if (widget.datosReservacion!['reserva_servicio'] != null) {
        serviciosPaquete = List<Map<String, dynamic>>.from(
          widget.datosReservacion!['reserva_servicio'],
        );
      }

      if (widget.datosReservacion!['reserva_equipa'] != null) {
        equipamientosPaquete = List<Map<String, dynamic>>.from(
          widget.datosReservacion!['reserva_equipa'],
        );
      }
    }
  }

  @override
  void dispose() {
    _descripcionEventoController.dispose();
    _nombreEventoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _asistentesController.dispose();
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _rfcController.dispose();
    _nombreFiscalController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _coloniaController.dispose();
    _calleController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  void actualizarDatos(Map<String, dynamic> nuevosDatos) {
    setState(() {
      datosReservacion.addAll(nuevosDatos);
    });
  }

  void _goToNextTab() {
    final tabController = DefaultTabController.of(context);
    if (tabController.index < tabController.length - 1) {
      tabController.animateTo(tabController.index + 1);
    }
  }

  void actualizarDatosCliente(Map<String, String> nuevosDatos) {
    setState(() {
      datosCliente.addAll(nuevosDatos);
    });
  }

  void actualizarMontaje(Map<String, dynamic> montaje) {
    setState(() {
      montajesPorSalon = montaje;
    });
  }

  void actualizarSalon(Map<String, dynamic>? salon) {
    setState(() {
      salonSeleccionado = salon;

      if (widget.datosReservacion != null && !_paqueteOriginal) {
        final montajeOriginal = widget.datosReservacion!['montaje'];
        if (montajeOriginal != null) {
          final idSalonOg = montajeOriginal['salon']['id'];
          if (salon != null && salon['id'] != idSalonOg) {
            _deshacerPaquete();
          }
        }
      }
    });
  }

  void _deshacerPaquete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Se ha cambiado el salon del paquete. Los elementos del paquete se cobran individualmente.",
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );

    void incluirElementos(List<Map<String, dynamic>> listaSeleccionado, Map<String, dynamic> itemPaquete, bool tieneCantidad) {

      final elemento = itemPaquete['mobiliario'] ?? itemPaquete['equipamiento'] ?? itemPaquete['servicio'];

      if (elemento == null) return;

      final id = elemento['id'];
      final indice = listaSeleccionado.indexWhere((e) => e['id'] == id);

      if (indice >= 0){
        if (tieneCantidad) {
          listaSeleccionado[indice]['cantidad'] = (listaSeleccionado[indice]['cantidad'] as int) + (itemPaquete['cantidad'] ?? 1);
        }
      } else {
        Map<String, dynamic> nuevoItem = {
          'id': id,
          'nombre': elemento['nombre'],
          'costo': double.tryParse(elemento['costo'].toString()) ?? 0.0,
        };

        if (tieneCantidad) {
          nuevoItem['cantidad'] = itemPaquete['cantidad'] ?? 1;
        } else {
          nuevoItem['tipo'] = elemento ['tipo_servicio'] ?? 'sin tipo';
        }

        listaSeleccionado.add(nuevoItem);

      }

    }

    for (var mob in mobiliariosPaquete) {
      incluirElementos(mobiliariosSeleccionados, mob, true);
    }
    for (var equipo in equipamientosPaquete) {
      incluirElementos(equipamientosSeleccionados, equipo, true);
    }
    for (var servicio in serviciosPaquete) {
      incluirElementos(serviciosSeleccionados, servicio, false);
    }

    mobiliariosPaquete.clear();
    serviciosPaquete.clear();
    equipamientosPaquete.clear();

    _paqueteOriginal = true;

  }

  void actualizarMobiliarios(List<Map<String, dynamic>> mobiliarios) {
    setState(() {
      mobiliariosSeleccionados = mobiliarios;
    });
  }

  void actualizarServicios(List<Map<String, dynamic>> servicios) {
    setState(() {
      serviciosSeleccionados = servicios;
    });
  }

  void actualizarEquipamientos(List<Map<String, dynamic>> equipamientos) {
    setState(() {
      equipamientosSeleccionados = equipamientos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColores.background2,
          bottom: ButtonsTabBar(
            backgroundColor: AppColores.primary,
            unselectedBackgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            radius: 70,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            tabs: [
              Tab(text: "Reservacion"),
              Tab(text: "Datos cliente"),
              Tab(text: "Salones"),
              Tab(text: "Mobiliarios"),
              Tab(text: "Servicios"),
              Tab(text: "Equipamientos"),
              Tab(text: "Resumen"),
              Tab(text: "total"),
            ],
          ),

          title: Text("Solicitar reservacion"),
        ),
        body: TabBarView(
          children: [
            TabDatosReservacion(
              onDatosChanged: actualizarDatos,
              onSaveAndNext: _goToNextTab,
              nombreController: _nombreEventoController,
              fechaController: _fechaController,
              horaController: _horaController,
              asistentesController: _asistentesController,
            ),
            TabClienteReservacion(
              onDatosChanged: actualizarDatosCliente,
              onSaveAndNext: _goToNextTab,
              nombreController: _nombreController,
              apellidoPaternoController: _apellidoPaternoController,
              apellidoMaternoController: _apellidoMaternoController,
              rfcController: _rfcController,
              nombreFiscalController: _nombreFiscalController,
              telefonoController: _telefonoController,
              correoController: _correoController,
              coloniaController: _coloniaController,
              calleController: _calleController,
              numeroController: _numeroController,
            ),
            TabSalon(
              cantidadAsistentes:
                  int.tryParse(
                    datosReservacion['estimaAsistentes']?.toString() ?? '',
                  ) ??
                  0,
              salonSeleccionado: salonSeleccionado,
              onMontajeSelected: actualizarMontaje,
              onSalonSelected: actualizarSalon,
              montajesPorSalon: montajesPorSalon,
            ),
            TabMobiliariosReservacion(
              onMobiliariosChanged: actualizarMobiliarios,
              mobiliariosSeleccionados: mobiliariosSeleccionados,
              salon: salonSeleccionado,
              mobiliariosPaquete: mobiliariosPaquete,
            ),
            TabServiciosReservacion(
              onServiciosChanged: actualizarServicios,
              serviciosSeleccionados: serviciosSeleccionados,
              serviciosPaquete: serviciosPaquete,
            ),
            TabEquipamientosReservacion(
              onEquipamientosChanged: actualizarEquipamientos,
              equipamientosSeleccionados: equipamientosSeleccionados,
              equipamientosPaquete: equipamientosPaquete,
            ),
            TabResumen(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salonSeleccionado,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: serviciosSeleccionados,
              equipamientosSeleccionados: equipamientosSeleccionados,
              mobiliariosSeleccionados: mobiliariosSeleccionados,
              datosPaquete: widget.datosReservacion,
              mobiliariosPaquete: mobiliariosPaquete,
              equipamientosPaquete: equipamientosPaquete,
              serviciosPaquete: serviciosPaquete,
            ),
            TabTotalReservacion(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salonSeleccionado,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: serviciosSeleccionados,
              equipamientosSeleccionados: equipamientosSeleccionados,
              mobiliariosSeleccionados: mobiliariosSeleccionados,
              datosPaquete: widget.datosReservacion,
            ),
          ],
        ),
      ),
    );
  }
}
