import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/boton_styles.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_eventos_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/main_reservacion_proceso.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_detalles_reservacion_actual.dart';
import 'package:followroom_flutter/services/cliente_service.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class Reservacion extends StatefulWidget {
  const Reservacion({super.key});

  @override
  State<Reservacion> createState() => _ReservacionState();
}

class _ReservacionState extends State<Reservacion> {
  final ReservacionService _serivicoReservacion = ReservacionService();

  final ClienteService _clienteService = ClienteService();
  String? _rfc;

  List<Map<String, dynamic>> _paquetes = [];
  Map<String, dynamic>? _reservacionProxima;

  bool _cargando = true;

  final List<Color> _coloresPaquetes = [
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
  ];

  final List<IconData> _iconosPaquetes = [
    Icons.card_giftcard,
    Icons.celebration,
    Icons.star,
    Icons.diamond,
    Icons.workspace_premium,
    Icons.auto_awesome,
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    Future.wait([_cargarPaquetes(),_cargarReservacionProxima()]);
    setState(() {
      _cargando = false;
    });
  }

  Future<String?> _cargarRfc() async {
    final datos = await _clienteService.getDatosCliente();
    if (!mounted) return '';
    setState(() {
      _rfc = datos?['rfc'];
    });
    return _rfc;
  }

  Future<void> _cargarReservacionProxima() async {
    final rfc = await _cargarRfc();
    final datos = await _serivicoReservacion.getReservacionProxima(rfc);
    if (!mounted) return;
    setState(() {
      _reservacionProxima = datos;
    });
  } 

  Future<void> _cargarPaquetes() async {
    List<Map<String, dynamic>> paqueteObtenidos = await _serivicoReservacion
        .getPaquetes();
    if (!mounted) return;
    setState(() {
      _paquetes = paqueteObtenidos.asMap().entries.map((entri) {
        final i = entri.key;
        final p = entri.value;
        return {
          ...p,
          'color': _coloresPaquetes[i % _coloresPaquetes.length],
          'icono': _iconosPaquetes[i % _iconosPaquetes.length],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneReservacion = _reservacionProxima != null && _reservacionProxima!.isNotEmpty;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            if (tieneReservacion)
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
                      "Tienes una reservación proxima a realizarse",
                      style: TextEstilos.subtitulos,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallesHistorial(idReservacion: _reservacionProxima!['id']),
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
                      "No tienes eventos proximos pagados",
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
                height: 380.0,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
              ),
              items: _paquetes.map((paquete) {
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
                                          paquete['nombreEvento'] as String,
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
                                      '\$${paquete['total']}',
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
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Descripcion:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          paquete['descripEvento'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (paquete['montaje']['salon'] !=
                                            null) ...[
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
                                                'Salón: ${paquete['montaje']['salon']['nombre']}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (paquete['montaje']['montaje_mobiliario'] !=
                                                null &&
                                            paquete['montaje']['montaje_mobiliario']
                                                .isNotEmpty) ...[
                                          ...paquete['montaje']['montaje_mobiliario']
                                              .take(2)
                                              .map((mobiliario) {
                                                return Row(
                                                  children: [
                                                    Icon(
                                                      Icons.chair,
                                                      size: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Mobiliario: ${mobiliario['mobiliario']['nombre']} (x${mobiliario['cantidad']})',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          SizedBox(height: 4),
                                        ],
                                        if (paquete['reserva_servicio'] !=
                                                null &&
                                            paquete['reserva_servicio']
                                                .isNotEmpty) ...[
                                          ...paquete['reserva_servicio']
                                              .take(2)
                                              .map((servicio) {
                                                return Row(
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      size: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Servicio: ${servicio['servicio']['nombre']}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ],
                                        if (paquete['reserva_equipa'] != null &&
                                            paquete['reserva_equipa']
                                                .isNotEmpty) ...[
                                          ...paquete['reserva_equipa'].take(2).map((
                                            euipo,
                                          ) {
                                            return Row(
                                              children: [
                                                Icon(
                                                  Icons.laptop,
                                                  size: 12,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Equipo: ${euipo['equipamiento']['nombre']} (x${euipo['cantidad']})',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ],
                                    ),
                                  ),
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
                                                DetallesHistorial(
                                                  idReservacion: paquete['id'],
                                                  detallesPaquete: true,
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
                                                ReservacionProceso(
                                                  datosReservacion: paquete,
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
