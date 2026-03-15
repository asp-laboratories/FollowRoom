import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class NavigatorEventosReservacion extends StatefulWidget {
  const NavigatorEventosReservacion({super.key});

  @override
  State<NavigatorEventosReservacion> createState() =>
      _NavigatorEventosReservacionState();
}

class _NavigatorEventosReservacionState
    extends State<NavigatorEventosReservacion> {
  DateTime fechaSeleccionada = DateTime.now();
  String? salonSeleccionado;
  final TextEditingController _busquedaController = TextEditingController();

  final List<Map<String, dynamic>> salonesDB = [
    {'id': 1, 'nombre': 'Salón Imperial'},
    {'id': 2, 'nombre': 'Salón Ejecutivo'},
    {'id': 3, 'nombre': 'Salón Universal'},
    {'id': 4, 'nombre': 'Salón Premium'},
  ];

  final List<Map<String, dynamic>> reservacionesDB = [
    {
      'id': 1,
      'salon': 'Salón Imperial',
      'salonId': 1,
      'fecha': DateTime.now(),
      'horaInicio': 14,
      'horaFin': 18,
      'evento': 'Cumpleaños de María',
      'cliente': 'Juan Pérez',
    },
    {
      'id': 2,
      'salon': 'Salón Ejecutivo',
      'salonId': 2,
      'fecha': DateTime.now(),
      'horaInicio': 9,
      'horaFin': 12,
      'evento': 'Reunión de trabajo',
      'cliente': 'Carlos García',
    },
    {
      'id': 3,
      'salon': 'Salón Imperial',
      'salonId': 1,
      'fecha': DateTime.now().add(Duration(days: 1)),
      'horaInicio': 10,
      'horaFin': 14,
      'evento': 'Conferencia',
      'cliente': 'Ana López',
    },
    {
      'id': 4,
      'salon': 'Salón Premium',
      'salonId': 4,
      'fecha': DateTime.now().add(Duration(days: 1)),
      'horaInicio': 16,
      'horaFin': 20,
      'evento': 'Boda',
      'cliente': 'Pedro y María',
    },
    {
      'id': 5,
      'salon': 'Salón Universal',
      'salonId': 3,
      'fecha': DateTime.now().add(Duration(days: 2)),
      'horaInicio': 8,
      'horaFin': 17,
      'evento': 'Exposicion',
      'cliente': 'Exposiciones SA',
    },
  ];

  List<Map<String, dynamic>> get reservacionesFiltradas {
    return reservacionesDB.where((r) {
      bool coincideFecha = _esMismaFecha(r['fecha'], fechaSeleccionada);
      bool coincideSalon =
          salonSeleccionado == null ||
          salonSeleccionado == 'todos' ||
          r['salon'] == salonSeleccionado;
      bool coincideBusqueda =
          _busquedaController.text.isEmpty ||
          r['evento'].toLowerCase().contains(
            _busquedaController.text.toLowerCase(),
          ) ||
          r['cliente'].toLowerCase().contains(
            _busquedaController.text.toLowerCase(),
          );
      return coincideFecha && coincideSalon && coincideBusqueda;
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

  @override
  Widget build(BuildContext context) {
    List<DateTime> fechas = _getFechasConReservaciones();

    return Scaffold(
      appBar: AppBar(
        title: Text("Disponibilidad de Salones"),
        backgroundColor: AppColores.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
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
                          value: salonSeleccionado,
                          hint: Text("Todos", style: TextStyle(fontSize: 13)),
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
                            ...salonesDB.map(
                              (s) => DropdownMenuItem(
                                value: s['nombre'],
                                child: Text(
                                  s['nombre'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => salonSeleccionado = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de reservaciones
            Expanded(
              child: fechas.isEmpty
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
                    reservacion['salon'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "OCUPADO",
                    style: TextStyle(
                      color: Colors.red,
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
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  reservacion['cliente'],
                  style: TextStyle(color: Colors.grey),
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
    }
  }
}
