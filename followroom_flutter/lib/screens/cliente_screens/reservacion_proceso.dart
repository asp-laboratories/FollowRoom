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
  String? montajeSeleccionado;
  List<Map<String, dynamic>> serviciosSeleccionados = [];
  List<Map<String, dynamic>> equipamientosSeleccionados = [];

  void actualizarDatos(Map<String, String> nuevosDatos) {
    setState(() {
      datosReservacion.addAll(nuevosDatos);
    });
  }


  void actualizarDatosCliente(Map<String, String> nuevosDatos) {
    setState(() {
      datosCliente.addAll(nuevosDatos);
    });
  }

  void actualizarMontaje(String montaje) {
    setState(() {
      montajeSeleccionado = montaje;
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

          title: Text("data"),
        ),
        body: TabBarView(
          children: [
            TabDatosReservacion(onDatosChanged: actualizarDatos),
            TabClienteReservacion(onDatosChanged: actualizarDatosCliente),
            TabSalon(
              montajeSeleccionado: montajeSeleccionado,
              onMontajeSelected: actualizarMontaje,
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
              montajeSeleccionado: montajeSeleccionado,
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
