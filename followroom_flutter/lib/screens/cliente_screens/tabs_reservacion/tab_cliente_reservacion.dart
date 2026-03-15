import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';

class TabClienteReservacion extends StatefulWidget {
  final Function(Map<String, String>) onDatosChanged;
  final VoidCallback? onSaveAndNext;

  const TabClienteReservacion({
    super.key,
    required this.onDatosChanged,
    this.onSaveAndNext,
  });

  @override
  State<TabClienteReservacion> createState() => _TabClienteReservacionState();
}

class _TabClienteReservacionState extends State<TabClienteReservacion> {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidoPaterno = TextEditingController();
  final TextEditingController apellidoMaterno = TextEditingController();
  final TextEditingController rfc = TextEditingController();
  final TextEditingController nombreFiscal = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController correoElectronico = TextEditingController();
  final TextEditingController colonia = TextEditingController();
  final TextEditingController calle = TextEditingController();
  final TextEditingController numero = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombre.addListener(_autoSave);
    apellidoPaterno.addListener(_autoSave);
    apellidoMaterno.addListener(_autoSave);
    rfc.addListener(_autoSave);
    nombreFiscal.addListener(_autoSave);
    telefono.addListener(_autoSave);
    correoElectronico.addListener(_autoSave);
    colonia.addListener(_autoSave);
    calle.addListener(_autoSave);
    numero.addListener(_autoSave);
  }

  @override
  void dispose() {
    nombre.removeListener(_autoSave);
    apellidoPaterno.removeListener(_autoSave);
    apellidoMaterno.removeListener(_autoSave);
    rfc.removeListener(_autoSave);
    nombreFiscal.removeListener(_autoSave);
    telefono.removeListener(_autoSave);
    correoElectronico.removeListener(_autoSave);
    colonia.removeListener(_autoSave);
    calle.removeListener(_autoSave);
    numero.removeListener(_autoSave);
    nombre.dispose();
    apellidoPaterno.dispose();
    apellidoMaterno.dispose();
    rfc.dispose();
    nombreFiscal.dispose();
    telefono.dispose();
    correoElectronico.dispose();
    colonia.dispose();
    calle.dispose();
    numero.dispose();
    super.dispose();
  }

  void _autoSave() {
    widget.onDatosChanged({
      'nombre': nombre.text,
      'apellidoPaterno': apellidoPaterno.text,
      'apellidoMaterno': apellidoMaterno.text,
      'rfc': rfc.text,
      'nombreFiscal': nombreFiscal.text,
      'telefono': telefono.text,
      'correoElectronico': correoElectronico.text,
      'colonia': colonia.text,
      'calle': calle.text,
      'numero': numero.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColores.background2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text("Datos personales", style: TextEstilos.subtitulos),
                Container(
                  width: double.infinity,
                  // decoration: BoxDecoration(color: AppColores.primary),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Text("Nombre"),
                        TextField(
                          controller: nombre,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu nombre',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text("Apellidos"),
                        TextField(
                          controller: apellidoPaterno,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu apellido paterno',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text("Apellido materno"),
                        TextField(
                          controller: apellidoMaterno,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu apellido materno',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("RFC"),

                        TextField(
                          controller: rfc,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu RFC',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text("Nombre fiscal"),
                        TextField(
                          controller: nombreFiscal,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu nombre fiscal',
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
                        const SizedBox(height: 10),

                        Text("Telefono"),
                        TextField(
                          controller: telefono,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu telefono',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text("Correo electronico"),

                        TextField(
                          controller: correoElectronico,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu correo electronico',
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
                        const SizedBox(height: 10),

                        Text("Colonia"),
                        TextField(
                          controller: colonia,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu colonia',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text("Calle"),
                        TextField(
                          controller: calle,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu calle',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Numero"),
                        TextField(
                          controller: numero,
                          decoration: createAppDecoration(
                            prefixIcon: Icon(Icons.perm_identity),
                            hintText: 'Ingresa tu numero',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
