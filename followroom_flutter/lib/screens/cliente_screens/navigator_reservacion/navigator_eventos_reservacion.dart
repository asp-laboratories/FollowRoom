import 'package:flutter/material.dart';
import 'package:followroom_flutter/components/widget_seccion_busqueda.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/services/disponibilidad_service.dart';
import 'package:followroom_flutter/services/salon_service.dart';

class NavigatorEventosReservacion extends StatefulWidget {
  const NavigatorEventosReservacion({super.key});

  @override
  State<NavigatorEventosReservacion> createState() =>
      _NavigatorEventosReservacionState();
}

class _NavigatorEventosReservacionState
    extends State<NavigatorEventosReservacion> {
  DateTime? _fechaSeleccionada;
  String? _salonSeleccionado;
  String _textoBusqueda = '';

  final DisponibilidadService _disponibilidadService = DisponibilidadService();
  final SalonService _salonServicios = SalonService();

  List<Map<String, dynamic>> _reservacionesDB = [];
  List<Map<String, dynamic>> _estadosSalonesDB = [];
  List<Map<String, dynamic>> _salonesDB = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      String fechaStr = '';
      if (_fechaSeleccionada != null){
        fechaStr = 
          '${_fechaSeleccionada!.year}-'
          '${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-'
          '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';}

      final resultados = await Future.wait([
        _disponibilidadService.getReservacionesFecha(fechaStr),
        _disponibilidadService.getEstadosSalones(fechaStr),
        _salonServicios.getSalonesConEstado(null),
      ]);

      if (!mounted) return;
      setState(() {
        _reservacionesDB = (resultados[0] as List).map((item) {
          return {
            'id': item['id'],
            'salon': item['salon_nombre'],
            'salonId': item['salon_id'],
            'fecha': DateTime.parse(item['fechaEvento']),
            'horaInicio': int.parse(
              item['horaInicio'].toString().split(':')[0],
            ),
            'horaFin': int.parse(item['horaFin'].toString().split(':')[0]),
            'evento': item['nombreEvento'],
            'tipo_evento': item['tipo_evento_nombre'],
          };
        }).toList();

        _estadosSalonesDB = (resultados[1] as List).map((item) {
          return {
            'salonId': item['salon']?['id'] ?? item['salon'],
            'salonNombre': item['salon']?['nombre'] ?? '',
            'estadoCodigo':
                item['estado_codigo'] ?? item['estado_salon']?['codigo'] ?? '',
            'estadoNombre':
                item['estado_nombre'] ?? item['estado_salon']?['nombre'] ?? '',
          };
        }).toList();

        _salonesDB = (resultados[2] as List).map((item) {
          return {'id': item['id'], 'nombre': item['nombre']};
        }).toList();

        _cargando = false;
      });
    } catch (e) {
      debugPrint("Error cargando datos: $e");
      setState(() => _cargando = false);
    }
  }

  void _onFechaChanged(DateTime? fecha) {
    setState(() => _fechaSeleccionada = fecha);
    _cargarDatos();
  }

  void _onSalonChanged(String? salon) {
    setState(() => _salonSeleccionado = salon);
  }

  void _onBusquedaChanged(String texto) {
    setState(() => _textoBusqueda = texto);
  }

  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Map<String, dynamic>> get _reservacionesFiltradas {
    return _reservacionesDB.where((r) {
      final coincideSalon =
          _salonSeleccionado == null ||
          _salonSeleccionado == 'todos' ||
          r['salon'] == _salonSeleccionado;

      if (!coincideSalon) return false;

      if (_textoBusqueda.isNotEmpty) {
        final eventoTexto = r['evento'].toString().toLowerCase();
        if (eventoTexto.contains(_textoBusqueda.toLowerCase())) {
          return true;
        }
        return false;
      }

      if (_fechaSeleccionada != null) {
        return _esMismaFecha(r['fecha'], _fechaSeleccionada!);
      }
      return true;
    }).toList();
  }

  bool _esHoy(DateTime? fecha) =>
      fecha != null && _esMismaFecha(fecha, DateTime.now());

  bool _esManana(DateTime? fecha) =>
      fecha != null &&
      _esMismaFecha(fecha, DateTime.now().add(const Duration(days: 1)));

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Todas las fechas';
    if (_esHoy(fecha)) return 'HOY';
    if (_esManana(fecha)) return 'MAÑANA';
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  bool _esSalonReservable(String salonNombre) {
    final estado = _estadosSalonesDB
        .where((e) => e['salonNombre'] == salonNombre)
        .firstOrNull;
    if (estado == null) return true;
    final codigo = estado['estadoCodigo']?.toString().toUpperCase();
    return codigo == 'DISP' || codigo == 'DISPONIBLE';
  }

  String? _getEstadoSalon(String salonNombre) {
    final estado = _estadosSalonesDB
        .where((e) => e['salonNombre'] == salonNombre)
        .firstOrNull;
    if (estado == null) return null;
    return estado['estadoCodigo']?.toString().toUpperCase();
  }

  List<DateTime> _getFechasConReservaciones() {
    final fechas = <DateTime>{};
    for (var r in _reservacionesFiltradas) {
      fechas.add(DateTime(r['fecha'].year, r['fecha'].month, r['fecha'].day));
    }
    return fechas.toList()..sort();
  }

  List<Map<String, dynamic>> _getReservacionesDelDia(DateTime fecha) {
    return _reservacionesFiltradas
        .where((r) => _esMismaFecha(r['fecha'], fecha))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final fechas = _getFechasConReservaciones();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Disponibilidad de Salones"),
        backgroundColor: AppColores.background2,
        foregroundColor: AppColores.foreground,
      ),
      backgroundColor: AppColores.background2,
      body: SafeArea(
        child: Column(
          children: [
            FiltroReservacionesWidget(
              salones: _salonesDB,
              onFechaChanged: _onFechaChanged,
              onSalonChanged: _onSalonChanged,
              onBusquedaChanged: _onBusquedaChanged,
            ),

            Expanded(
              child: _cargando
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColores.primary,
                      ),
                    )
                  : fechas.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No hay reservaciones",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            "para la fecha seleccionada",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: fechas.length,
                      itemBuilder: (context, index) {
                        final fecha = fechas[index];
                        final reservaciones = _getReservacionesDelDia(fecha);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 20,
                                    color: AppColores.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatearFecha(fecha),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...reservaciones.map(_buildCardReservacion),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardReservacion(Map<String, dynamic> reservacion) {
    final salonNombre = reservacion['salon'] as String;
    final estadoCodigo = _getEstadoSalon(salonNombre);

    Color estadoColor = Colors.red.shade100;
    Color textColor = Colors.red;
    String estadoTexto = "OCUPADO";

    if (estadoCodigo != null) {
      switch (estadoCodigo) {
        case 'DISP':
        case 'DISPONIBLE':
          estadoColor = Colors.green.shade100;
          textColor = Colors.green;
          estadoTexto = "DISPONIBLE";
          break;
        case 'NODIS':
        case 'NODISP':
        case 'NO DISPONIBLE':
          estadoColor = Colors.red.shade100;
          textColor = Colors.red;
          estadoTexto = "NO DISPONIBLE";
          break;
        case 'LIM':
        case 'LIMPIEZA':
          estadoColor = Colors.orange.shade100;
          textColor = Colors.orange;
          estadoTexto = "EN LIMPIEZA";
          break;
        case 'MANT':
        case 'MANTENIMIENTO':
          estadoColor = Colors.blue.shade100;
          textColor = Colors.blue;
          estadoTexto = "MANTENIMIENTO";
          break;
        default:
          estadoColor = Colors.red.shade100;
          textColor = Colors.red;
          estadoTexto = "OCUPADO";
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    salonNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${reservacion['horaInicio'].toString().padLeft(2, '0')}:00"
                  " - ${reservacion['horaFin'].toString().padLeft(2, '0')}:00",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.celebration, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reservacion['evento'],
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            if (reservacion['tipo_evento'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reservacion['tipo_evento'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
