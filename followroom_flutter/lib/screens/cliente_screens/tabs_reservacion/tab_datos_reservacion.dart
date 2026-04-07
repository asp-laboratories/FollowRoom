import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/services/tipo_evento_service.dart';

class TabDatosReservacion extends StatefulWidget {
  final Function(Map<String, dynamic>) onDatosChanged;
  final VoidCallback? onSaveAndNext;
  final TextEditingController? nombreController;
  final TextEditingController? fechaController;
  final TextEditingController? horaController;
  final TextEditingController? asistentesController;
  final TextEditingController? descripcionController;

  const TabDatosReservacion({
    super.key,
    required this.onDatosChanged,
    this.descripcionController,
    this.onSaveAndNext,
    this.nombreController,
    this.fechaController,
    this.horaController,
    this.asistentesController,
  });

  @override
  State<TabDatosReservacion> createState() => _TabDatosReservacionState();
}

class _TabDatosReservacionState extends State<TabDatosReservacion>
    with AutomaticKeepAliveClientMixin {
  final TipoEventoService _tipoServicioServicevice = TipoEventoService();

  late Future<List<dynamic>> _tiposEventos;

  Map<String, dynamic>? tipoEventoSeleccionado;

  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _nombreController;
  late final TextEditingController _fechaController;
  late final TextEditingController _timeController;
  late final TextEditingController _asistentesController;
  late final TextEditingController _descripcionEventoController;

  @override
  void initState() {
    super.initState();
    _tiposEventos = _tipoServicioServicevice.getTiposEventos();
    _nombreController = widget.nombreController ?? TextEditingController();
    _fechaController = widget.fechaController ?? TextEditingController();
    _timeController = widget.horaController ?? TextEditingController();
    _asistentesController =
        widget.asistentesController ?? TextEditingController();
    _descripcionEventoController =
        widget.descripcionController ?? TextEditingController();

    _descripcionEventoController.addListener(_autoSave);
    _nombreController.addListener(_autoSave);
    _fechaController.addListener(_autoSave);
    _timeController.addListener(_autoSave);
    _asistentesController.addListener(_autoSave);
  }

  @override
  void dispose() {
    _nombreController.removeListener(_autoSave);
    _fechaController.removeListener(_autoSave);
    _timeController.removeListener(_autoSave);
    _asistentesController.removeListener(_autoSave);
    _descripcionEventoController.removeListener(_autoSave);
    if (widget.nombreController == null) _nombreController.dispose();
    if (widget.fechaController == null) _fechaController.dispose();
    if (widget.horaController == null) _timeController.dispose();
    if (widget.asistentesController == null) _asistentesController.dispose();
    if (widget.descripcionController == null)
      _descripcionEventoController.dispose();
    super.dispose();
  }

  void _autoSave() {
    widget.onDatosChanged({
      'nombre': _nombreController.text,
      'fechaEvento': _fechaController.text,
      'horario': _timeController.text,
      'horaInicio': _formatearPa24h(_horaInicio),
      'horaFin': _formatearPa24h(_horaFin),
      'tipo_evento': tipoEventoSeleccionado,
      'estimaAsistentes': _asistentesController.text,
      'descripEvento': _descripcionEventoController.text,
    });
  }

  String? _formatearPa24h(TimeOfDay? time) {
    if (time == null) return null;
    final hora = time.hour.toString().padLeft(2, '0');
    final minuto = time.minute.toString().padLeft(2, '0');
    return '$hora:$minuto:00';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  ThemeData _getCustomTimePickerTheme(BuildContext context) {
    final Color colorPrincipal = AppColores.primary;
    final Color fondoMoradoClaro = colorPrincipal.withOpacity(0.12);
    final Color fondoGris = Colors.grey.shade200;

    return Theme.of(context).copyWith(
      colorScheme: Theme.of(
        context,
      ).colorScheme.copyWith(primary: colorPrincipal, onSurface: Colors.black),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColores.background2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        hourMinuteColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? fondoMoradoClaro
              : fondoGris,
        ),
        hourMinuteTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorPrincipal
              : Colors.black87,
        ),
        hourMinuteTextStyle: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),

        dayPeriodColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? fondoMoradoClaro
              : AppColores.background2,
        ),
        dayPeriodTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorPrincipal
              : Colors.grey.shade600,
        ),
        dayPeriodBorderSide: BorderSide(color: Colors.grey.shade300),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        dialBackgroundColor: fondoGris,
        dialHandColor: colorPrincipal,
        dialTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColores.foreground
              : Colors.black87,
        ),

        entryModeIconColor: Colors.grey.shade700,
        helpTextStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorPrincipal, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        fillColor: fondoGris,
        filled: true,
      ),
    );
  }

  Future<void> showLightTimePicker() async {
    // 1. Seleccionar Hora de Inicio
    TimeOfDay? selectedInicio = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? TimeOfDay.now(),
      helpText: 'Seleccina la hora de inicio',
      builder: (context, child) {
        return Theme(data: _getCustomTimePickerTheme(context), child: child!);
      },
    );

    if (selectedInicio == null) return;

    TimeOfDay? selectedFin = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (selectedInicio.hour + 2) % 24,
        minute: selectedInicio.minute,
      ),
      helpText: 'Seleccina la hora de fin',
      builder: (context, child) {
        return Theme(data: _getCustomTimePickerTheme(context), child: child!);
      },
    );

    if (selectedFin == null) return;

    setState(() {
      _horaInicio = selectedInicio;
      _horaFin = selectedFin;
      _timeController.text =
          "${_formatTimeOfDay(selectedInicio)} - ${_formatTimeOfDay(selectedFin)}";
    });
    _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: AppColores.background2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nombre del evento", style: TextEstilos.indicador),
              const SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: createAppDecoration(
                  hintText: "Ej. Lanzamiento de Producto",
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Descripcion del evento",
                style: TextEstilos.indicador,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionEventoController,
                decoration: createAppDecoration(
                  hintText: "Ej. Se realizara celebracion para ...",
                ),
              ),

              const SizedBox(height: 16),
              const Text("Fecha del evento", style: TextEstilos.indicador),
              const SizedBox(height: 8),
              TextField(
                controller: _fechaController,
                readOnly: true,
                onTap: _selectDate,
                decoration: createAppDecoration(
                  hintText: "Selecciona una fecha",
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 16),
              const Text("Horario del evento", style: TextEstilos.indicador),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: showLightTimePicker,
                decoration: createAppDecoration(
                  hintText: "Selecciona el rango de horas",
                  prefixIcon: const Icon(Icons.access_time_outlined),
                ),
              ),

              const SizedBox(height: 16),
              const Text("Tipo de evento", style: TextEstilos.indicador),
              const SizedBox(height: 8),

              FutureBuilder<List<dynamic>>(
                future: _tiposEventos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DropdownButtonFormField(
                      value: null,
                      items: const [],
                      onChanged: null,
                      decoration: createAppDecoration(
                        hintText: "Selecciona tipo",
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      "Error al cargar los salones: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  final listaTiposEventos = snapshot.data ?? [];

                  return DropdownButtonFormField<Map<String, dynamic>>(
                    value: tipoEventoSeleccionado,
                    decoration: createAppDecoration(
                      hintText: "Selecciona tipo",
                    ),
                    hint: const Text("Toca para elegir un tipo de evento"),
                    items: listaTiposEventos
                        .map<DropdownMenuItem<Map<String, dynamic>>>((
                          tipoEvento,
                        ) {
                          return DropdownMenuItem(
                            value: tipoEvento,
                            child: Text(tipoEvento['nombre'] ?? 'Sin nombre'),
                          );
                        })
                        .toList(),
                    onChanged: (nuevaEleccion) {
                      setState(() => tipoEventoSeleccionado = nuevaEleccion);
                      _autoSave();
                    },
                  );
                },
              ),

              // DropdownButtonFormField<String>(
              //   value: tipoEventoSeleccionado,
              //   items: tiposEvento
              //       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              //       .toList(),
              //   onChanged: (val) {
              //     setState(() => tipoEventoSeleccionado = val);
              //     _autoSave();
              //   },
              //   decoration: createAppDecoration(hintText: "Selecciona tipo"),
              // ),
              const SizedBox(height: 16),
              const Text(
                "Cantidad de asistentes",
                style: TextEstilos.indicador,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _asistentesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: createAppDecoration(
                  hintText: "Número de personas",
                  prefixIcon: const Icon(Icons.people_outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (seleccionada != null) {
      if (!mounted) return;
      setState(() {
        _fechaController.text =
            "${seleccionada.year}-${seleccionada.month}-${seleccionada.day}";
      });
      _autoSave();
    }
  }
}
