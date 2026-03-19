import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_aceptados_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_cancelados_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_proceso_reservacion.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          ButtonsTabBar(
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
              Tab(text: "Aceptados"),
              Tab(text: "En proceso"),
              Tab(text: "Cancelados"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TabAceptadosReservacion(),
                TabProcesoReservacion(),
                TabCanceladosReservacion(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
