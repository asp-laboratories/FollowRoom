import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:from_to_time_picker/from_to_time_picker.dart';
import 'package:flutter/services.dart';

class TabDatosReservacion extends StatefulWidget {
  final Function(Map<String, String>) onDatosChanged;

  const TabDatosReservacion({super.key, required this.onDatosChanged});

  @override
  State<TabDatosReservacion> createState() => _TabDatosReservacionState();
}

class _TabDatosReservacionState extends State<TabDatosReservacion> {
  final List<String> tiposEvento = ['1', '2', '3'];
  String? tipoEventoSelccionado;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _asistentesController = TextEditingController();

  void showLightTimePicker() {
    showDialog(
      context: context,
      builder: (_) => FromToTimePicker(
        maxWidth: 600,
        onTab: (from, to) {
          if (kDebugMode) {
            print('from $from to $to');
          }
          setState(() {
            if (from.hour > to.hour) {
              _timeController.text = "Error";
            } else {
              _timeController.text =
                  "Inicio ${from.hour.toString()} - Cierre ${to.hour.toString()}";
            }
          });
          Navigator.pop(context);
        },
        dialogBackgroundColor: const Color(0xFF121212),
        fromHeadlineColor: Colors.white,
        toHeadlineColor: Colors.white,
        upIconColor: Colors.white,
        downIconColor: Colors.white,
        timeBoxColor: const Color(0xFF1E1E1E),
        timeHintColor: Colors.grey,
        timeTextColor: Colors.white,
        dividerColor: const Color(0xFF121212),
        doneTextColor: Colors.white,
        dismissTextColor: Colors.white,
        defaultDayNightColor: const Color(0xFF1E1E1E),
        defaultDayNightTextColor: Colors.white,
        colonColor: Colors.white,
        showHeaderBullet: true,
        headerText: 'Time available from 01:00 AM to 11:00 PM',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(23.0),
      child: Container(
        decoration: BoxDecoration(color: AppColores.background),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),

            Text("Nombre del evento", textAlign: TextAlign.start),
            TextField(
              controller: _nombreController,
              decoration: createAppDecoration(
                labelText: 'Ingrese nombre del evento',
              ),
            ),

            SizedBox(height: 12),

            Text("Fecha del evento"),

            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha',
                filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),
            const SizedBox(height: 10),

            Text("Horario del evento"),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Horario',
                filled: true,
                prefixIcon: Icon(Icons.punch_clock_rounded),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              readOnly: true,
              onTap: () => showLightTimePicker(),
            ),

            const SizedBox(height: 20),

            Text("Tipo de evento"),
            Flexible(
              child: DropdownMenu<String>(
                dropdownMenuEntries: tiposEvento.map<DropdownMenuEntry<String>>(
                  (String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                    );
                  },
                ).toList(),
                onSelected: (String? nuevoValor) {
                  setState(() {
                    tipoEventoSelccionado = nuevoValor;
                  });
                },

                label: const Text('Selecciona un tipo de evento'),
              ),
            ),

            Text("Cantidad de asistentes"),
            TextField(
              controller: _asistentesController,
              decoration: InputDecoration(
                labelText: 'Asistentes',
                filled: true,
                prefixIcon: Icon(Icons.people),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Only allow digits 0-9
              ],
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                widget.onDatosChanged({
                  'nombre': _nombreController.text,
                  'fecha': _fechaController.text,
                  'horario': _timeController.text,
                  'tipo': tipoEventoSelccionado ?? '',
                  'asistentes': _asistentesController.text,
                });
              },
              child: Text("Guardar datos"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_seleccionada != null) {
      setState(() {
        _fechaController.text = _seleccionada.toString().split(" ")[0];
      });
    }
  }
}

//Container(
//          decoration: BoxDecoration(
//            color: Colors.black,
//            borderRadius: BorderRadius.circular(5),
//          ),
//          height: 50,
//        ),
//
//        SizedBox(height: 12),
//
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Container(
//            decoration: BoxDecoration(
//              color: Colors.black,
//              borderRadius: BorderRadius.circular(5),
//            ),
//            height: 120,
//          ),
//        ),
