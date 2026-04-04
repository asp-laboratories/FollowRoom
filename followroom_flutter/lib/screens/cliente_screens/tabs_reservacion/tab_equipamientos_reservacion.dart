import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TabEquipamientosReservacion extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onEquipamientosChanged;
  final List<Map<String, dynamic>> equipamientosSeleccionados;

  const TabEquipamientosReservacion({
    super.key,
    required this.onEquipamientosChanged,
    required this.equipamientosSeleccionados,
  });

  @override
  State<TabEquipamientosReservacion> createState() =>
      _TabEquipamientosReservacionState();
}

class _TabEquipamientosReservacionState
    extends State<TabEquipamientosReservacion> {
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  List<dynamic> _tiposEquipamiento = [];
  List<Map<String, dynamic>> _equipamientosDB = [];
  List<Map<String, dynamic>> _equipamientosMostrados = [];
  String? tiposEquipamientoSeleccionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  Future<void> _loadDatos() async {
    await Future.wait([_loadTiposEquipamiento(), _loadEquipamientos()]);
  }

  Future<void> _loadTiposEquipamiento() async {
    try {
      final response = await http.get(
        Uri.parse('http://${IpConfig.ip}/api/tipo-equipa/'),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _tiposEquipamiento = data
              .map((e) => e['nombre']?.toString() ?? '')
              .toList();
        });
      }
    } catch (e) {
      print("Error loading tipos equipamiento: $e");
    }
  }

  Future<void> _loadEquipamientos() async {
    try {
      final response = await http.get(
        Uri.parse('http://${IpConfig.ip}/api/equipamiento/'),
      );
      print("equipamiento response status: ${response.statusCode}");
      print("equipamiento response body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _equipamientosDB = data
              .map(
                (e) => {
                  'id': e['id'],
                  'nombre': e['nombre'] ?? '',
                  'tipo': e['tipo_equipa']?.toString() ?? 'sin tipo',
                  'descripcion': e['descripcion'] ?? '',
                  'precio': e['costo'] ?? 0,
                  'stock': e['stock'] ?? 0,
                },
              )
              .toList();
          _equipamientosMostrados = _equipamientosDB.take(_pageSize).toList();
          _currentPage = 1;
          _hasMoreData = _equipamientosDB.length > _pageSize;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading equipamentos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _equipamientosDB.length);

    if (startIndex < _equipamientosDB.length) {
      final nuevosEquipos = _equipamientosDB.sublist(startIndex, endIndex);
      setState(() {
        _equipamientosMostrados.addAll(
          nuevosEquipos.map((e) => Map<String, dynamic>.from(e)),
        );
        _currentPage++;
        _hasMoreData = endIndex < _equipamientosDB.length;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get equipamientosFiltrados {
    if (tiposEquipamientoSeleccionado == null ||
        tiposEquipamientoSeleccionado == 'todos') {
      return _equipamientosMostrados;
    }
    return _equipamientosMostrados
        .where(
          (equipa) =>
              equipa['tipo']?.toString().toLowerCase() ==
              tiposEquipamientoSeleccionado?.toLowerCase(),
        )
        .toList();
  }

  void actualizarCantidad(Map<String, dynamic> equipamiento, int cantidad) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.equipamientosSeleccionados,
    );

    if (cantidad == 0) {
      nuevaLista.removeWhere((e) => e['id'] == equipamiento['id']);
    } else {
      final index = nuevaLista.indexWhere((e) => e['id'] == equipamiento['id']);
      if (index >= 0) {
        nuevaLista[index] = {...equipamiento, 'cantidad': cantidad};
      } else {
        nuevaLista.add({...equipamiento, 'cantidad': cantidad});
      }
    }

    widget.onEquipamientosChanged(nuevaLista);
  }

  int getCantidad(Map<String, dynamic> equipamiento) {
    final found = widget.equipamientosSeleccionados.where(
      (e) => e['id'] == equipamiento['id'],
    );
    if (found.isEmpty) return 0;
    return found.first['cantidad'] as int;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.equipamientosSeleccionados.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: ContainerStyles.sombreado,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Equipamientos seleccionados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (widget.equipamientosSeleccionados.isEmpty)
                        Text("Sin equipos", style: TextStyle(fontSize: 12))
                      else
                        ...widget.equipamientosSeleccionados.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    "- ${e['nombre']} (x${e['cantidad']})",
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "\$${(e['precio'] as int) * (e['cantidad'] as int)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.equipamientosSeleccionados.isNotEmpty) ...[
                        Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "\$${widget.equipamientosSeleccionados.fold<int>(0, (sum, e) => sum + (((e['precio'] as num?)?.toInt() ?? 0) * ((e['cantidad'] as num?)?.toInt() ?? 1)))}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColores.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: ContainerStyles.sombreado,
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      "Filtrar:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: tiposEquipamientoSeleccionado,
                        hint: Text("Todos"),
                        isExpanded: true,
                        items: isLoading
                            ? [
                                DropdownMenuItem(
                                  value: 'cargando',
                                  child: Text("Cargando..."),
                                ),
                              ]
                            : [
                                DropdownMenuItem(
                                  value: 'todos',
                                  child: Text("Todos"),
                                ),
                                ..._tiposEquipamiento.map(
                                  (value) => DropdownMenuItem(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  ),
                                ),
                              ],
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  tiposEquipamientoSeleccionado = value;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Catálogo de equipamiento:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: equipamientosFiltrados.length,
              itemBuilder: (context, index) {
                final equipamiento = equipamientosFiltrados[index];
                final cantidad = getCantidad(equipamiento);

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    equipamiento['nombre'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColores.foreground,
                                    ),
                                  ),
                                  Text(
                                    equipamiento['descripcion'],
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "\$${equipamiento['precio']} c/u - Stock: ${equipamiento['stock']}",
                                    style: TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: cantidad > 0
                                      ? () => actualizarCantidad(
                                          equipamiento,
                                          cantidad - 1,
                                        )
                                      : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: cantidad > 0
                                      ? AppColores.primary
                                      : Colors.grey,
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$cantidad",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      cantidad < (equipamiento['stock'] as int)
                                      ? () => actualizarCantidad(
                                          equipamiento,
                                          cantidad + 1,
                                        )
                                      : null,
                                  icon: Icon(Icons.add_circle_outline),
                                  color:
                                      cantidad < (equipamiento['stock'] as int)
                                      ? AppColores.primary
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_hasMoreData)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _isLoadingMore
                      ? CircularProgressIndicator(color: AppColores.primary)
                      : ElevatedButton(
                          onPressed: _loadMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Cargar más"),
                        ),
                ),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
