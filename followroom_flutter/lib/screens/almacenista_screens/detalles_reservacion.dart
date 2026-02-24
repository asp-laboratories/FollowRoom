import 'package:flutter/material.dart';
import 'dart:async';


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
    await Future.delayed(const Duration(seconds: 3));

    final datoPruebas = {
      'cliente': 'Mi papa',
      'invitados': 100,
      'comentarios': 'Cositas',
      'estado_pago': 'pagao',
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
    // TODO: implement dispose
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
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text("evento"),
                    ),
                  ),
                
                  const SizedBox(height: 10,),
                
                  Container(
          
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey,
          
                    ),
                    width: double.infinity,
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text("cliente"),
                    ),
                  ),
                
                  const SizedBox(height: 10,),
                
                  Container(
          
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey,
          
                    ),
                    width: double.infinity,
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text("montaje del salon"),
                    ),
                  ),
                
                  const SizedBox(height: 10,),
          
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                            
                          ),
                            
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text('Servicios'),
                            
                          ),
                            
                        ),
                            
                      ),
                            
                      const SizedBox(width: 20,),
                            
                      Expanded(
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                            
                          ),
                            
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text('equipamietos'),
                            
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