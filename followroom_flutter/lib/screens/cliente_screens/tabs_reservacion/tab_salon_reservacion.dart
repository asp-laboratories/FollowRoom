import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/screens/cliente_screens/navigator_reservacion/navigator_montaje_reservacion.dart';

class TabSalon extends StatefulWidget {
  final String? montajeSeleccionado;
  final Function(String) onMontajeSelected;

  const TabSalon({
    super.key,
    required this.montajeSeleccionado,
    required this.onMontajeSelected,
  });

  @override
  State<TabSalon> createState() => _TabSalonState();
}

class _TabSalonState extends State<TabSalon> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColores.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Salon"),
                Text("Salon"),
                Text("Salon"),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final resultado = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavigatorMontajeReservacion(),
                          ),
                        );
                        if (resultado != null) {
                          widget.onMontajeSelected(resultado);
                        }
                      },
                      child: Text(
                        widget.montajeSeleccionado ?? "Selecciona un montaje",
                      ),
                    ),
                    if (widget.montajeSeleccionado != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
