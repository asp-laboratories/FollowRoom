import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/almacenista_screens/detalles_reservacion.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';

class InicioAlmacenista extends StatefulWidget {
  const InicioAlmacenista({super.key});

  @override
  State<InicioAlmacenista> createState() => _InicioAlmacenistaState();
}

class Reservacion {
  final int idReservacion;
  final String titulo;
  final String fecha;
  final String hora;
  final String salon;
  final String montaje;
  final bool equipos;
  final bool servicos;
  final String estado;

  Reservacion({
    required this.idReservacion,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.salon,
    required this.montaje,
    required this.equipos,
    required this.servicos,
    required this.estado,
  });
}

class _InicioAlmacenistaState extends State<InicioAlmacenista> {
  int _actualIndice = 0;

  List<Reservacion> reservaciones = [
    Reservacion(
      idReservacion: 1,
      titulo: "Reservacion 2",
      fecha: "ayer",
      hora: "12:00",
      salon: "Federico",
      montaje: "menotaje en T",
      equipos: true,
      servicos: true,
      estado: "Por Hacer",
    ),
    Reservacion(
      idReservacion: 2,
      titulo: "Reservacon 1",
      fecha: "antier",
      hora: "13:00",
      salon: "peluche",
      montaje: "banmquete",
      equipos: false,
      servicos: false,
      estado: "Concluido",
    ),
    Reservacion(
      idReservacion: 3,
      titulo: "Reservacion 43",
      fecha: "manana",
      hora: "14:00",
      salon: "Federica",
      montaje: "Enbestida",
      equipos: false,
      servicos: true,
      estado: "Amueblando",
    ),
    Reservacion(
      idReservacion: 5,
      titulo: "Reser5acion 43",
      fecha: "manana",
      hora: "14:00",
      salon: "Federica",
      montaje: "Enbestida",
      equipos: false,
      servicos: true,
      estado: "Finalziando",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    String estadoBuscado = "";

    if (_actualIndice == 0) {
      estadoBuscado = "Por Hacer";
    } else if (_actualIndice == 2) {
      estadoBuscado = "Finalziando";
    } else {
      estadoBuscado = "demas";
    }

    final reservacionesFinales = reservaciones.where((res) {
      if (estadoBuscado != "demas") {
        return res.estado == estadoBuscado;
      } else {
        return res.estado != "Por Hacer" || res.estado == "Finalziando";
      }
    }).toList();

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Textos(
                texts: const ['Por Hacer', 'En Marcha', 'Concluidos'],
                seleccionActual: _actualIndice,
                alSeleccionar: (int nuevoIndice) {
                  setState(() {
                    _actualIndice = nuevoIndice;
                  });
                },
              ),
            ),
            const SizedBox(width: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reservacionesFinales.length,
              itemBuilder: (context, index) {
                final itemActual = reservacionesFinales[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaDetalles(
                              idReservacion: itemActual.idReservacion
                                  .toString(),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Titulo: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  itemActual.titulo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColores.foreground,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Fecha: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual.fecha,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.alarm,
                                  color: AppColores.foreground,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Hora: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual.hora,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Salon: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual.salon,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Montaje: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual.montaje,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Equipamientos: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                itemActual.equipos
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      )
                                    : const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                const SizedBox(width: 16),
                                Text(
                                  "Servicios: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                itemActual.servicos
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      )
                                    : const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Click para ver detalles del evento",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColores.foreground.withValues(
                                  alpha: 0.9,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
