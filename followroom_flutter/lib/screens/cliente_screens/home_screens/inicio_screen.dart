import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/core/estados_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_eventos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/main_reservacion_proceso.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_detalles_reservacion_actual.dart';
import 'package:followroom_flutter/screens/cliente_screens/reservar_paquete_screen.dart';
import 'package:followroom_flutter/services/paquete_service.dart';
import 'package:followroom_flutter/services/historial_service.dart';
import 'package:followroom_flutter/services/session_data.dart';

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
  final PaqueteService _paqueteService = PaqueteService();
  final HistorialService _historialService = HistorialService();
  List<Map<String, dynamic>> paquetesDB = [];
  bool _cargandoPaquetes = true;
  bool _cargandoReservacion = true;
  String? _errorPaquetes;
  String? _errorReservacion;
  Map<String, dynamic>? _reservacionProxima;
  final Color _colorBase = Colors.blue;

  @override
  void initState() {
    super.initState();
    _cargarPaquetes();
    _cargarReservacionProxima();
  }

  Future<void> _cargarPaquetes() async {
    try {
      final data = await _paqueteService.getPaquetes();
      setState(() {
        paquetesDB = data.map((item) {
          final precio = int.tryParse(item['total']?.toString() ?? '0') ?? 0;
          return {
            'id': item['id'],
            'nombre': item['nombre_paquete'] ?? 'Sin nombre',
            'descripcion': item['descripEvento'] ?? 'Sin descripción',
            'precio': precio,
            'icono': Icons.card_giftcard,
            'color': _colorBase,
            'servicios': item['servicios'] ?? [],
            'equipamentos': item['equipamentos'] ?? [],
            'mobiliarios': item['mobiliarios'] ?? [],
            'salon_id': item['salon_id'],
            'salon_nombre': item['salon_nombre'],
            'salon_precio': item['salon_precio'],
            'salon_capacidad': item['salon_capacidad'],
            'montaje_id': item['montaje_id'],
            'montaje_nombre': item['montaje_nombre'],
          };
        }).toList();
        _cargandoPaquetes = false;
      });
    } catch (e) {
      print('Error al cargar paquetes: $e');
      setState(() {
        _cargandoPaquetes = false;
        _errorPaquetes = e.toString();
      });
    }
  }

  Future<void> _cargarReservacionProxima() async {
    try {
      final reservacion = await _historialService.getReservacionProxima();

      bool tieneActiva = false;
      if (reservacion != null) {
        final estado = reservacion['estado_reserva_datos'];
        if (estado is Map) {
          final codigo = estado['codigo']?.toString() ?? '';
          print('Reservación próxima - Estado código: $codigo');
          if (codigo == 'CONF' || codigo == 'CON' || codigo == 'PROC') {
            tieneActiva = true;
            print('Tengo reservación ACTIVA: $codigo');
          } else {
            print(
              'Reservación con estado: $codigo (no es CONF, CON ni PROC, no se mostrará)',
            );
          }
        }
      } else {
        print('No hay reservación próxima');
      }

      setState(() {
        _reservacionProxima = tieneActiva ? reservacion : null;
        _cargandoReservacion = false;
      });
    } catch (e) {
      print('Error al cargar reservación próxima: $e');
      setState(() {
        _cargandoReservacion = false;
        _errorReservacion = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoPaquetes || _cargandoReservacion) {
      return const LoadingWidget(mensaje: 'Cargando información...');
    }

    if (_errorPaquetes != null || _errorReservacion != null) {
      return ErrorDisplay.conexion(
        mensaje: _errorPaquetes ?? _errorReservacion ?? 'Error de conexión',
        onRetry: () {
          setState(() {
            _errorPaquetes = null;
            _errorReservacion = null;
            _cargandoPaquetes = true;
            _cargandoReservacion = true;
          });
          _cargarPaquetes();
          _cargarReservacionProxima();
        },
      );
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            if (!_cargandoReservacion && _reservacionProxima != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColores.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColores.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Tienes una reservación pendiente",
                      style: TextEstilos.subtitulos,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallesReservacionActual(
                              reservacion: _reservacionProxima,
                            ),
                          ),
                        );
                      },
                      style: BotonStyles.botonesAccion,
                      child: Text("Ver detalles"),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "No tienes eventos reservados",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColores.backgroundComponent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColores.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColores.primary, AppColores.secundary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "¡Comienza ahora!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NavigatorEventosReservacion(),
                                  ),
                                );
                              },
                              style: BotonStyles.botonesAccion,
                              child: Text(
                                "Ver eventos",
                                style: TextStyle(fontSize: 11.5),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservacionProceso(),
                                  ),
                                );
                              },
                              style: BotonStyles.botonesAccion,
                              child: Text(
                                "Solicitar reservacion",
                                style: TextStyle(fontSize: 11.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            CarouselSlider(
              options: CarouselOptions(
                height: 320.0,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
              ),
              items: paquetesDB.map((paquete) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (paquete['color'] as Color)
                                          .withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      paquete['icono'] as IconData,
                                      size: 32,
                                      color: paquete['color'] as Color,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          paquete['nombre'] as String,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Paquete especial',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColores.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '\$${paquete['precio']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Incluye:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      paquete['descripcion'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (paquete['salon_nombre'] != null) ...[
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Salón: ${paquete['salon_nombre']}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReservacionProceso(
                                                  paqueteSeleccionado: paquete,
                                                ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        side: BorderSide(
                                          color: AppColores.primary,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Ver más",
                                        style: TextStyle(
                                          color: AppColores.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReservarPaqueteScreen(
                                                  paquete: paquete,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColores.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text("Reservar"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
