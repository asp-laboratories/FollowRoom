import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:dio/dio.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_cliente_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_datos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_resumen_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/tabs_reservacion/tab_total_reservacion.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:followroom_flutter/services/salon_service.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
import 'package:followroom_flutter/services/session_data.dart';

class ReservarPaqueteScreen extends StatefulWidget {
  final Map<String, dynamic> paquete;

  const ReservarPaqueteScreen({super.key, required this.paquete});

  @override
  State<ReservarPaqueteScreen> createState() => _ReservarPaqueteScreenState();
}

class _ReservarPaqueteScreenState extends State<ReservarPaqueteScreen> {
  final ReservacionService _reservacionService = ReservacionService();
  Map<String, String> datosReservacion = {};
  Map<String, String> datosCliente = {};
  bool salonOcupado = false;
  bool _cargando = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController =
      TextEditingController();
  final TextEditingController _apellidoMaternoController =
      TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _nombreFiscalController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    final email = SessionData.email;
    if (email == null) return;

    try {
      final clienteService = _ClienteService();
      final cliente = await clienteService.getDatosCliente(email);
      if (cliente != null && mounted) {
        setState(() {
          datosCliente = {
            'nombre': cliente['nombre'] ?? '',
            'apellidoPaterno': cliente['apellidoPaterno'] ?? '',
            'apelidoMaterno': cliente['apelidoMaterno'] ?? '',
            'rfc': cliente['rfc'] ?? '',
            'nombre_fiscal': cliente['nombre_fiscal'] ?? '',
            'telefono': cliente['telefono'] ?? '',
            'correo_electronico': cliente['correo_electronico'] ?? '',
            'dir_colonia': cliente['dir_colonia'] ?? '',
            'dir_calle': cliente['dir_calle'] ?? '',
            'dir_numero': cliente['dir_numero'] ?? '',
          };
          _nombreController.text = datosCliente['nombre'] ?? '';
          _apellidoPaternoController.text =
              datosCliente['apellidoPaterno'] ?? '';
          _apellidoMaternoController.text =
              datosCliente['apelidoMaterno'] ?? '';
          _rfcController.text = datosCliente['rfc'] ?? '';
          _nombreFiscalController.text = datosCliente['nombre_fiscal'] ?? '';
          _telefonoController.text = datosCliente['telefono'] ?? '';
          _correoController.text = datosCliente['correo_electronico'] ?? '';
          _coloniaController.text = datosCliente['dir_colonia'] ?? '';
          _calleController.text = datosCliente['dir_calle'] ?? '';
          _numeroController.text = datosCliente['dir_numero'] ?? '';
        });
      }
    } catch (e) {
      print('Error al cargar datos del cliente: $e');
    }
  }

  Future<void> _verificarDisponibilidadSalon(String fecha) async {
    if (fecha.isEmpty) return;

    final salonId = widget.paquete['salon_id'];
    if (salonId == null) return;

    try {
      final salonService = SalonService();
      final salones = await salonService.getSalonesDisponibles(fecha);

      bool ocupado = true;
      for (var salon in salones) {
        if (salon['id'] == salonId && salon['reservado'] == false) {
          ocupado = false;
          break;
        }
      }

      if (mounted) {
        setState(() {
          salonOcupado = ocupado;
        });
      }
    } catch (e) {
      print('Error al verificar disponibilidad: $e');
    }
  }

  void _onDatosReservacionChanged(Map<String, String> nuevosDatos) {
    setState(() {
      datosReservacion.addAll(nuevosDatos);
    });

    if (nuevosDatos.containsKey('fecha') && nuevosDatos['fecha']!.isNotEmpty) {
      _verificarDisponibilidadSalon(nuevosDatos['fecha']!);
    }
  }

  Future<void> _confirmarReservacion() async {
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _rfcController.dispose();
    _nombreFiscalController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _coloniaController.dispose();
    _calleController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Contenido del paquete": ${widget.paquete}');

    final salon = {
      'id': widget.paquete['salon_id'],
      'nombre': widget.paquete['salon_nombre'],
      'precio': widget.paquete['salon_precio'],
    };

    final montajesPorSalon = <int, String>{};
    if (widget.paquete['salon_id'] != null &&
        widget.paquete['montaje_nombre'] != null) {
      montajesPorSalon[widget.paquete['salon_id']] =
          '${widget.paquete['montaje_nombre']}-${widget.paquete['tipo_montaje_id']}';
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColores.background2,
          title: Text('Reservar Paquete: ${widget.paquete['nombre']}'),
          bottom: ButtonsTabBar(
            backgroundColor: AppColores.primary,
            unselectedBackgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            radius: 70,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: "Datos del evento"),
              Tab(text: "Datos del cliente"),
              Tab(text: "Resumen"),
              Tab(text: "Total"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TabDatosReservacion(onDatosChanged: _onDatosReservacionChanged),
            TabClienteReservacion(
              onDatosChanged: (Map<String, String> datos) {
                setState(() {
                  datosCliente = datos;
                });
              },
              nombreController: _nombreController,
              apellidoPaternoController: _apellidoPaternoController,
              apellidoMaternoController: _apellidoMaternoController,
              rfcController: _rfcController,
              nombreFiscalController: _nombreFiscalController,
              telefonoController: _telefonoController,
              correoController: _correoController,
              coloniaController: _coloniaController,
              calleController: _calleController,
              numeroController: _numeroController,
            ),
            TabResumen(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salon,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['servicios'] ?? [],
              ),
              equipamientosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['equipamentos'] ?? [],
              ),
              mobiliariosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['mobiliarios'] ?? [],
              ),
              salonOcupado: salonOcupado,
            ),
            TabTotalReservacion(
              datosReservacion: datosReservacion,
              datosCliente: datosCliente,
              salonSeleccionado: salon,
              montajesPorSalon: montajesPorSalon,
              serviciosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['servicios'] ?? [],
              ),
              equipamientosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['equipamentos'] ?? [],
              ),
              mobiliariosSeleccionados: List<Map<String, dynamic>>.from(
                widget.paquete['mobiliarios'] ?? [],
              ),
              onReservacionEnviada: _confirmarReservacion,
              salonOcupado: salonOcupado,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClienteService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<Map<String, dynamic>?> getDatosCliente(String email) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/cliente/',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Error al obtener cliente: $e');
      return null;
    }
  }
}
