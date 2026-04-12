import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/widget_cantidades_elementos.dart';
import 'package:followroom_flutter/services/tipo_mobiliario_service.dart';
import 'package:followroom_flutter/services/mobiliario_service.dart';

class TabMobiliariosReservacion extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onMobiliariosChanged;
  final List<Map<String, dynamic>> mobiliariosSeleccionados;
  final List<Map<String, dynamic>>? mobiliariosPaquete;
  final Map<String, dynamic>? salon;

  const TabMobiliariosReservacion({
    super.key,
    required this.onMobiliariosChanged,
    required this.mobiliariosSeleccionados,
    required this.salon,
    this.mobiliariosPaquete,
  });

  @override
  State<TabMobiliariosReservacion> createState() =>
      _TabMobiliariosReservacionState();
}

class _TabMobiliariosReservacionState extends State<TabMobiliariosReservacion> {
  final TipoMobiliarioService _servicioTipos = TipoMobiliarioService();
  final MobiliarioService _mobiliarioService = MobiliarioService();

  final int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  List<Map<String, dynamic>> _tiposMobiliarios = [];
  List<Map<String, dynamic>> _mobiliario = [];
  List<Map<String, dynamic>> _mobiliariosMostrados = [];
  int? tipoMobiliarioSeleccionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  Future<void> _loadDatos() async {
    if (!mounted) return;
    await Future.wait([_loadTiposmobiliario(), _loadMobiliarios()]);
  }

  Future<void> _loadTiposmobiliario() async {
    List<Map<String, dynamic>> tiposMobiliariosObtenidos = await _servicioTipos
        .getTiposMobiliarios();

    setState(() {
      _tiposMobiliarios = tiposMobiliariosObtenidos;
    });
  }

