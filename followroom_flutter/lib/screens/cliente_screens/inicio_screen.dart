import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_eventos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/reservacion_proceso.dart';

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
  // Simulación de datos que vendrían de una base de datos
  final List<Map<String, dynamic>> paquetesDB = [
    {
      'id': 1,
      'nombre': 'Paquete Birthday',
      'descripcion': 'Festeja tu cumpleaños',
      'precio': 1500,
      'icono': Icons.celebration,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'nombre': 'Paquete Corporativo',
      'descripcion': 'Reuniones y conferencias',
      'precio': 2500,
      'icono': Icons.business,
      'color': Colors.purple,
    },
    {
      'id': 3,
      'nombre': 'Paquete Boda',
      'descripcion': 'El día más especial',
      'precio': 5000,
      'icono': Icons.groups,
      'color': Colors.orange,
    },
    {
      'id': 4,
      'nombre': 'Paquete Graduación',
      'descripcion': 'Celebra tu logro',
      'precio': 3000,
      'icono': Icons.school,
      'color': Colors.green,
    },
    {
      'id': 5,
      'nombre': 'Paquete Prueba',
      'descripcion': 'Celebra tu PRUEBA',
      'precio': 3000,
      'icono': Icons.school,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColores.backgroundComponent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              height: 120,
              child: Row(
                children: [


                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservacionProceso(),
                        ),
                      );
                    },
                    child: Text("Solicitar reservacion"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigatorEventosReservacion(),
                        ),
                      );
                    },
                    child: Text("Ver eventos"),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Carousel generado dinámicamente desde la "base de datos"
          CarouselSlider(
            options: CarouselOptions(height: 180.0),
            items: paquetesDB.map((paquete) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: (paquete['color'] as Color).withAlpha(51),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          paquete['icono'] as IconData,
                          size: 40,
                          color: paquete['color'] as Color,
                        ),
                        SizedBox(height: 8),
                        Text(
                          paquete['nombre'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(paquete['descripcion'] as String),
                        Text(
                          '\$${paquete['precio']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Aquí podrías pasar el paquete seleccionado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservacionProceso(),
                              ),
                            );
                          },
                          child: Text("Ver más"),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
