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
  List<Map<String, dynamic>> tiposMontaje = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTiposMontaje();
  }

  Future<void> _cargarTiposMontaje() async {
    try {
      final data = await _montajeService.getTipoMontaje();
      setState(() {
        tiposMontaje = data;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar tipos de montaje: $e');
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
              itemCount: tiposMontaje.length,
              itemBuilder: (context, index) {
                final tipo = tiposMontaje[index];
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
                      tipo['nombre'] ?? 'Sin nombre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context, {
                        'nombre': tipo['nombre'],
                        'id': tipo['id'],
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
