import 'package:flutter/material.dart';
import 'package:followroom_flutter/screens/almacenista_screens/estado_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/inicio_almacenista.dart';
import 'package:followroom_flutter/screens/almacenista_screens/solicitudes_almacenista.dart';


class Almacen extends StatefulWidget {
  const Almacen({super.key});

  @override
  State<Almacen> createState() => _AlmacenState();
}

class _AlmacenState extends State<Almacen> {
  int _indiceSeleccionado = 0;

  final List<Widget> _pantallas = [
    InicioAlmacenista(),
    AlmacenistaEstadoScreen(),
    AlmacenistaSolicitudesScreen()
  ];

  void _alPresionar(int indice){
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Almacen"),),
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
            icon: Icon(Icons.sms),
            label: "Solicitar",
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


