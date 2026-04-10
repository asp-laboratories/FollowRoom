import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/mobiliario_service.dart';

class NavigatorMobiliarioReservacion extends StatefulWidget {
  final List<Map<String, dynamic>> mobiliariosIniciales;
  final List<Map<String, dynamic>> mobiliariosSugeridos;

  const NavigatorMobiliarioReservacion({
    super.key,
    this.mobiliariosIniciales = const [],
    this.mobiliariosSugeridos = const [],
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
  List<Map<String, dynamic>> _mobiliariosConAdvertencia = [];

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  Future<void> _loadDatos() async {
    await Future.wait([_cargarTiposMobil(), _cargarMobiliarios()]);
    _precargarSugeridos();
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

  void _precargarSugeridos() {
    if (widget.mobiliariosSugeridos.isEmpty) return;

    _mobiliariosConAdvertencia = [];
    for (var sug in widget.mobiliariosSugeridos) {
      final mobId = sug['mobiliario'] ?? sug['mobiliario_id'] ?? sug['id'];
      final cantidadSugerida = sug['cantidad'] ?? 1;

      Map<String, dynamic>? mob;
      for (var m in _mobiliariosDB) {
        if (m['id'] == mobId) {
          mob = m;
          break;
        }
      }

      if (mob != null) {
        final stock = mob['stock'] ?? 0;
        bool esInsuficiente = cantidadSugerida > stock;

        _mobiliariosConAdvertencia.add({
          ...mob,
          'cantidad_sugerida': cantidadSugerida,
          'disponible': stock,
          'es_insuficiente': esInsuficiente,
        });
      }
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
      setState(() {
        _mobiliariosMostrados.addAll(
          _mobiliariosDB.sublist(startIndex, endIndex),
        );
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
    setState(() {
      if (cantidad == 0) {
        widget.mobiliariosIniciales.removeWhere(
          (m) => m['id'] == mobiliario['id'],
        );
      } else {
        final index = widget.mobiliariosIniciales.indexWhere(
          (m) => m['id'] == mobiliario['id'],
        );
        if (index >= 0) {
          widget.mobiliariosIniciales[index] = {
            ...mobiliario,
            'cantidad': cantidad,
          };
        } else {
          widget.mobiliariosIniciales.add({
            ...mobiliario,
            'cantidad': cantidad,
          });
        }
      }
    });
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, widget.mobiliariosIniciales);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Seleccionar Mobiliario"),
          backgroundColor: AppColores.background2,
          foregroundColor: AppColores.foreground,
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, widget.mobiliariosIniciales),
              child: Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppColores.background2,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.mobiliariosSugeridos.isNotEmpty)
                      _buildSugerencias(),
                    if (widget.mobiliariosIniciales.isNotEmpty)
                      _buildSeleccionados(),
                    _buildFiltro(),
                    _buildCatalogo(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSugerencias() {
    final tieneInsuficiente = _mobiliariosConAdvertencia.any(
      (m) => m['es_insuficiente'] == true,
    );

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: tieneInsuficiente ? Colors.orange : AppColores.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 18),
              SizedBox(width: 4),
              Text(
                "Sugerencias del montaje",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          if (tieneInsuficiente)
            Text(
              "⚠️ MOBILIARIO INSUFICIENTE",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          SizedBox(height: 8),
          ..._mobiliariosConAdvertencia.map(
            (m) => Text(
              "- ${m['nombre']} (sug: x${m['cantidad_sugerida']}) Disp: ${m['disponible']}",
              style: TextStyle(
                fontSize: 12,
                color: m['es_insuficiente'] == true
                    ? Colors.orange
                    : AppColores.foreground,
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  for (var sug in _mobiliariosConAdvertencia) {
                    final id = sug['id'];
                    final cantidad = sug['cantidad_sugerida'];
                    final idx = widget.mobiliariosIniciales.indexWhere(
                      (e) => e['id'] == id,
                    );
                    if (idx >= 0) {
                      widget.mobiliariosIniciales[idx]['cantidad'] = cantidad;
                    } else {
                      widget.mobiliariosIniciales.add({
                        'id': id,
                        'nombre': sug['nombre'],
                        'precio': sug['precio'],
                        'cantidad': cantidad,
                      });
                    }
                  }
                });
              },
              child: Text("Agregar sugerencias"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeleccionados() {
    final total = widget.mobiliariosIniciales.fold<int>(
      0,
      (sum, m) =>
          sum + ((m['precio'] as int? ?? 0) * (m['cantidad'] as int? ?? 1)),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: ContainerStyles.sombreado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mobiliarios seleccionados",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          ...widget.mobiliariosIniciales.map(
            (m) => Text(
              "- ${m['nombre']} (x${m['cantidad']}) \$${((m['precio'] as num?)?.toInt() ?? 0) * ((m['cantidad'] as num?)?.toInt() ?? 1)}",
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "\$$total",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColores.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltro() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<String>(
        value: tipoMobilSeleccionado,
        hint: Text("Todos los tipos"),
        isExpanded: true,
        underline: SizedBox(),
        items: [
          DropdownMenuItem(value: 'todos', child: Text("Todos")),
          ..._tiposMobil.map(
            (tipo) => DropdownMenuItem(
              value: tipo.toString(),
              child: Text(tipo.toString()),
            ),
          ),
        ],
        onChanged: (value) => setState(() {
          tipoMobilSeleccionado = value;
        }),
      ),
    );
  }

  Widget _buildCatalogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Catálogo de mobiliarios:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mob['nombre'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          mob['tipo_nombre'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                            ? () => actualizarCantidad(mob, cantidad - 1)
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
                        onPressed: () => actualizarCantidad(mob, cantidad + 1),
                        color: AppColores.primary,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
