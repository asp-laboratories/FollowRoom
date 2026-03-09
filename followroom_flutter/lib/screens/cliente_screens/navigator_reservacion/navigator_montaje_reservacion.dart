import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class NavigatorMontajeReservacion extends StatelessWidget {
  const NavigatorMontajeReservacion({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> montajes = [
      {'nombre': 'Auditorio', 'capacidad': 100, 'icono': Icons.meeting_room},
      {'nombre': 'Salón Ejecutivo', 'capacidad': 50, 'icono': Icons.business},
      {
        'nombre': 'Sala de Conferencias',
        'capacidad': 30,
        'icono': Icons.groups,
      },
      {'nombre': 'Terraza', 'capacidad': 80, 'icono': Icons.deck},
      {'nombre': 'Salón Modular', 'capacidad': 120, 'icono': Icons.view_module},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Montaje"),
        backgroundColor: AppColores.primary,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: montajes.length,
        itemBuilder: (context, index) {
          final montaje = montajes[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColores.primary.withValues(alpha: 0.1),
                child: Icon(
                  montaje['icono'] as IconData,
                  color: AppColores.primary,
                ),
              ),
              title: Text(
                montaje['nombre'] as String,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Capacidad: ${montaje['capacidad']} personas"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context, montaje['nombre']);
              },
            ),
          );
        },
      ),
    );
  }
}
