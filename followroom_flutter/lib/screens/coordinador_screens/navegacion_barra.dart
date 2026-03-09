import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';

class NavegacionBarra extends StatefulWidget {
  const NavegacionBarra({super.key});

  @override
  State<NavegacionBarra> createState() => _NavegacionBarraState();
}

class _NavegacionBarraState extends State<NavegacionBarra> {
  int _indiceSeleccionado = 0;

  final List<Widget> _pantallas = [
    const Center(child: Text("Panel Coordinador - Bienvenido, Juan")),
    const Center(child: Text("Notificaciones")),
    const Center(child: Text("Mensajes")),
    const Center(child: Text("Pagos")),
    const Center(child: Text("Perfil")),
  ];

  final List<String> _titulos = [
    "Panel Coordinador",
    "Notificaciones",
    "Mensajes",
    "Pagos",
    "Perfil",
  ];

  void _alPresionar(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titulos[_indiceSeleccionado],
          style: TextEstilos.encabezados,
        ),
      ),

      body: _pantallas[_indiceSeleccionado],

      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColores.primary,
            selectedItemColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: _indiceSeleccionado,
            onTap: _alPresionar,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.work),
                label: "Panel",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: "Notificaciones",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: "Mensajes",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money),
                label: "Pagos",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Perfil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}