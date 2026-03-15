import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_cliente_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_datos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_equipamientos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_resumen_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_salon_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_servicios_reservacion.dart';

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
            ),
            TabClienteReservacion(
              onDatosChanged: actualizarDatosCliente,
              onSaveAndNext: _goToNextTab,
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
            TabEquipamientosReservacion(
              onEquipamientosChanged: actualizarEquipamientos,
              equipamientosSeleccionados: equipamientosSeleccionados,
            ),
          ],
        ),
      ),
    );
  }
}
