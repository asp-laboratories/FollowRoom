import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/container_styles.dart';

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
      margin: ContainerStyles.marginCardBottom,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: ContainerStyles.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(nombreEvento, style: ContainerStyles.tituloCard),
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
                ContainerStyles.iconCard(Icons.meeting_room),
                SizedBox(width: 6),
                Text(salon, style: ContainerStyles.subtituloCard),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                ContainerStyles.iconCard(Icons.calendar_today),
                SizedBox(width: 6),
                Text(fecha, style: ContainerStyles.subtituloCard),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                ContainerStyles.iconCard(Icons.access_time),
                SizedBox(width: 6),
                Text(hora, style: ContainerStyles.subtituloCard),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
