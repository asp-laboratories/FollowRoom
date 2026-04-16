import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class FiltroReservacionesWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? salones;

  final bool seccionSalones;

  final void Function(DateTime? fecha) onFechaChanged;

  final void Function(String? salon) onSalonChanged;

  final void Function(String texto) onBusquedaChanged;

  const FiltroReservacionesWidget({
    super.key,
    this.salones,
    required this.onFechaChanged,
    required this.onSalonChanged,
    required this.onBusquedaChanged,
    this.seccionSalones = true,
  });

  @override
  State<FiltroReservacionesWidget> createState() =>
      _FiltroReservacionesWidgetState();
}

class _FiltroReservacionesWidgetState extends State<FiltroReservacionesWidget> {
  DateTime? fechaSeleccionada;
  String? salonSeleccionado;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _esHoy(DateTime fecha) => _esMismaFecha(fecha, DateTime.now());

  bool _esManana(DateTime fecha) =>
      _esMismaFecha(fecha, DateTime.now().add(const Duration(days: 1)));

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return "Todas las fechas";
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

  Future<void> _selectDate() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (seleccionada != null) {
      setState(() => fechaSeleccionada = seleccionada);
      widget.onFechaChanged(seleccionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onBusquedaChanged,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
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
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatearFecha(fechaSeleccionada),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (fechaSeleccionada != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => fechaSeleccionada = null);
                              widget.onFechaChanged(null);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              widget.seccionSalones
                  ? Expanded(
                      child: DropdownButtonFormField<String>(
                        value: salonSeleccionado,
                        hint: const Text(
                          "Todos",
                          style: TextStyle(fontSize: 13),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'todos',
                            child: Text(
                              "Todos",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          ...widget.salones!.map(
                            (s) => DropdownMenuItem(
                              value: s['nombre'] as String,
                              child: Text(
                                s['nombre'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => salonSeleccionado = value);
                          widget.onSalonChanged(value);
                        },
                      ),
                    )
                  : SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
