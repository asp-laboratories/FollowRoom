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

class ReservacionProceso extends StatefulWidget {
  const ReservacionProceso({super.key});

  @override
  State<ReservacionProceso> createState() => _ReservacionProcesoState();
}

class _ReservacionProcesoState extends State<ReservacionProceso> {
  Map<String, String> datosReservacion = {};
  Map<String, String> datosCliente = {};
  Map<int, String> montajesPorSalon = {};
  Map<String, dynamic>? salonSeleccionado;
  List<Map<String, dynamic>> serviciosSeleccionados = [];
  List<Map<String, dynamic>> equipamientosSeleccionados = [];

  final TextEditingController _nombreEventoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _asistentesController = TextEditingController();
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
  void dispose() {
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

  void actualizarDatos(Map<String, String> nuevosDatos) {
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

  void actualizarMontaje(int salonId, String montaje) {
    setState(() {
      montajesPorSalon[salonId] = montaje;
    });
  }

  void actualizarSalon(Map<String, dynamic>? salon) {
    setState(() {
      salonSeleccionado = salon;
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
      length: 7,
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
              montajesPorSalon: montajesPorSalon,
              salonSeleccionado: salonSeleccionado,
              onMontajeSelected: actualizarMontaje,
              onSalonSelected: actualizarSalon,
            ),
            TabServiciosReservacion(
              onServiciosChanged: actualizarServicios,
              serviciosSeleccionados: serviciosSeleccionados,
            ),
            TabEquipamientosReservacion(
              onEquipamientosChanged: actualizarEquipamientos,
              equipamientosSeleccionados: equipamientosSeleccionados,
            ),
            TabResumen(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salonSeleccionado,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: serviciosSeleccionados,
              equipamientosSeleccionados: equipamientosSeleccionados,
            ),
            TabTotalReservacion(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salonSeleccionado,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: serviciosSeleccionados,
              equipamientosSeleccionados: equipamientosSeleccionados,
            ),
          ],
        ),
      ),
    );
  }
}
