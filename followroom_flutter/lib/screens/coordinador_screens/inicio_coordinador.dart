import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/coordinador_screens/detalles_reservacion_coordinador.dart';
import 'package:followroom_flutter/screens/coordinador_screens/subnavbar_coordinador.dart';

class InicioCoordinador extends StatefulWidget {
  const InicioCoordinador({super.key});

  @override
  State<InicioCoordinador> createState() => _InicioCoordinadorState();
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

class _InicioCoordinadorState extends State<InicioCoordinador> {
  int _actualIndice = 0;

  List<Reservacion> reservaciones = [
    Reservacion(
      idReservacion: 1,
      titulo: "Reservacion 2",
      fecha: "ayer",
      hora: "12:00",
      salon: "Federico",
      montaje: "montaje en T",
      equipos: true,
      servicos: true,
      estado: "Por Hacer",
    ),
    Reservacion(
      idReservacion: 2,
      titulo: "Reservacion 1",
      fecha: "antier",
      hora: "13:00",
      salon: "peluche",
      montaje: "banquete",
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
      montaje: "Escenario",
      equipos: false,
      servicos: true,
      estado: "Amueblando",
    ),
    Reservacion(
      idReservacion: 5,
      titulo: "Reservacion 43",
      fecha: "manana",
      hora: "14:00",
      salon: "Federica",
      montaje: "Escenario",
      equipos: false,
      servicos: true,
      estado: "Finalizando",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    String estadoBuscado = "";

    if (_actualIndice == 0) {
      estadoBuscado = "Por Hacer";
    } else if (_actualIndice == 2) {
      estadoBuscado = "Finalizando";
    } else {
      estadoBuscado = "demas";
    }

    final reservacionesFinales = reservaciones.where((res) {
      if (estadoBuscado != "demas") {
        return res.estado == estadoBuscado;
      } else {
        return res.estado != "Por Hacer" || res.estado == "Finalizando";
      }
    }).toList();

    return Column(
      children: [
        Textos(
          texts: ['Por Hacer', 'En Marcha', 'Concluidos'],
          seleccionActual: _actualIndice,
          alSeleccionar: (int nuevoIndice) {
            setState(() {
              _actualIndice = nuevoIndice;
            });
          },
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ListView.builder(
            itemCount: reservacionesFinales.length,
            itemBuilder: (context, index) {
              final itemActual = reservacionesFinales[index];

              return Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaDetallesCoordinador(
                          idReservacion: itemActual.idReservacion.toString(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: ContainerStyles.cardAlmacenista,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                              const SizedBox(width: 30),
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
                              const SizedBox(width: 30),
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
                            ],
                          ),

                          Row(
                            children: [
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
                              Spacer(),
                              Text(
                                "Click en el contenedor para ver detalles del evento",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColores.foreground.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontStyle: FontStyle.italic,
                                ),
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
      ],
    );
  }
}
