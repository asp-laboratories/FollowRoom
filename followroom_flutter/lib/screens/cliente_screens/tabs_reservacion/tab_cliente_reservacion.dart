import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/services/cliente_service.dart';
import 'package:followroom_flutter/services/session_data.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class TabClienteReservacion extends StatefulWidget {
  final Function(Map<String, String>) onDatosChanged;
  final VoidCallback? onSaveAndNext;
  final TextEditingController? nombreController;
  final TextEditingController? apellidoPaternoController;
  final TextEditingController? apellidoMaternoController;
  final TextEditingController? rfcController;
  final TextEditingController? nombreFiscalController;
  final TextEditingController? telefonoController;
  final TextEditingController? correoController;
  final TextEditingController? coloniaController;
  final TextEditingController? calleController;
  final TextEditingController? numeroController;

  const TabClienteReservacion({
    super.key,
    required this.onDatosChanged,
    this.onSaveAndNext,
    this.nombreController,
    this.apellidoPaternoController,
    this.apellidoMaternoController,
    this.rfcController,
    this.nombreFiscalController,
    this.telefonoController,
    this.correoController,
    this.coloniaController,
    this.calleController,
    this.numeroController,
  });

  @override
  State<TabClienteReservacion> createState() => _TabClienteReservacionState();
}

class _TabClienteReservacionState extends State<TabClienteReservacion>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController nombre;
  late final TextEditingController apellidoPaterno;
  late final TextEditingController apellidoMaterno;
  late final TextEditingController rfc;
  late final TextEditingController nombreFiscal;
  late final TextEditingController telefono;
  late final TextEditingController correoElectronico;
  late final TextEditingController colonia;
  late final TextEditingController calle;
  late final TextEditingController numero;

  final ClienteService _clienteService = ClienteService();
  bool _cargando = true;
  bool _esClienteNuevo = true;

  @override
  void initState() {
    super.initState();
    nombre = widget.nombreController ?? TextEditingController();
    apellidoPaterno =
        widget.apellidoPaternoController ?? TextEditingController();
    apellidoMaterno =
        widget.apellidoMaternoController ?? TextEditingController();
    rfc = widget.rfcController ?? TextEditingController();
    nombreFiscal = widget.nombreFiscalController ?? TextEditingController();
    telefono = widget.telefonoController ?? TextEditingController();
    correoElectronico = widget.correoController ?? TextEditingController();
    colonia = widget.coloniaController ?? TextEditingController();
    calle = widget.calleController ?? TextEditingController();
    numero = widget.numeroController ?? TextEditingController();

    _cargarDatosCliente();

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

  Future<void> _cargarDatosCliente() async {
    final datos = await _clienteService.getDatosCliente();

    if (mounted) {
      setState(() {
        _cargando = false;

        if (datos != null) {
          _esClienteNuevo = false;
          nombre.text = datos['nombre'] ?? '';
          apellidoPaterno.text = datos['apellidoPaterno'] ?? '';
          apellidoMaterno.text = datos['apelidoMaterno'] ?? '';
          rfc.text = datos['rfc'] ?? '';
          nombreFiscal.text = datos['nombre_fiscal'] ?? '';
          telefono.text = datos['telefono'] ?? '';
          correoElectronico.text =
              datos['correo_electronico'] ?? SessionData.email ?? '';
          colonia.text = datos['dir_colonia'] ?? '';
          calle.text = datos['dir_calle'] ?? '';
          numero.text = datos['dir_numero'] ?? '';
        } else {
          _esClienteNuevo = true;
          correoElectronico.text = SessionData.email ?? '';
        }
      });

      _autoSave();
    }
  }

  Future<void> _guardarDatos() async {
    await _clienteService.guardarDatosCliente({
      'nombre': nombre.text,
      'apellidoPaterno': apellidoPaterno.text,
      'apelidoMaterno': apellidoMaterno.text,
      'rfc': rfc.text,
      'nombre_fiscal': nombreFiscal.text,
      'telefono': telefono.text,
      'dir_colonia': colonia.text,
      'dir_calle': calle.text,
      'dir_numero': numero.text,
    });

    if (mounted) {
      AnimatedSnackBar(
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Datos guardados con éxito',
                  style: TextStyle(color: Colors.green.shade800),
                ),
              ),
            ],
          ),
        ),
      ).show(context);
    }
  }

  @override
  bool get wantKeepAlive => true;

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
    if (widget.nombreController == null) nombre.dispose();
    if (widget.apellidoPaternoController == null) apellidoPaterno.dispose();
    if (widget.apellidoMaternoController == null) apellidoMaterno.dispose();
    if (widget.rfcController == null) rfc.dispose();
    if (widget.nombreFiscalController == null) nombreFiscal.dispose();
    if (widget.telefonoController == null) telefono.dispose();
    if (widget.correoController == null) correoElectronico.dispose();
    if (widget.coloniaController == null) colonia.dispose();
    if (widget.calleController == null) calle.dispose();
    if (widget.numeroController == null) numero.dispose();
    super.dispose();
  }

  void _autoSave() {
    widget.onDatosChanged({
      'nombre': nombre.text,
      'apellidoPaterno': apellidoPaterno.text,
      'apelidoMaterno': apellidoMaterno.text,
      'rfc': rfc.text,
      'nombre_fiscal': nombreFiscal.text,
      'telefono': telefono.text,
      'correoElectronico': correoElectronico.text,
      'dir_colonia': colonia.text,
      'dir_calle': calle.text,
      'dir_numero': numero.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: AppColores.background2,
      child: _cargando
          ? Center(child: CircularProgressIndicator(color: AppColores.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_esClienteNuevo)
                      Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Es tu primera vez. Completa tus datos y se guardarán automáticamente.',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text("Datos personales", style: TextEstilos.subtitulos),
                    Container(
                      width: double.infinity,
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
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'Ingresa tu telefono',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Correo electronico"),
                            TextField(
                              controller: correoElectronico,
                              readOnly: true,
                              decoration: createAppDecoration(
                                prefixIcon: Icon(Icons.email),
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
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Ingresa tu colonia',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Calle"),
                            TextField(
                              controller: calle,
                              decoration: createAppDecoration(
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Ingresa tu calle',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Numero"),
                            TextField(
                              controller: numero,
                              decoration: createAppDecoration(
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Ingresa tu numero',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardarDatos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _esClienteNuevo
                              ? 'Guardar mis datos'
                              : 'Actualizar mis datos',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
