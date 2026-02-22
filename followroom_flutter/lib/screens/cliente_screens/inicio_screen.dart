import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:followroom_flutter/screens/cliente_screens/reservacion_proceso.dart';

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
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
                  Text("Reservar"),

                  Text("Hacer una reservacion"),
            
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservacionProceso(),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          CarouselSlider(
            options: CarouselOptions(height: 140.0),
            items: [1, 2, 3, 4, 5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(color: Colors.amber),
                    child: Column(
                      children: [
                        Text('Paquete $i', style: TextStyle(fontSize: 16.0)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservacionProceso(),
                              ),
                            );
                          },
                          child: Icon(Icons.add),
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
