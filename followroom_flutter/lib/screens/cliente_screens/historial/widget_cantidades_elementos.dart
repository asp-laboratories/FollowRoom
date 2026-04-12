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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón Menos
        IconButton(
          onPressed: widget.cantidadActual > 0
              ? () {
                  _validacionActualizados(
                    (widget.cantidadActual - 1).toString(),
                  );
                  _controlador.text = (widget.cantidadActual - 1).toString();
                }
              : null,
          icon: Icon(Icons.remove_circle_outline),
          color: widget.cantidadActual > 0 ? AppColores.primary : Colors.grey,
        ),

        // El nuevo Campo de Texto
        SizedBox(
          width: 50,
          child: TextField(
            controller: _controlador,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColores.primary, width: 2),
              ),
            ),
            onChanged: _validacionActualizados,
          ),
        ),

        // Botón Más
        IconButton(
          onPressed: widget.cantidadActual < widget.stockMaximo
              ? () {
                  _validacionActualizados(
                    (widget.cantidadActual + 1).toString(),
                  );
                  _controlador.text = (widget.cantidadActual + 1).toString();
                }
              : null,
          icon: Icon(Icons.add_circle_outline),
          color: widget.cantidadActual < widget.stockMaximo
              ? AppColores.primary
              : Colors.grey,
        ),
      ],
    );
  }
}