import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/manual_screen.dart';
import 'package:followroom_flutter/screens/cliente_screens/reservacion_estado.dart';
import 'package:followroom_flutter/screens/cliente_screens/solicitudes_screen.dart';

class FollowRoom extends StatefulWidget {
  const FollowRoom({super.key});

  @override
  State<FollowRoom> createState() => _FollowRoomState();
}

class _FollowRoomState extends State<FollowRoom> {
  int _indiceSeleccionado = 0;

  final List<Widget> _pantallas = [
    Reservacion(),
    ReservacionEstado(),
    HistorialScreen(),
    SolicitudesScreen(),
    ManualScreen()
  ];

  void _alPresionar(int indice){
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("data"),),
      body: _pantallas[_indiceSeleccionado],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceSeleccionado,
        onTap: _alPresionar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Reservacion",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: "Estado",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sms),
            label: "Solicitar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: "Manual",
          ),
        ],
      ),
    );
  }
}

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}