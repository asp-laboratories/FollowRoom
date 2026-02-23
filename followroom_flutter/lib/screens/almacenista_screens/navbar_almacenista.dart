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
      
      appBar: AppBar(title: Text("Almacen"), scrolledUnderElevation: 0, backgroundColor: const Color.fromARGB(255, 255, 255, 255),),

      body: _pantallas[_indiceSeleccionado],
      
      bottomNavigationBar: Theme(

        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),

        child: BottomNavigationBar(

          type: BottomNavigationBarType.shifting,
          currentIndex: _indiceSeleccionado,
          onTap: _alPresionar,

          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 24),
              label: "Eventos",
              activeIcon: Icon(Icons.calendar_month, size: 32),
              tooltip: ("Ir a la seccion de eventos"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outline_blank, size: 24),
              label: "Estados",
              activeIcon: Icon(Icons.check_box, size: 32),
              tooltip: ("Ir a la seccion de estados"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_outlined, size: 24),
              label: "Solicitudes",
              activeIcon: Icon(Icons.send, size: 32),
              tooltip: ("Ir a la seccion de solicitudes de eventos"),
            ),
          ],
        ),

      ),
    );
  
  }

}


