import 'package:flutter/material.dart';
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
    required this.estado

  });

}

class _InicioAlmacenistaState extends State<InicioAlmacenista> {
  int _actualIndice = 0;

  List<Reservacion> reservaciones = [
    Reservacion(
      idReservacion: 1,
      titulo: "REservacion 2",
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
      titulo: "REservacon 1",
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

    // Esta parte se tiene q actualizar para q solo mande los chidos de la abse de datos, estos datos y asi fueron pa probar
    String estadoBuscado = "";
    
    if (_actualIndice == 0) {
      estadoBuscado = "Por Hacer";
    } else if (_actualIndice == 2) {
      estadoBuscado = "Finalziando";
    } else {
      estadoBuscado = "demas";
    }

    final reservacionesFinales = reservaciones.where( (res) {
      if (estadoBuscado != "demas") {
        return res.estado == estadoBuscado;
      } else {
        return res.estado != "Por Hacer" || res.estado == "Finalziando";
      }
    }).toList();

    return Column(
      children: [ 
        
        // Esta funcion crea la subbarra que se genera arriba, requiere 3 parametros, los contenidos de las secciones
        // el indice de la pantalla o seccion actual, y una funcion a ejecutar cuando se cambie, en esta misma se cambia
        // el indice seleccionado 
        Textos(
          
          texts: ['Por Hacer', 'En Marcha', 'Concluidos'],
          
          seleccionActual: _actualIndice,
          
          alSeleccionar: (int nuevoIndice) {
            setState(() {
              _actualIndice = nuevoIndice;

            });
          }, 
        ),

        // seccion de cambio de acuerdo al indice actual
        // La presentacion en cuanto a distribucion se hace desde aca

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
                      builder: (context) => PantallaDetalles(idReservacion: itemActual.idReservacion.toString()),
              
                    ),
              
                  );
              
                  },
              
                  child: Container(
                
                    height: 200,
                    width: double.infinity,
              
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 3,
              
                      ),
                    ),
              
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
              
                        children: [
                          Text(
                            "Titulo ${itemActual.titulo}",
                          ),
              
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_outlined),
                                  Text(" Fecha: ${itemActual.fecha}")
                                ],
                              ),
                              const SizedBox(width: 50,),
                              Row(
                                children: [
                                  Icon(Icons.alarm),
                                  Text(" Hora: ${itemActual.hora}")
                                ],
                              ),
                            ],
                          ),
              
                          Row(
                            children: [
                              Text("Salon: ${itemActual.salon}"),
                              const SizedBox(width: 50,),
                              Text("Montaje: ${itemActual.montaje}")
                            ],
                          ),
              
                          Row(
                            children: [
                                Text("Equipamientos:"),
                                itemActual.equipos 
                                  ? const Icon(Icons.check, color: Colors.green) 
                                  : const Icon(Icons.close, color: Colors.red),
                            ],
                          ),
              
                          Row(
                            children: [
                              Row(
                                children: [
                                Text("Servicios:"),
                                itemActual.servicos 
                                  ? const Icon(Icons.check, color: Colors.green) 
                                  : const Icon(Icons.close, color: Colors.red),
                                ],
                                ),
                                Spacer(),
                                Text("Detalles >"),
              
                            ],
              
                          ),
              
                        ],
                        
                      ),
                        
                    )
                        
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

