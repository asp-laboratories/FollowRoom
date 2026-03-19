import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/almacenista_screens/estado_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/inicio_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/perfil_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/solicitudes_almacenista.dart';

class Almacen extends StatefulWidget {
  const Almacen({super.key});

  @override
  State<Almacen> createState() => _AlmacenState();
}

class _AlmacenState extends State<Almacen> {
  int _indiceSeleccionado = 0;
  bool _navegacionBarra = false;

  final PageController _controladorPagina = PageController();

  final List<Widget> _pantallas = [
    InicioAlmacenista(),
    AlmacenistaEstadoScreen(),
    AlmacenistaSolicitudesScreen(),
    Perfil()
  ];

  void _alPresionar(int indice) async {
    setState(() {
      _indiceSeleccionado = indice;
      _navegacionBarra = true;
    });

    await _controladorPagina.animateToPage(
      indice,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _navegacionBarra = false;
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Almacen"),
          scrolledUnderElevation: 0,
          backgroundColor: AppColores.background2,
          foregroundColor: AppColores.foreground,
        ),

        body: Container(
          color: AppColores.background2,

          child: PageView(
            controller: _controladorPagina,

            physics: const FisicasFriccion(),

            onPageChanged: (int indice) {
              if (!_navegacionBarra) {
                setState(() {
                  _indiceSeleccionado = indice;
                });
              }
            },

            children: _pantallas,
          ),
        ),

        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),

          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            currentIndex: _indiceSeleccionado,
            onTap: _alPresionar,

            selectedItemColor: Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),

            items: const [
              BottomNavigationBarItem(
                backgroundColor: AppColores.primary,
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 24,
                  color: Colors.white,
                ),
                label: "Eventos",
                activeIcon: Icon(
                  Icons.calendar_month,
                  size: 32,
                  color: Colors.white,
                ),
                tooltip: ("Ir a la seccion de eventos"),
              ),
              BottomNavigationBarItem(
                backgroundColor: AppColores.primary,
                icon: Icon(
                  Icons.check_box_outline_blank,
                  size: 24,
                  color: Colors.white,
                ),
                label: "Estados",
                activeIcon: Icon(
                  Icons.check_box,
                  size: 32,
                  color: Colors.white,
                ),
                tooltip: ("Ir a la seccion de estados"),
              ),
              BottomNavigationBarItem(
                backgroundColor: AppColores.primary,
                icon: Icon(Icons.send_outlined, size: 24, color: Colors.white),
                label: "Solicitudes",
                activeIcon: Icon(Icons.send, size: 32, color: Colors.white),
                tooltip: ("Ir a la seccion de solicitudes de eventos"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FisicasFriccion extends ScrollPhysics {
  const FisicasFriccion({super.parent});

  @override
  FisicasFriccion applyTo(ScrollPhysics? ancestor) {
    return FisicasFriccion(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics posicion, double offset) {
    return super.applyPhysicsToUserOffset(posicion, offset * 0.5);
  }
}
