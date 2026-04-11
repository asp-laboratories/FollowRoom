import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_aceptados_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_cancelados_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_solicitudes_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tabs_reservacion_historial/tab_finalizadas_reservacion.dart';
import 'package:followroom_flutter/services/perfil_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final PerfilService _servicioPerfil = PerfilService();

  String rfcCliente = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _cargarRFCUsuario();
  }

  Future<void> _cargarRFCUsuario() async {
    final datos = await _servicioPerfil.getPerfil();

    setState(() {
      rfcCliente = datos['rfc'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rfcCliente == '') {
      return const Center(child: Text("No se encontro sesion del cliente"));
    }

    return DefaultTabController(
      length: 4,
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
              Tab(text: "Solicitudes"),
              Tab(text: "Aceptados"),
              Tab(text: "Finalizados"),
              Tab(text: "Cancelados"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TabSolicitudesReservacion(rfc: rfcCliente),
                TabAceptadosReservacion(rfc: rfcCliente),
                TabFinalizadasReservacion(rfc: rfcCliente),
                TabCanceladosReservacion(rfc: rfcCliente),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
