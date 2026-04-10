import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/services/montaje_service.dart';

class NavigatorMontajeReservacion extends StatefulWidget {
  const NavigatorMontajeReservacion({super.key});

  @override
  State<NavigatorMontajeReservacion> createState() =>
      _NavigatorMontajeReservacionState();
}

class _NavigatorMontajeReservacionState
    extends State<NavigatorMontajeReservacion> {
  final MontajeService _montajeService = MontajeService();
  List<Map<String, dynamic>> montajes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMontajes();
  }

  Future<void> _cargarMontajes() async {
    try {
      final data = await _montajeService.getMontajes();
      setState(() {
        montajes = data;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar montajes: $e');
      setState(() {
        _cargando = false;
      });
    }
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
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: montajes.length,
              itemBuilder: (context, index) {
                final tipo = montajes[index];
                final mobiliarios = tipo['montaje_mobiliario'] as List? ?? [];

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColores.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.meeting_room,
                        color: AppColores.primary,
                      ),
                    ),
                    title: Text(
                      tipo['tipo_montaje_nombre'] ??
                          tipo['nombre'] ??
                          'Sin nombre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      mobiliarios.isNotEmpty
                          ? "${mobiliarios.length} mobiliarios sugeridos"
                          : "Sin mobiliarios",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context, {
                        'nombre': tipo['tipo_montaje_nombre'] ?? tipo['nombre'],
                        'id': tipo['id'],
                        'mobiliarios_sugeridos': mobiliarios,
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
