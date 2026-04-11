import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/coordinador_screens/estado_salones.dart';
import 'package:followroom_flutter/screens/coordinador_screens/inicio_coordinador.dart';
import 'package:followroom_flutter/screens/coordinador_screens/solicitudes_cliente.dart';
import 'package:followroom_flutter/screens/screens_for_all.dart/manual_screen.dart';
import 'package:followroom_flutter/screens/screens_for_all.dart/perfil_screen.dart';
import 'package:torch_light/torch_light.dart';
import 'package:ambient_light/ambient_light.dart';
import 'dart:async';

class NavegacionBarra extends StatefulWidget {
  const NavegacionBarra({super.key});

  @override
  State<NavegacionBarra> createState() => _NavegacionBarraState();
}

class _NavegacionBarraState extends State<NavegacionBarra> {
  int _indiceSeleccionado = 0;
  bool _navegacionBarra = false;

  final PageController _controladorPagina = PageController();

  bool _taAbiertoDialogo = false;
  final AmbientLight _cantidadLuz = AmbientLight();
  DateTime? _ultimaAlertaSilenciada;
  bool _linternaPrendida = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checaLuz();
    });
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _checaLuz();
      }
    });
  }

  void _checaLuz() async {
    if (_ultimaAlertaSilenciada != null) {
      final diferencia = DateTime.now().difference(_ultimaAlertaSilenciada!);
      if (diferencia.inMinutes < 5) {
        return;
      }
    }
    double? nivelLuz = await _cantidadLuz.currentAmbientLight();
    if (nivelLuz != null && nivelLuz < 5 && !_taAbiertoDialogo && mounted) {
      _mostrarAlerta();
    }
  }

  void _mostrarAlerta() {
    _taAbiertoDialogo = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Ambiente oscuro detectado"),
        content: const Text(
          "El nivel de luz es muy bajo. "
          "Para evitar accidentes, te recomendamos:\n\n"
          "• Encender la linterna del dispositivo\n"
          "• Tener precaución al movilizar equipos\n"
          "• Solicitar ayuda si es necesario",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _silenciarAlerta5Minutos();
            },
            child: const Text("Silenciar 5 min"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _prenderLinterna();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("🔦 Linterna"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Entendido"),
          ),
        ],
      ),
    ).then((_) {
      _taAbiertoDialogo = false;
    });
  }

  void _silenciarAlerta5Minutos() {
    _ultimaAlertaSilenciada = DateTime.now();
  }

  Future<void> _prenderLinterna() async {
    try {
      bool linterna = await TorchLight.isTorchAvailable();
      if (linterna && !_linternaPrendida) {
        await TorchLight.enableTorch();
        setState(() => _linternaPrendida = true);
      } else if (_linternaPrendida) {
        await TorchLight.disableTorch();
        setState(() => _linternaPrendida = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Linterna no disponible")));
      }
    }
  }

  final List<Widget> _pantallas = [
    const InicioCoordinador(),
    const ReservacionesVisualScreen(),
    const PantallaEstadoSalones(),
    const ManualScreen(),
    const Perfil(),
  ];

  final List<String> _titulos = [
    "Panel Coordinador",
    "Solicitudes",
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
                  label: "Solicitudes",
                  activeIcon: Icon(
                    Icons.notifications,
                    size: 32,
                    color: Colors.white,
                  ),
                  tooltip: ("Ir a solicitudes"),
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
