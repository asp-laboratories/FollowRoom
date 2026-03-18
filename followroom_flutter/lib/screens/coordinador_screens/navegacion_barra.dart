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
  bool _navegacionBarra = false;

  final PageController _controladorPagina = PageController();

  final List<Widget> _pantallas = [
    const InicioCoordinador(),
    const Center(child: Text("Notificaciones")),
    const Center(child: Text("Mensajes")),
    const Center(child: Text("Pagos")),
    const Center(child: Text("Perfil")),
  ];

  final List<String> _titulos = [
    "Panel Coordinador",
    "Notificaciones",
    "Salones",
    "Manual de garantias",
    "Perfil",
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
          backgroundColor: AppColores.background2,
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
                  icon: Icon(Icons.work_outline, size: 24, color: Colors.white),
                  label: "Panel",
                  activeIcon: Icon(Icons.work, size: 32, color: Colors.white),
                  tooltip: ("Ir al panel"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Notificaciones",
                  activeIcon: Icon(
                    Icons.notifications,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir a notificaciones"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.meeting_room_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  activeIcon: Icon(
                    Icons.meeting_room,
                    size: 32,
                    color: Colors.white,
                  ),
                  label: "Salones",
                  tooltip: ("Ir a salones"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.description_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Manual de garantias",
                  activeIcon: Icon(
                    Icons.description,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir a Manual de Garantias"),
                ),
                BottomNavigationBarItem(
                  backgroundColor: AppColores.primary,
                  icon: Icon(
                    Icons.person_outline,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: "Perfil",
                  activeIcon: Icon(Icons.person, size: 32, color: Colors.white),
                  tooltip: ("Ir al perfil"),
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
