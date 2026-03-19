import 'package:flutter/material.dart';
import 'package:followroom_flutter/components/card_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabCanceladosReservacion extends StatelessWidget {
  const TabCanceladosReservacion({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reservaciones = [
      {
        'id': '6',
        'nombre': 'Fiesta Privada',
        'salon': 'Salón Ejecutivo',
        'fecha': '10 de Marzo 2026',
        'hora': '20:00 - 00:00',
      },
      {
        'id': '7',
        'nombre': 'Taller de Cocina',
        'salon': 'Salón Universal',
        'fecha': '12 de Marzo 2026',
        'hora': '11:00 - 14:00',
      },
      {
        'id': '8',
        'nombre': 'Seminario',
        'salon': 'Salón Imperial',
        'fecha': '14 de Marzo 2026',
        'hora': '09:00 - 18:00',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reservaciones.length,
      itemBuilder: (context, index) {
        final r = reservaciones[index];
        return CardReservacion(
          nombreEvento: r['nombre'],
          salon: r['salon'],
          fecha: r['fecha'],
          hora: r['hora'],
          estado: 'Cancelado',
          estadoColor: Colors.red,
          estadoIcono: Icons.cancel,
          cardColor: AppColores.backgroundComponent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesHistorial(idReservacion: r['id']),
              ),
            );
          },
        );
      },
    );
  }
}
