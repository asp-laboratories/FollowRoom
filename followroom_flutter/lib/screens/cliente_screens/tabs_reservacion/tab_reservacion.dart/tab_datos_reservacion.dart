import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/input_styles.dart';
import 'package:from_to_time_picker/from_to_time_picker.dart';

class TabDatosReservacion extends StatefulWidget {
  const TabDatosReservacion({super.key});

  @override
  State<TabDatosReservacion> createState() => _TabDatosReservacionState();
}

class _TabDatosReservacionState extends State<TabDatosReservacion> {
  final TextEditingController _fechaController = TextEditingController();

  String startTime = 'from';
  String endTime = 'to' '';

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
            if(from.hour>to.hour){
              startTime = '';
              endTime = 'Error';
            } else {
              startTime = from.hour.toString();
              endTime = to.hour.toString();
            }

          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),

        Text("Nombre del evento", textAlign: TextAlign.start),

        TextField(
          decoration: createAppDecoration(
            labelText: 'Correo electronico',
            prefixIcon: Icon(Icons.email),
          ),
        ),

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

        const Text('selected duration'),
        const SizedBox(height: 10),
        Text('$startTime - $endTime'),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => showLightTimePicker(),
          child: const Text(' show light time picker'),
        ),
        const SizedBox(height: 20),
      ],
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