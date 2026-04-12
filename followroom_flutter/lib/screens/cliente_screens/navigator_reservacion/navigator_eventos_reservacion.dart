import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/services/disponibilidad_service.dart';

class NavigatorEventosReservacion extends StatefulWidget {
  const NavigatorEventosReservacion({super.key});

  @override
  State<NavigatorEventosReservacion> createState() =>
      _NavigatorEventosReservacionState();
}

class _NavigatorEventosReservacionState
    extends State<NavigatorEventosReservacion> {
  DateTime fechaSeleccionada = DateTime.now();
  // Filtro por estado del salon (null = todos)
  String? estadoFiltro;
  final TextEditingController _busquedaController = TextEditingController();
  final DisponibilidadService _disponibilidadService = DisponibilidadService();
  List<Map<String, dynamic>> reservacionesDB = [];
  List<Map<String, dynamic>> estadosSalonesDB = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final fechaStr =
          '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}';

      final resultados = await Future.wait([
        _disponibilidadService.getReservacionesFecha(fechaStr),
        _disponibilidadService.getEstadosSalones(fechaStr),
      ]);

      final reservacionesData = resultados[0];
      final estadosData = resultados[1];

      setState(() {
        reservacionesDB = reservacionesData.map((item) {
          return {
            'id': item['id'],
            'salon': item['montaje']['salon']['nombre'],
            'salonId': item['montaje']['salon']['id'],
            'fecha': DateTime.parse(item['fechaEvento']),
            'horaInicio': int.parse(
              item['horaInicio'].toString().split(':')[0],
            ),
            'horaFin': int.parse(item['horaFin'].toString().split(':')[0]),
            'evento': item['nombreEvento'],
            'tipo_evento': item['tipo_evento']['nombre'],
          };
        }).toList();

        estadosSalonesDB = estadosData.map((item) {
          dynamic salonData = item['salon'];
          int? salonId;
          String salonNombre = '';

          if (salonData is Map) {
            salonId = salonData['id'] is int
                ? salonData['id']
                : int.tryParse(salonData['id']?.toString() ?? '');
            salonNombre = salonData['nombre']?.toString() ?? 'Desconocido';
          } else {
            salonId = salonData is int
                ? salonData
                : int.tryParse(salonData?.toString() ?? '');
            salonNombre = 'Salón $salonId';
          }
          dynamic estadoData = item['estado_salon'];
          String estadoCodigo = item['estado_codigo']?.toString() ?? '';
          String estadoNombre = item['estado_nombre']?.toString() ?? '';

          if (estadoData is Map) {
            estadoCodigo = estadoData['codigo'] ?? estadoCodigo;
            estadoNombre = estadoData['nombre'] ?? estadoNombre;
          } else if (estadoData != null && estadoCodigo.isEmpty) {
            estadoCodigo = estadoData.toString();
          }

          return {
            'salonId': salonId,
            'salonNombre': salonNombre,
            'estadoCodigo': estadoCodigo,
            'estadoNombre': estadoNombre,
          };
        }).toList();

        _cargando = false;
      });
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() => _cargando = false);
    }
  }

  bool _esSalonReservable(String salonNombre) {
    final estado = estadosSalonesDB
        .where((e) => e['salonNombre'] == salonNombre)
        .firstOrNull;

    if (estado == null) return true;

    final codigo = estado['estadoCodigo']?.toString().toUpperCase();
    // TODO: Descomentar cuando se ejecute migración para agregar campo fecha_fin
    // final fechaFin = estado['fechaFin'] as DateTime?;
    // if (fechaFin != null && fechaFin.isBefore(fechaSeleccionada)) {
    //   return true;
    // }

    return codigo == 'DISP' || codigo == 'DISPONIBLE';
  }

  String? _getEstadoSalon(String salonNombre) {
    final estado = estadosSalonesDB
        .where((e) => e['salonNombre'] == salonNombre)
        .firstOrNull;

    if (estado == null) return null;

    final codigo = estado['estadoCodigo']?.toString().toUpperCase();
    // TODO: Descomentar cuando se ejecute migración para agregar campo fecha_fin
    // final fechaFin = estado['fechaFin'] as DateTime?;
    // if (fechaFin != null && fechaFin.isBefore(fechaSeleccionada)) {
    //   return null;
    // }

    return codigo;
  }

  List<Map<String, dynamic>> get reservacionesFiltradas {
    return reservacionesDB.where((r) {
      // Filtro por fecha
      final coincideFecha = _esMismaFecha(r['fecha'], fechaSeleccionada);

      // Filtro por busqueda (nombre del evento o salon)
      final textoBusqueda = _busquedaController.text.toLowerCase();
      final coincideBusqueda =
          textoBusqueda.isEmpty ||
          r['evento'].toString().toLowerCase().contains(textoBusqueda) ||
          r['salon'].toString().toLowerCase().contains(textoBusqueda);

      // Filtro por estado del salon
      bool coincideEstado = true;
      if (estadoFiltro != null && estadoFiltro != 'todos') {
        final estadoSalon = estadosSalonesDB
            .where((e) => e['salonNombre'] == r['salon'])
            .firstOrNull;
        final codigoSalon =
            estadoSalon?['estadoCodigo']?.toString().toUpperCase() ?? '';
        coincideEstado = codigoSalon == estadoFiltro!.toUpperCase();
      }

      return coincideFecha && coincideBusqueda && coincideEstado;
    }).toList();
  }

  bool _esMismaFecha(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _esHoy(DateTime fecha) {
    return _esMismaFecha(fecha, DateTime.now());
  }

  bool _esManana(DateTime fecha) {
    return _esMismaFecha(fecha, DateTime.now().add(Duration(days: 1)));
  }

  String _formatearFecha(DateTime fecha) {
    if (_esHoy(fecha)) return 'HOY';
    if (_esManana(fecha)) return 'MANANA';
    final dias = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Domingo',
    ];
    final meses = [
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

  List<Map<String, dynamic>> _getReservacionesDelDia(DateTime fecha) {
    return reservacionesFiltradas
        .where((r) => _esMismaFecha(r['fecha'], fecha))
        .toList();
  }

  List<DateTime> _getFechasConReservaciones() {
    Set<DateTime> fechas = {};
    for (var r in reservacionesFiltradas) {
      fechas.add(DateTime(r['fecha'].year, r['fecha'].month, r['fecha'].day));
    }
    return fechas.toList()..sort();
  }

  final List<Map<String, String>> _estadosDisponibles = [
    {'codigo': 'DISPO', 'nombre': 'Disponible'},
    {'codigo': 'NODIS', 'nombre': 'No disponible'},
    {'codigo': 'ENLIM', 'nombre': 'En limpieza'},
    {'codigo': 'MANTE', 'nombre': 'Mantenimiento'},
    {'codigo': 'RESER', 'nombre': 'Reservado'},
  ];

  @override
  Widget build(BuildContext context) {
    List<DateTime> fechas = _getFechasConReservaciones();

    print(reservacionesDB);
    print(estadosSalonesDB);

    return Scaffold(
      appBar: AppBar(
        title: Text("Disponibilidad de Salones"),
        backgroundColor: AppColores.background2,
        foregroundColor: AppColores.foreground,
      ),
      backgroundColor: AppColores.background2,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              color: AppColores.backgroundComponent,
              child: Column(
                children: [
                  TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: AppColores.foreground,
                      ),
                      filled: true,
                      fillColor: AppColores.backgroundComponent,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppColores.primary,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _formatearFecha(fechaSeleccionada),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: estadoFiltro,
                          hint: Text("Estado", style: TextStyle(fontSize: 13)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text(
                                "Todos",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            ..._estadosDisponibles.map(
                              (e) => DropdownMenuItem(
                                value: e['codigo'],
                                child: Text(
                                  e['nombre'] ?? e['codigo'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => estadoFiltro = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de reservaciones
            Expanded(
              child: _cargando
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColores.primary,
                      ),
                    )
                  : fechas.isEmpty
                  ? Center(
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
                      padding: EdgeInsets.all(16),
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
                                  SizedBox(width: 8),
                                  Text(
                                    _formatearFecha(fecha),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...reservaciones.map(
                              (r) => _buildCardReservacion(r),
                            ),
                            SizedBox(height: 16),
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
        case 'DISPO':
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
        case 'ENLIM':
        case 'LIMPIEZA':
          estadoColor = Colors.orange.shade100;
          textColor = Colors.orange;
          estadoTexto = "EN LIMPIEZA";
          break;
        case 'MANTE':
        case 'MANTENIMIENTO':
          estadoColor = Colors.blue.shade100;
          textColor = Colors.blue;
          estadoTexto = "MANTENIMIENTO";
          break;
        default:
          estadoColor = Colors.grey.shade100;
          textColor = Colors.grey;
          estadoTexto = "SIN INFORMACION";
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    salonNombre,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "${reservacion['horaInicio'].toString().padLeft(2, '0')}:00 - ${reservacion['horaFin'].toString().padLeft(2, '0')}:00",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.celebration, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reservacion['evento'],
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            if (reservacion['tipo_evento'] != null)
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reservacion['tipo_evento'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (seleccionada != null) {
      setState(() {
        fechaSeleccionada = seleccionada;
      });
      _cargarDatos();
    }
  }
}
