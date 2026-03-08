import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';

class TabClienteReservacion extends StatefulWidget {

    final Function(Map<String, String>) onDatosChanged;

  const TabClienteReservacion({super.key, required this.onDatosChanged});

  @override
  State<TabClienteReservacion> createState() => _TabClienteReservacionState();
}

class _TabClienteReservacionState extends State<TabClienteReservacion> {

final TextEditingController nombre = TextEditingController();
final TextEditingController apellidoPaterno= TextEditingController();
final TextEditingController apellidoMaterno = TextEditingController();
final TextEditingController rfc = TextEditingController();
final TextEditingController nombreFiscal = TextEditingController();
final TextEditingController telefono = TextEditingController();
final TextEditingController correoElectronico = TextEditingController();
final TextEditingController colonia = TextEditingController();
final TextEditingController calle = TextEditingController();
final TextEditingController numero = TextEditingController();








  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text("Datos personales", style: TextEstilos.subtitulos,),
              Container(
                width: double.infinity,
                // decoration: BoxDecoration(color: AppColores.primary),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      TextField(
                        controller: nombre,
                        decoration: createAppDecoration(
                          labelText: 'Ingresar nombre',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      
                      TextField(
                        controller: apellidoPaterno,
                        decoration: createAppDecoration(
                          labelText: 'Apellido paterno',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      
                      TextField(
                        controller: apellidoMaterno,
                        decoration: createAppDecoration(
                          labelText: 'Apellido materno',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      
                      TextField(
                        controller: rfc,
                        decoration: createAppDecoration(
                          labelText: 'RFC',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),
                    
                      TextField(
                        controller: nombreFiscal,
                        decoration: createAppDecoration(
                          labelText: 'Nombre fiscal',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text("Contacto", style: TextEstilos.subtitulos),
              Container(
                width: double.infinity,
                // decoration: BoxDecoration(color: AppColores.primary),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      TextField(
                        controller: telefono,
                        decoration: createAppDecoration(
                          labelText: 'Telefono',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      
                      TextField(
                        controller: correoElectronico,
                        decoration: createAppDecoration(
                          labelText: 'Correo electronico',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text("Direccion", style: TextEstilos.subtitulos),

              Container(
                width: double.infinity,
                // decoration: BoxDecoration(color: AppColores.primary), 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),

                      TextField(
                        controller: colonia,
                        decoration: createAppDecoration(
                          labelText: 'Colonia',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),

                      TextField(
                        controller: calle,
                        decoration: createAppDecoration(
                          labelText: 'Calle',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      const SizedBox(height: 10,),

                      TextField(
                        controller: numero,
                        decoration: createAppDecoration(
                          labelText: 'Numero',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ElevatedButton(
              onPressed: () {
                widget.onDatosChanged({
                  'nombre' : nombre.text,
                  'apellidoPaterno' : apellidoPaterno.text,
                  'apellidoMaterno' : apellidoMaterno.text,
                  'rfc' : rfc.text,
                  'nombreFiscal' : nombreFiscal.text,
                  'telefono' : telefono.text,
                  'correoElectronico' : correoElectronico.text,
                  'colonia' : colonia.text,
                  'calle' : calle.text,
                  'numero' : numero.text,

                });
              },
              child: Text("Guardar datos"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
