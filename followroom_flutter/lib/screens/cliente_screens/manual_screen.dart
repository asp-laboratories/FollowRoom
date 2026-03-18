import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  decoration: ContainerStyles.cardAlmacenista,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Manual de garantias',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                      
                          Text(
                            "Con el objetivo de garantizar la satisfacción del cliente y la calidad del servicio, el hotel se compromete a cumplir con las siguientes garantías en relación al alquiler de salones para eventos:",
                          style: TextStyle(fontSize: 20, color: Colors.black)
                          ),
                      
                          SizedBox(height: 20),
                      
                          Text(
                            '1. En caso de causar daños a los elementos fisicos el cliente debera pagar el 50% del valor del elemento dañado.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '2. En caso cancelar una reserva a una semana de la fecha de la reserva el cliente no recibira el anticipo initial',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '3. Aplicar descuentos en caso de discoformidades con el servicio prestado.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '4.  El hotel garantiza entregar el salón y sus áreas anexas en perfectas condiciones de mantenimiento, funcionamiento y limpieza.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '5. En caso de incendio, terremoto u otros eventos de fuerza mayor que impidan el uso del salón, el hotel garantiza el reintegro total de las cantidades entregadas.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '6. Garantía de mantener una temperatura confortable en el salón; de lo contrario, se activan protocolos de compensación inmediata.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '7. Se garantiza que los equipamientos han sido probados previamente y funcionarán correctamente.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                      
                          SizedBox(height: 10),
                          Text(
                            'El establecimiento garantiza contar con alumbrado suficiente y sistemas de emergencia para mantener la visibilidad y seguridad',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '9. El salón se configurará exactamente según el plano y estilo de asientos (teatro, escuela, banquete) definido en la Orden de Servicio (BEO).',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '10. Si persisten problemas en el salón, el hotel ofrece un descuento porcentual directo sobre el valor del alquiler del espacio.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '11. Ante fallos críticos que impidan el desarrollo normal de la actividad por culpa del hotel, se garantiza la repetición del evento sin costo para el cliente.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
