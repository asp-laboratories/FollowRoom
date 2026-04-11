import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class TabFinalizadasReservacion extends StatefulWidget {
  final String rfc;
  const TabFinalizadasReservacion({super.key, required this.rfc});

  @override
  State<TabFinalizadasReservacion> createState() =>
      _TabFinalizadasReservacionState();
}

class _TabFinalizadasReservacionState extends State<TabFinalizadasReservacion>
    with AutomaticKeepAliveClientMixin {
  final ReservacionService _servicioReservaciones = ReservacionService();

  List<Map<String, dynamic>> reservaciones = [];
  bool loading = true;

  Future<void> _cargarReservaciones() async {
    List<Map<String, dynamic>> reservacionesObtenidas;
    try {
      reservacionesObtenidas = await _servicioReservaciones
          .getReservacionesCliente(widget.rfc, 'FINAL');
    } catch (e) {
      reservacionesObtenidas = [];
    }
    setState(() {
      reservaciones = reservacionesObtenidas;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarReservaciones();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (loading) {
      return Container(
        color: AppColores.background2,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (reservaciones.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarReservaciones,
        color: AppColores.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              color: AppColores.background2,height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'No tienes reservaciones finalizadas.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarReservaciones,
      color: AppColores.primary,
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          itemCount: reservaciones.length,
          itemBuilder: (context, index) {
            final r = reservaciones[index];
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
                            DetallesHistorial(idReservacion: r['id']),
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
                                r['nombreEvento'],
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
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Finalizado',
                                    style: TextStyle(
                                      color: Colors.green,
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
                              r['montaje']['salon']['nombre'],
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
                              r['fechaEvento'],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
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
                              "${r['horaInicio']} - ${r['horaFin']}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
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
}
