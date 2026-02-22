import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

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
      child: Row(
        children: [
          Text("Hacer una reservacion"),

          ElevatedButton(onPressed: () {}, child: Icon(Icons.add)),
        ],
      ),
    );
  }
}