  Future<void> _loadMobiliarios() async {
    List<Map<String, dynamic>> mobiliariosObtenidos = await _mobiliarioService
        .getMobiliarios();
    setState(() {
      _mobiliario = mobiliariosObtenidos;
      _mobiliariosMostrados = mobiliariosObtenidos.take(_pageSize).toList();
      _currentPage = 1;
      _hasMoreData = mobiliariosObtenidos.length > _pageSize;
      isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _mobiliario.length);

    if (startIndex < _mobiliario.length) {
      final nuevosEquipos = _mobiliario.sublist(startIndex, endIndex);
      setState(() {
        _mobiliariosMostrados.addAll(
          nuevosEquipos.map((e) => Map<String, dynamic>.from(e)),
        );
        _currentPage++;
        _hasMoreData = endIndex < _mobiliario.length;
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
    print(tipoMobiliarioSeleccionado);
    if (tipoMobiliarioSeleccionado == null || tipoMobiliarioSeleccionado == 0) {
      return _mobiliariosMostrados;
    }
    return _mobiliariosMostrados
        .where((mob) => mob['tipo_movil']['id'] == tipoMobiliarioSeleccionado)
        .toList();
  }

  void actualizarCantidad(Map<String, dynamic> mobiliario, int cantidad) {
    final List<Map<String, dynamic>> nuevaLista = List.from(
      widget.mobiliariosSeleccionados,
    );

    if (cantidad == 0) {
      nuevaLista.removeWhere((e) => e['id'] == mobiliario['id']);
    } else {
      final index = nuevaLista.indexWhere((e) => e['id'] == mobiliario['id']);
      if (index >= 0) {
        nuevaLista[index] = {...mobiliario, 'cantidad': cantidad};
      } else {
        nuevaLista.add({...mobiliario, 'cantidad': cantidad});
      }
    }

    widget.onMobiliariosChanged(nuevaLista);
  }

  int getCantidadDisponible(Map<String, dynamic> mobiliario) {
    final detalles = mobiliario['inventario_detalles'] as List;

    return detalles
        .where(
          (disponibles) =>
              disponibles['estado_mobil']?.toString().toUpperCase() == 'DISPO',
        )
        .fold(
          0,
          (sum, disponible) => sum + (disponible['cantidad'] as num).toInt(),
        );
  }

  int totalInlcuidosPaquete(Map<String, dynamic> mobiliario) {
    if (widget.mobiliariosPaquete == null ||
        widget.mobiliariosPaquete!.isEmpty) {
      return 0;
    }

    int total = 0;

    for (var mob in widget.mobiliariosPaquete!) {
      final mobiliarioPaquete = mob['mobiliario']?['id'];
      if (mobiliarioPaquete == mobiliario['id']) {
        total += (mob['cantidad'] as num?)?.toInt() ?? 1;
      }
    }

    return total;
  }

  int getCantidad(Map<String, dynamic> mobiliario) {
    final found = widget.mobiliariosSeleccionados.where(
      (e) => e['id'] == mobiliario['id'],
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
            if ((widget.mobiliariosPaquete != null &&
                    widget.mobiliariosPaquete!.isNotEmpty) ||
                widget.mobiliariosSeleccionados.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: ContainerStyles.sombreado,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.mobiliariosPaquete != null &&
                          widget.mobiliariosPaquete!.isNotEmpty) ...[
                        Text(
                          "Mobiliario incluido en el paquete:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        ...widget.mobiliariosPaquete!.map((mob) {
                          final nombre =
                              mob['mobiliario']?['nombre'] ?? 'Mobiliario';

                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "- $nombre (x${mob['cantidad']})",
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "Incluido",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Divider(height: 16),
                      ],

                      Text(
                        "Mobiliarios seleccionados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (widget.mobiliariosSeleccionados.isEmpty)
                        Text("Sin mobiliarios", style: TextStyle(fontSize: 12))
                      else
                        ...widget.mobiliariosSeleccionados.map(
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
                                  "\$${double.parse(e['costo'].toString()) * double.parse(e['cantidad'].toString())}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.mobiliariosSeleccionados.isNotEmpty) ...[
                        Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Seleccionados:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "\$${widget.mobiliariosSeleccionados.fold<double>(0, (sum, e) => sum + ((double.parse(e['costo'].toString())) * (double.parse(e['cantidad'].toString()))))}",
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
                      child: DropdownButton<int>(
                        value: tipoMobiliarioSeleccionado,
                        hint: Text("Todos"),
                        isExpanded: true,
                        items: isLoading
                            ? [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("Cargando..."),
                                ),
                              ]
                            : [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("Todos"),
                                ),
                                ..._tiposMobiliarios.map(
                                  (value) => DropdownMenuItem(
                                    value: value['id'],
                                    child: Text(value['nombre'].toString()),
                                  ),
                                ),
                              ],
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  tipoMobiliarioSeleccionado = value;
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
                "Catálogo de mobiliarios:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: mobiliariosFiltrados.length,
              itemBuilder: (context, index) {
                final mobiliario = mobiliariosFiltrados[index];
                final cantidad = getCantidad(mobiliario);
                final mobiliarioInlcuido = totalInlcuidosPaquete(mobiliario);
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
                                    mobiliario['nombre'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColores.foreground,
                                    ),
                                  ),
                                  Text(
                                    mobiliario['descripcion'],
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Row(
                                    children: [
                                      if (mobiliario['descripcion_mob'] != null)
                                        ...(mobiliario['descripcion_mob']
                                                as List)
                                            .map(
                                              (caracteristica) => Text(
                                                " - ${caracteristica['descripcion']}",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                      else
                                        Text(
                                          "No se encontraron caracteristicas",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                    ],
                                  ),

                                  if (mobiliarioInlcuido > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        "El paquete incluye $mobiliarioInlcuido de este mobiliario",
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  Text(
                                    "\$${mobiliario['costo']} c/u - Stock: ${getCantidadDisponible(mobiliario)}",
                                    style: TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            WidgetCantidadElementos(
                              cantidadActual: cantidad,
                              stockMaximo: getCantidadDisponible(mobiliario),
                              onChange: (nuevaCantidad) {
                                actualizarCantidad(mobiliario, nuevaCantidad);
                              },
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


