import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/almacenista_screens/estado_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/inicio_almacenista.dart';
import 'package:followroom_flutter/screens/screens_for_all.dart/perfil_screen.dart';
import 'package:followroom_flutter/screens/almacenista_screens/solicitudes_almacenista.dart';
import 'package:ambient_light/ambient_light.dart';
import 'dart:async';

import 'package:torch_light/torch_light.dart';

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
    Perfil(),
  ];

  bool get _esPerfil => _indiceSeleccionado == 3;

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

  Timer? _tempora;
  bool _taAbiertoDialogo = false;

  void _iniciarEscaneo() {
    _tempora = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checaLuz();
    });
  }

  final AmbientLight _cantidadLuz = AmbientLight();
  void _checaLuz() async {
    double? nivelLuz = await _cantidadLuz.currentAmbientLight();
    print("hay un total de: $nivelLuz");
    if (nivelLuz! < 5 && !_taAbiertoDialogo) {
      _mostrarAlerata();
    }
  }

  void _mostrarAlerata() {
    _taAbiertoDialogo = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("E we no hay luz"),
        content: const Text(
          "E we si q hay poca luz, deberias prender la linterna.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ta bien"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ta bien"),
          ),
          TextButton(
            onPressed: _prenderLinterna,
            child: const Text("Ta bien"),
          ),
        ],
      ),
    ).then((_) {
      _taAbiertoDialogo = false;
    });
  }

  bool _linternaPrendida = false;
  Future<void> _prenderLinterna() async {
    try {
      bool litnera = await TorchLight.isTorchAvailable();
      if (litnera && !_linternaPrendida) {
        await TorchLight.enableTorch();
        _linternaPrendida = true;
      } else if (_linternaPrendida) {
        await TorchLight.disableTorch();
        _linternaPrendida = false;
      } else {
        print("Literna no disponible");
      }
    } catch (e) {
      print("Hubo un error $e");
    }
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    _tempora?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _iniciarEscaneo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_esPerfil ? "Perfil" : "Almacen"),
          scrolledUnderElevation: 0,
          backgroundColor: _esPerfil
              ? AppColores.primary
              : AppColores.background2,
          foregroundColor: _esPerfil ? Colors.white : AppColores.foreground,
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
              BottomNavigationBarItem(
                backgroundColor: AppColores.primary,
                icon: Icon(Icons.person_outline, size: 24, color: Colors.white),
                label: "Perfil",
                activeIcon: Icon(Icons.person, size: 32, color: Colors.white),
                tooltip: ("Ir al perfil"),
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
