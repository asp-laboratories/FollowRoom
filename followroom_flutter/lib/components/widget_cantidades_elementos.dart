import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class WidgetCantidadElementos extends StatefulWidget {
  final int cantidadActual;
  final int stockMaximo;
  final Function(int) onChange;
  const WidgetCantidadElementos({
    super.key,
    required this.cantidadActual,
    required this.stockMaximo,
    required this.onChange,
  });

  @override
  State<WidgetCantidadElementos> createState() =>
      _WidgetCantidadElementosState();
}

class _WidgetCantidadElementosState extends State<WidgetCantidadElementos> {
  late TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(
      text: widget.cantidadActual.toString(),
    );
  }

  @override
  void didUpdateWidget(WidgetCantidadElementos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cantidadActual.toString() != _controlador.text) {
      final nuevaCantidad = int.tryParse(_controlador.text) ?? 0;
      if (nuevaCantidad != widget.cantidadActual) {
        _controlador.text = widget.cantidadActual.toString();
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _validacionActualizados(String valor) {
    int nuevaCantidad = int.tryParse(valor) ?? 0;

    if (nuevaCantidad > widget.stockMaximo) {
      nuevaCantidad = widget.stockMaximo;
      _controlador.text = nuevaCantidad.toString();
      _controlador.selection = TextSelection.fromPosition(
        TextPosition(offset: _controlador.text.length),
      );
    } else if (nuevaCantidad < 0) {
      nuevaCantidad = 0;
      _controlador.text = "0";
    }
    widget.onChange(nuevaCantidad);
  }

  @override
  Widget build(BuildContext context) {
    final puedeRestar = widget.cantidadActual > 0;
    final puedeSumar = widget.cantidadActual < widget.stockMaximo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: puedeRestar
              ? () {
                  _validacionActualizados(
                    (widget.cantidadActual - 1).toString(),
                  );
                  _controlador.text = (widget.cantidadActual - 1).toString();
                }
              : null,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Icon(
              Icons.remove_circle_outline,
              size: 22,
              color: puedeRestar ? AppColores.primary : Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 2),
        SizedBox(
          width: 40,
          child: TextField(
            controller: _controlador,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColores.primary, width: 1),
              ),
            ),
            onChanged: _validacionActualizados,
          ),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: puedeSumar
              ? () {
                  _validacionActualizados(
                    (widget.cantidadActual + 1).toString(),
                  );
                  _controlador.text = (widget.cantidadActual + 1).toString();
                }
              : null,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Icon(
              Icons.add_circle_outline,
              size: 22,
              color: puedeSumar ? AppColores.primary : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}