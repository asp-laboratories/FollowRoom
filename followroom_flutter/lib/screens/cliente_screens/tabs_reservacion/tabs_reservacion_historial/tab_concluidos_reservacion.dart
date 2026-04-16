import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';
import 'package:followroom_flutter/services/historial_service.dart';

class TabConcluidosReservacion extends StatefulWidget {
  const TabConcluidosReservacion({super.key});

  @override
  State<TabConcluidosReservacion> createState() =>
      _TabConcluidosReservacionState();
}

class _TabConcluidosReservacionState extends State<TabConcluidosReservacion> {
  final HistorialService _historialService = HistorialService();
  List<Map<String, dynamic>> _reservaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReservaciones();
  }

  Future<void> _cargarReservaciones() async {
    try {
      final datos = await _historialService.getMisReservaciones();
      if (mounted) {
        setState(() {
          _reservaciones = datos.where((r) {
            final estado = r['estado_codigo'] ?? '';
            return estado == 'FIN' || estado == 'TERMI' || estado == 'CONF';
          }).toList();
          _reservaciones.sort((a, b) {
            final ordenA = _getOrden(a['estado_codigo'] ?? '');
            final ordenB = _getOrden(b['estado_codigo'] ?? '');
            return ordenB - ordenA;
          });
          print(
            'DEBUG: Reservaciones concluidas: ${_reservaciones.map((r) => '${r['nombre']}:${r['estado_codigo']}').toList()}',
          );
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Center(child: CircularProgressIndicator());
    }

    if (_reservaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes reservaciones concluidas',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          itemCount: _reservaciones.length,
          itemBuilder: (context, index) {
            final r = _reservaciones[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: ContainerStyles.sombreado,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetallesHistorial(idReservacion: r['id'] as int),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r['nombre'] ?? 'Sin título',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(
                                  r['estado_codigo'] ?? '',
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getBadgeIcon(r['estado_codigo'] ?? ''),
                                    size: 14,
                                    color: _getBadgeColor(
                                      r['estado_codigo'] ?? '',
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    r['estado_nombre'] ?? 'Concluido',
                                    style: TextStyle(
                                      color: _getBadgeColor(
                                        r['estado_codigo'] ?? '',
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              r['salon_nombre'] ?? 'Sin salón',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatearFecha(r['fecha']),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (r['hora_inicio'] != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${_formatearHora(r['hora_inicio'])} - ${_formatearHora(r['hora_fin'])}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'Sin fecha';
    try {
      final parts = fecha.split('-');
      if (parts.length == 3) {
        return '${parts[2]} de ${_mes(parts[1])} de ${parts[0]}';
      }
    } catch (e) {}
    return fecha;
  }

  String _formatearHora(String? hora) {
    if (hora == null) return '';
    try {
      final parts = hora.split(':');
      if (parts.length >= 2) {
        int h = int.parse(parts[0]);
        final m = parts[1];
        final period = h >= 12 ? 'PM' : 'AM';
        if (h > 12) h -= 12;
        if (h == 0) h = 12;
        return '$h:$m $period';
      }
    } catch (e) {}
    return hora;
  }

  String _mes(String m) {
    final meses = {
      '01': 'Enero',
      '02': 'Febrero',
      '03': 'Marzo',
      '04': 'Abril',
      '05': 'Mayo',
      '06': 'Junio',
      '07': 'Julio',
      '08': 'Agosto',
      '09': 'Septiembre',
      '10': 'Octubre',
      '11': 'Noviembre',
      '12': 'Diciembre',
    };
    return meses[m] ?? m;
  }

  int _getOrden(String estado) {
    switch (estado) {
      case 'FIN':
        return 3;
      case 'TERMI':
        return 2;
      case 'CONF':
        return 1;
      default:
        return 0;
    }
  }

  Color _getBadgeColor(String estado) {
    switch (estado) {
      case 'FIN':
        return Colors.green;
      case 'TERMI':
        return Colors.green;
      case 'CONF':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  IconData _getBadgeIcon(String estado) {
    switch (estado) {
      case 'FIN':
        return Icons.check_circle;
      case 'TERMI':
        return Icons.check_circle;
      case 'CONF':
        return Icons.check_circle;
      default:
        return Icons.check_circle;
    }
  }
}
