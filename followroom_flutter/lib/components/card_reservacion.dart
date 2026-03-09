import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class CardReservacion extends StatelessWidget {
  final String nombreEvento;
  final String salon;
  final String fecha;
  final String hora;
  final String estado;
  final Color estadoColor;
  final IconData estadoIcono;

  const CardReservacion({
    super.key,
    required this.nombreEvento,
    required this.salon,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.estadoColor,
    required this.estadoIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreEvento,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColores.foreground,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(estadoIcono, size: 14, color: estadoColor),
                      SizedBox(width: 4),
                      Text(
                        estado,
                        style: TextStyle(
                          color: estadoColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.meeting_room, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(salon, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(fecha, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(hora, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
