import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_eventos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/main_reservacion_proceso.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_detalles_reservacion_actual.dart';

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
  final List<Map<String, dynamic>> paquetesDB = [
    {
      'id': 1,
      'nombre': 'Paquete Birthday',
      'descripcion': 'Festeja tu cumpleaños',
      'precio': 1500,
      'icono': Icons.celebration,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'nombre': 'Paquete Corporativo',
      'descripcion': 'Reuniones y conferencias',
      'precio': 2500,
      'icono': Icons.business,
      'color': Colors.purple,
    },
    {
      'id': 3,
      'nombre': 'Paquete Boda',
      'descripcion': 'El día más especial',
      'precio': 5000,
      'icono': Icons.groups,
      'color': Colors.orange,
    },
    {
      'id': 4,
      'nombre': 'Paquete Graduación',
      'descripcion': 'Celebra tu logro',
      'precio': 3000,
      'icono': Icons.school,
      'color': Colors.green,
    },
  ];

  final bool tieneReservacion = true; //widget.salonSeleccionado != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: Container(
            decoration: BoxDecoration(color: AppColores.background2),
            child: Column(
              children: [
                if (tieneReservacion)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 120,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColores.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColores.primary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tienes una reservación pendiente",
                                style: TextEstilos.subtitulos,
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetallesReservacionActual(),
                                    ),
                                  );
                                },
                                style: BotonStyles.botonesAccion,
                                child: Text("Ver detalles"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "No tienes eventos reservados",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColores.backgroundComponent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColores.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColores.primary,
                                AppColores.secundary,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "¡Comienza ahora!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NavigatorEventosReservacion(),
                                    ),
                                  );
                                },
                                style: BotonStyles.botonesAccion,
                                child: Text("Ver eventos"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservacionProceso(),
                                    ),
                                  );
                                },
                                style: BotonStyles.botonesAccion,
                                child: Text("Solicitar reservacion"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                CarouselSlider(
                  options: CarouselOptions(height: 290.0),
                  items: paquetesDB.map((paquete) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: (paquete['color'] as Color).withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                paquete['icono'] as IconData,
                                size: 40,
                                color: paquete['color'] as Color,
                              ),
                              SizedBox(height: 8),
                              Text(
                                paquete['nombre'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(paquete['descripcion'] as String),
                              Text(
                                '\$${paquete['precio']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservacionProceso(),
                                    ),
                                  );
                                },
                                child: Text("Ver más"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
