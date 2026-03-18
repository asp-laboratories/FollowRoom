import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 500,
                decoration: ContainerStyles.cardAlmacenista,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Manual de Uso',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '1. En caso de causar daños a los elementos fisicos el cliente debera pagar el 50% del valor del elemento dañado.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '2. En caso cancelar una reserva a una semana de la fecha de la reserva el cliente no recibira el anticipo inicial',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '3. Aplicar descuentos en caso de discoformidades con el servicio prestado.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '3. Suporte: Se você tiver alguma dúvida ou precisar de ajuda, acesse a seção de Suporte para entrar em contato conosco ou acessar nossa base de conhecimento.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ),
          ],
        )
      ),
    );
  }
}