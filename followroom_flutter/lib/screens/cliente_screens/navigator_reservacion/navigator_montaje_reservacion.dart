import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/services/tipo_montaje_service.dart';

class NavigatorMontajeReservacion extends StatefulWidget {
  final int salon_id;

  const NavigatorMontajeReservacion({super.key, required this.salon_id});

  @override
  State<NavigatorMontajeReservacion> createState() =>
      _NavigatorMontajeReservacionState();
}

class _NavigatorMontajeReservacionState
    extends State<NavigatorMontajeReservacion> {
  final TipoMontajeService _servicioMontajes = TipoMontajeService();
  late Future<List<Map<String, dynamic>>> _tipos_montajes;

  @override
  void initState() {
    super.initState();
    _tipos_montajes = _servicioMontajes.getMontajesPorSalon(widget.salon_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Montaje"),
        backgroundColor: AppColores.background2,
        foregroundColor: AppColores.foreground,
      ),

      backgroundColor: AppColores.background2,

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tipos_montajes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final montajeschidos = snapshot.data ?? [];

          if (montajeschidos.isEmpty) {
            return const Center(
              child: Text("No se encontraron montajes para este salon"),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: montajeschidos.length,
            itemBuilder: (context, index) {
              final montaje = montajeschidos[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColores.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.build,
                      color: AppColores.primary,
                    ),
                  ),
                  title: Text(
                    montaje['nombre'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Capacidad: ${montaje['capacidadIdeal']} personas"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context, montaje);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
