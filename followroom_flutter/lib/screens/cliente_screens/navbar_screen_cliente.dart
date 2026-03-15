import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/inicio_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/manual_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/solicitudes_screen.dart';

class FollowRoom extends StatefulWidget {
  const FollowRoom({super.key});

  @override
  State<FollowRoom> createState() => _FollowRoomState();
}

class _FollowRoomState extends State<FollowRoom> {
  int _indiceSeleccionado = 0;
  bool _navegacionBarra = false;

  final PageController _controladorPagina = PageController();

  final List<Widget> _pantallas = [
    Reservacion(),
    HistorialScreen(),
    SolicitudesScreen(),
    ManualScreen(),
  ];

  final List<String> _titulos = [
    "Bienvenido",
    "Historial",
    "Solicitudes extra",
    "Manual",
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
          title: Text(
            _titulos[_indiceSeleccionado],
            style: TextEstilos.encabezados,
          ),
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
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
        bottomNavigationBar: Container(
          height: 80,
          child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              currentIndex: _indiceSeleccionado,
              onTap: _alPresionar,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Reservación",
                  activeIcon: Icon(
                    Icons.calendar_month,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir a reservación"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.history_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Historial",
                  activeIcon: Icon(
                    Icons.history,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir a historial"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(Icons.sms_outlined, size: 24, color: Colors.white),
                  label: "Solicitudes",
                  activeIcon: Icon(Icons.sms, size: 32, color: Colors.white),
                  tooltip: ("Ir a solicitudes"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.menu_book_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Manual",
                  activeIcon: Icon(
                    Icons.menu_book,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir al manual"),
                ),
              ],
            ),
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
