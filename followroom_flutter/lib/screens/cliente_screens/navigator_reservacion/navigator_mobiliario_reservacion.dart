import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/mobiliario_service.dart';

class NavigatorMobiliarioReservacion extends StatefulWidget {
  final List<Map<String, dynamic>> mobiliariosIniciales;

  const NavigatorMobiliarioReservacion({
    super.key,
    this.mobiliariosIniciales = const [],
  });

  @override
  State<NavigatorMobiliarioReservacion> createState() =>
      _NavigatorMobiliarioReservacionState();
}

class _NavigatorMobiliarioReservacionState
    extends State<NavigatorMobiliarioReservacion> {
  final MobiliarioService _mobiliarioService = MobiliarioService();
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  List<dynamic> _tiposMobil = [];
  List<Map<String, dynamic>> _mobiliariosDB = [];
  List<Map<String, dynamic>> _mobiliariosMostrados = [];
  String? tipoMobilSeleccionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  Future<void> _loadDatos() async {
    await Future.wait([_cargarTiposMobil(), _cargarMobiliarios()]);
  }

  Future<void> _cargarTiposMobil() async {
    try {
      final data = await _mobiliarioService.getTiposMobil();
      setState(() {
        _tiposMobil = data
            .map((e) => e['nombre']?.toString() ?? '')
            .toList()
            .toSet()
            .toList();
      });
    } catch (e) {
      print('Error al cargar tipos: $e');
    }
  }

  Future<void> _cargarMobiliarios() async {
    try {
      final data = await _mobiliarioService.getMobiliarios();
      setState(() {
        _mobiliariosDB = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _mobiliariosMostrados = _mobiliariosDB.take(_pageSize).toList();
        _currentPage = 1;
        _hasMoreData = _mobiliariosDB.length > _pageSize;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar mobiliarios: $e');
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
    final endIndex = (startIndex + _pageSize).clamp(0, _mobiliariosDB.length);

    if (startIndex < _mobiliariosDB.length) {
      final nuevosItems = _mobiliariosDB.sublist(startIndex, endIndex);
      setState(() {
        _mobiliariosMostrados.addAll(nuevosItems);
        _currentPage++;
        _hasMoreData = endIndex < _mobiliariosDB.length;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get mobiliariosFiltrados {
    if (tipoMobilSeleccionado == null || tipoMobilSeleccionado == 'todos') {
      return _mobiliariosMostrados;
    }
    return _mobiliariosMostrados
        .where(
          (m) =>
              m['tipo_nombre']?.toString().toLowerCase() ==
              tipoMobilSeleccionado?.toLowerCase(),
        )
        .toList();
  }

  void actualizarCantidad(Map<String, dynamic> mobiliario, int cantidad) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.mobiliariosIniciales,
    );

    if (cantidad == 0) {
      nuevaLista.removeWhere((m) => m['id'] == mobiliario['id']);
    } else {
      final index = nuevaLista.indexWhere((m) => m['id'] == mobiliario['id']);
      if (index >= 0) {
        nuevaLista[index] = {...mobiliario, 'cantidad': cantidad};
      } else {
        nuevaLista.add({...mobiliario, 'cantidad': cantidad});
      }
    }

    Navigator.pop(context, nuevaLista);
  }

  int getCantidad(Map<String, dynamic> mobiliario) {
    final found = widget.mobiliariosIniciales.where(
      (m) => m['id'] == mobiliario['id'],
    );
    if (found.isEmpty) return 0;
    return found.first['cantidad'] as int;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Mobiliario"),
        backgroundColor: AppColores.background2,
        foregroundColor: AppColores.foreground,
      ),
      backgroundColor: AppColores.background2,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(color: AppColores.background2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.mobiliariosIniciales.isNotEmpty) ...[
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
                                "Mobiliarios seleccionados",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...widget.mobiliariosIniciales.map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "- ${m['nombre']} (x${m['cantidad']})",
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "\$${((m['precio'] as num?)?.toInt() ?? 0) * ((m['cantidad'] as num?)?.toInt() ?? 1)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "\$${widget.mobiliariosIniciales.fold<int>(0, (sum, m) => sum + (((m['precio'] as num?)?.toInt() ?? 0) * ((m['cantidad'] as num?)?.toInt() ?? 1)))}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColores.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Filtrar por tipo:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String?>(
                          value: tipoMobilSeleccionado,
                          hint: Text("Todos los tipos"),
                          isExpanded: true,
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem<String?>(
                              value: 'todos',
                              child: Text("Todos"),
                            ),
                            ..._tiposMobil.map((tipo) {
                              return DropdownMenuItem<String?>(
                                value: tipo.toString(),
                                child: Text(tipo.toString()),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              tipoMobilSeleccionado = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Catálogo de mobiliarios:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      itemCount: mobiliariosFiltrados.length + 1,
                      itemBuilder: (context, index) {
                        if (index == mobiliariosFiltrados.length) {
                          if (_hasMoreData) {
                            return Center(
                              child: _isLoadingMore
                                  ? CircularProgressIndicator()
                                  : TextButton(
                                      onPressed: _loadMore,
                                      child: Text("Cargar más"),
                                    ),
                            );
                          }
                          return SizedBox();
                        }

                        final mob = mobiliariosFiltrados[index];
                        final cantidad = getCantidad(mob);

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: ContainerStyles.sombreado,
                          child: Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mob['nombre'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          mob['tipo_nombre'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "\$${mob['precio'] ?? 0}",
                                              style: TextStyle(
                                                color: AppColores.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Stock: ${mob['stock'] ?? 0}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        onPressed: cantidad > 0
                                            ? () => actualizarCantidad(
                                                mob,
                                                cantidad - 1,
                                              )
                                            : null,
                                        color: AppColores.primary,
                                      ),
                                      Text(
                                        "$cantidad",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        onPressed: () => actualizarCantidad(
                                          mob,
                                          cantidad + 1,
                                        ),
                                        color: AppColores.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
