import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'dart:async';
import 'detalles_montaje.dart';

class PantallaDetalles extends StatefulWidget {
  final String idReservacion;

  const PantallaDetalles({super.key, required this.idReservacion});

  @override
  State<PantallaDetalles> createState() => _PantallaDetallesState();
}

class _PantallaDetallesState extends State<PantallaDetalles> {
  bool _cargando = true;
  String _puntos = ".";
  Timer? _timerPuntos;

  Map<String, dynamic>? _datosCompletos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _iniciarAnimacion();
    _descargarDatos();
  }

  void _iniciarAnimacion() {
    _timerPuntos = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_puntos == "...") {
          _puntos = ".";
        } else {
          _puntos += ".";
        }
      });
    });
  }

  Future<void> _descargarDatos() async {
    // Logica pa recibir los datos de la base de datos
    await Future.delayed(const Duration(seconds: 1));

    final datoPruebas = {
      'descripcionEvento': "fiesta pa mi sobrino q cumple 18",
      'invitados': 100,
      'fechaEvento': "18-12-2027",
      'horainicio': "12:00 AM",
      'cliente': 'Mi papa',
      'tipoCliente': "Persona fisica",
      'telefono': "666 6666 66 66",
      'email': "mimamamemima@tucola.com",
      'tipoMontaje': "Herradura",
      'nombreSalon': "paquito",
      'servicios': [
        {'nombre': 'Guardias'},
        {'nombre': "Decoradores"},
        {'nombre': "Meseros"},
        {'nombre': "Limpieza"},
      ],
      'equipos': [
        {'nombre': "Microfono"},
        {'nombre': "Equipo Audiovisual"},
        {'nombre': "Televisor"},
      ],
    };

    if (!mounted) return;

    setState(() {
      _datosCompletos = datoPruebas;
      _cargando = false;
    });

    _timerPuntos?.cancel();
  }

  @override
  void dispose() {
    //TODO: implement dispose
    _timerPuntos?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Usamos widget.idReservacion para mostrar el ID en el título
        title: Text('Detalles de Reserva ${widget.idReservacion}'),
      ),

      // Todo lo que ya tenías hecho, lo metemos en el 'body'
      body: _cargando
          ? Center(
              child: Text(
                'Cargando $_puntos',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),

                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Evento"),
                              const SizedBox(height: 5),
                              Text(
                                "Descripcion: ${_datosCompletos?['descripcionEvento']}",
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Total de asistentes: ${_datosCompletos?['invitados']}",
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Fecha: ${_datosCompletos?['fechaEvento']}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Hora de Inicio: ${_datosCompletos?['horainicio']}",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cliente"),
                            const SizedBox(height: 5),
                            Text("Nombre: ${_datosCompletos?['cliente']}"),
                            const SizedBox(height: 5),
                            Text(
                              "Tipo de Cliente: ${_datosCompletos?['tipoCliente']}",
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Telefono: ${_datosCompletos?['telefono']}",
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Correo: ${_datosCompletos?['email']}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detalles(
                              numeroReservacion: widget.idReservacion,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey,
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Montaje del salon"),
                              SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tipo de Montaje: ${_datosCompletos?['tipoMontaje']}",
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Salon: ${_datosCompletos?['nombreSalon']}",
                                      ),
                                      Spacer(),
                                      Text(
                                        "Detalles >",
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            209,
                                            208,
                                            208,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text('Servicios'),
                                  SizedBox(height: 5),

                                  ..._datosCompletos?['servicios'].map((
                                    servicio,
                                  ) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_right,
                                          color: AppColores.foreground,
                                        ),
                                        Expanded(
                                          child: Text(servicio['nombre']),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text('equipamietos'),
                                  SizedBox(height: 15),
                                  ..._datosCompletos?['equipos'].map((
                                    servicio,
                                  ) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_right,
                                          color: AppColores.foreground,
                                        ),
                                        Expanded(
                                          child: Text(servicio['nombre']),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
