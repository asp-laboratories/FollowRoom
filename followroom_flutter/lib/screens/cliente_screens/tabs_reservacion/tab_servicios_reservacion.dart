import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:followroom_flutter/services/servicio_service.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class TabServiciosReservacion extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onServiciosChanged;
  final List<Map<String, dynamic>> serviciosSeleccionados;

  const TabServiciosReservacion({
    super.key,
    required this.onServiciosChanged,
    required this.serviciosSeleccionados,
  });

  @override
  State<TabServiciosReservacion> createState() =>
      _TabServiciosReservacionState();
}

class _TabServiciosReservacionState extends State<TabServiciosReservacion> {
  final ServicioService _servicioService = ServicioService();
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  List<dynamic> _tiposServicios = [];
  List<Map<String, dynamic>> _serviciosDB = [];
  List<Map<String, dynamic>> _serviciosMostrados = [];
  String? tiposServicioSeleccionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  Future<void> _loadDatos() async {
    await Future.wait([_loadTiposServicio(), _loadServicios()]);
  }

  Future<void> _loadTiposServicio() async {
    try {
      final response = await http.get(
        Uri.parse('http://${IpConfig.ip}/api/tipo-servicio/'),
      );
      print("tipo-servicio status: ${response.statusCode}");
      print("tipo-servicio body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _tiposServicios = data
              .map((e) => e['nombre']?.toString() ?? '')
              .toList();
        });
      }
    } catch (e) {
      print("Error loading tipos servicio: $e");
    }
  }

  Future<void> _loadServicios() async {
    try {
      final response = await http.get(
        Uri.parse('http://${IpConfig.ip}/api/servicio/'),
      );
      print("servicio response status: ${response.statusCode}");
      print("servicio response body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _serviciosDB = data
              .map(
                (e) => {
                  'id': e['id'],
                  'nombre': e['nombre'] ?? '',
                  'descripcion': e['descripcion'] ?? '',
                  'precio': e['costo'] ?? 0,
                  'tipo': e['tipo_servicio']?.toString() ?? 'sin tipo',
                },
              )
              .toList();
          _serviciosMostrados = _serviciosDB.take(_pageSize).toList();
          _currentPage = 1;
          _hasMoreData = _serviciosDB.length > _pageSize;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading servicios: $e");
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
    final endIndex = (startIndex + _pageSize).clamp(0, _serviciosDB.length);

    if (startIndex < _serviciosDB.length) {
      final nuevosServicios = _serviciosDB.sublist(startIndex, endIndex);
      setState(() {
        _serviciosMostrados.addAll(
          nuevosServicios.map((e) => Map<String, dynamic>.from(e)),
        );
        _currentPage++;
        _hasMoreData = endIndex < _serviciosDB.length;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get serviciosFiltrados {
    if (tiposServicioSeleccionado == null ||
        tiposServicioSeleccionado == 'todos') {
      return _serviciosMostrados;
    }
    return _serviciosMostrados
        .where(
          (s) =>
              s['tipo']?.toString().toLowerCase() ==
              tiposServicioSeleccionado?.toLowerCase(),
        )
        .toList();
  }

  void toggleServicio(Map<String, dynamic> servicio) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.serviciosSeleccionados,
    );

    if (nuevaLista.any((s) => s['id'] == servicio['id'])) {
      nuevaLista.removeWhere((s) => s['id'] == servicio['id']);
    } else {
      nuevaLista.add(servicio);
    }

    widget.onServiciosChanged(nuevaLista);
  }

  bool isSelected(Map<String, dynamic> servicio) {
    return widget.serviciosSeleccionados.any((s) => s['id'] == servicio['id']);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.serviciosSeleccionados.isNotEmpty) ...[
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
                        "Servicios seleccionados (${widget.serviciosSeleccionados.length})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (widget.serviciosSeleccionados.isEmpty)
                        Text("Sin servicios", style: TextStyle(fontSize: 12))
                      else
                        ...widget.serviciosSeleccionados.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    "- ${s['nombre']}",
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "\$${s['precio']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.serviciosSeleccionados.isNotEmpty) ...[
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
                              "\$${widget.serviciosSeleccionados.fold<int>(0, (sum, s) => sum + ((s['precio'] as num?)?.toInt() ?? 0))}",
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
                        value: tiposServicioSeleccionado,
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
                                ..._tiposServicios.map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                ),
                              ],
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  tiposServicioSeleccionado = value;
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
                "Catálogo de servicios:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: serviciosFiltrados.length,
              itemBuilder: (context, index) {
                final servicio = serviciosFiltrados[index];
                final seleccionado = isSelected(servicio);

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => toggleServicio(servicio),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Checkbox(
                              value: seleccionado,
                              onChanged: (_) => toggleServicio(servicio),
                              activeColor: AppColores.primary,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    servicio['nombre'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColores.foreground,
                                    ),
                                  ),
                                  Text(
                                    servicio['descripcion'],
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "\$${servicio['precio']}",
                                    style: TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColores.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                servicio['tipo'],
                                style: TextStyle(
                                  color: AppColores.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
