import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_reservacion.dart/tab_datos_reservacion.dart';

class ReservacionProceso extends StatefulWidget {
  const ReservacionProceso({super.key});

  @override
  State<ReservacionProceso> createState() => _ReservacionProcesoState();
}

class _ReservacionProcesoState extends State<ReservacionProceso> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(text: "Reservacion",),
              Tab(text: "Datos cliente"),
              Tab(text: "Equipamiento"),
            ],
          ),

          title: Text("data"),
        ),
        body: TabBarView(
          children: [
            TabDatosReservacion(),
            Container(child: Text("2")),
            Container(child: Text("3")),
          ],
        ),
      ),
    );
  }
}
