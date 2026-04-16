import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
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

  final List<String> _titulos = ["Almacen", "Estados", "Solicitudes", "Perfil"];

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
    if (_ultimaAlertaSilenciada != null) {
      final diferencia = DateTime.now().difference(_ultimaAlertaSilenciada!);
      if (diferencia.inMinutes < 5) {
        return;
      }
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Ambiente oscuro",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "El nivel de luz en el almacén es muy bajo. Para evitar accidentes, te recomendamos:",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildRecomendacion(
                Icons.flashlight_on,
                "Encender la linterna del dispositivo",
              ),
              _buildRecomendacion(
                Icons.visibility,
                "Tener precaución al movilizar equipos",
              ),
              _buildRecomendacion(
                Icons.support_agent,
                "Solicitar ayuda si es necesario",
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _silenciarAlerta5Minutos();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Silenciar 5 min",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _prenderLinterna();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flashlight_on, size: 18),
                SizedBox(width: 4),
                Text("Linterna"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Entendido"),
          ),
        ],
      ),
    ).then((_) {
      _taAbiertoDialogo = false;
    });
  }

  Widget _buildRecomendacion(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColores.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _ultimaAlertaSilenciada;
  void _silenciarAlerta5Minutos() {
    _ultimaAlertaSilenciada = DateTime.now();
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
          title: Text(
            _titulos[_indiceSeleccionado],
            style: TextEstilos.encabezados,
          ),
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
