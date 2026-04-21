import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';
import 'package:followroom_flutter/services/inventario_service.dart';

class AlmacenistaEstadoScreen extends StatefulWidget {
  const AlmacenistaEstadoScreen({super.key});

  @override
  State<AlmacenistaEstadoScreen> createState() =>
      _AlmacenistaEstadoScreenState();
}

class _AlmacenistaEstadoScreenState extends State<AlmacenistaEstadoScreen> {
  final InventarioService _inventarioService = InventarioService();
  int _actualIndice = 0;
  bool _buscar = true;
  bool _cargando = true;
  String _filtroAplicado = "Todos";
  String _filtroEstadoAplicado = "Todos";
  List<Map<String, dynamic>> _tipos = [];
  Map<String, String> _nombresEstados = {'Todos': 'Todos los estados'};
  List<Map<String, dynamic>> _estadosBD = [];
  List<Map<String, dynamic>> _estadosMob = [];
  List<Map<String, dynamic>> _estadosEquipa = [];

  List<dynamic> _datosObtenidos = [];
  List<dynamic> _datosMostrados = [];

  @override
  void initState() {
    super.initState();
    _cargarEstados().then((_) {
      _cargarTipos();
      _datosBaseDatos();
    });
  }

  Future<void> _cargarEstados() async {
    try {
      final estados = await _inventarioService.getEstadosInventario();
      _estadosMob = List<Map<String, dynamic>>.from(estados['estados_mobiliario'] ?? []);
      _estadosEquipa = List<Map<String, dynamic>>.from(estados['estados_equipamiento'] ?? []);
      _actualizarEstadosPorIndice();
    } catch (e) {
      print('Error al cargar estados: $e');
    }
  }

  void _actualizarEstadosPorIndice() {
    final estadosFiltrar = _actualIndice == 0 ? _estadosMob : _estadosEquipa;
    setState(() {
      _estadosBD = List<Map<String, dynamic>>.from(estadosFiltrar);
      _nombresEstados = {'Todos': 'Todos los estados'};
      for (var e in estadosFiltrar) {
        final codigo = e['codigo']?.toString();
        final nombre = e['nombre']?.toString();
        if (codigo != null && nombre != null) {
          _nombresEstados[codigo] = nombre;
        }
      }
      _filtroEstadoAplicado = 'Todos';
    });
  }

  Future<void> _datosBaseDatos() async {
    try {
      print('Cargando datos... indice: $_actualIndice');
      final List<dynamic> datosObtenidos;

      if (_actualIndice == 0) {
        datosObtenidos = await _inventarioService.getInventarioMobiliario();
        print('Mobiliarios cargados: ${datosObtenidos.length}');
      } else {
        datosObtenidos = await _inventarioService.getInventarioEquipamiento();
        print('Equipamientos cargados: ${datosObtenidos.length}');
      }

      if (datosObtenidos.isNotEmpty) {
        print('Primer item: ${datosObtenidos.first}');
      }

      if (!mounted) return;

      setState(() {
        _datosObtenidos = datosObtenidos;
        _actualizarListaFiltrada(); // Aplicar filtros al cargar
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
      print('Error al cargar inventario: $e');
    }
  }

void _actualizarListaFiltrada() {
    setState(() {
      _datosMostrados = _datosObtenidos.where((item) {
        // --- FILTRO 0: CANTIDAD > 0 ---
        final int cantidad = item['cantidad'] ?? 0;
        if (cantidad <= 0) return false;

        // --- FILTRO 0b: EXCLUIR RESEV EN MOBILIARIO ---
        if (_actualIndice == 0) {
          final dynamic estadoData = item['estado_mobil'];
          String? codigoEstado;
          if (estadoData is Map) {
            codigoEstado = estadoData['codigo']?.toString();
          } else {
            codigoEstado = estadoData?.toString();
          }
          if (codigoEstado == 'RESEV') return false;
        }

        // --- FILTRO 1: CATEGORÍA (Tipo) ---
        bool coincideTipo = true;
        if (_filtroAplicado != "Todos") {
          final dynamic baseData = _actualIndice == 0
              ? item['mobiliario']
              : item['equipamiento'];
          if (baseData is Map) {
            dynamic tipoValue;
            if (_actualIndice == 0) {
              tipoValue = baseData['tipo_movil'] ?? baseData['tipo'];
            } else {
              tipoValue =
                  baseData['tipo_equipa'] ??
                  baseData['tipo_equipamiento'] ??
                  baseData['tipo_equipa_id'] ??
                  baseData['tipo_id'] ??
                  baseData['tipo'] ??
                  baseData['categoria'];
            }

            if (tipoValue is Map &&
                tipoValue['nombre']?.toString() == _filtroAplicado) {
              coincideTipo = true;
            } else if (tipoValue is String && tipoValue == _filtroAplicado) {
              coincideTipo = true;
            } else if (tipoValue != null) {
              final tipoEnCatalogo = _tipos.firstWhere(
                (t) => t['id'].toString() == tipoValue.toString(),
                orElse: () => {},
              );
              coincideTipo =
                  tipoEnCatalogo['nombre']?.toString() == _filtroAplicado;
            } else {
              coincideTipo = false;
            }
          } else {
            coincideTipo = false;
          }
        }

        // --- FILTRO 2: ESTADO (Disponible, Reparación, etc.) ---
        bool coincideEstado = true;
        if (_filtroEstadoAplicado != "Todos") {
          final dynamic estadoData = _actualIndice == 0
              ? item['estado_mobil']
              : item['estado_equipa'];

          if (estadoData is Map) {
            coincideEstado =
                estadoData['codigo']?.toString() == _filtroEstadoAplicado;
          } else {
            coincideEstado = estadoData?.toString() == _filtroEstadoAplicado;
          }
        }

        return coincideTipo && coincideEstado;
      }).toList();
    });
  }

  void _aplicarFiltro(String tipo) {
    _filtroAplicado = tipo;
    _actualizarListaFiltrada();
  }

  void _aplicarFiltroEstado(String codigoEstado) {
    _filtroEstadoAplicado = codigoEstado;
    _actualizarListaFiltrada();
  }

  Future<void> _cargarTipos() async {
    try {
      final tipos = _actualIndice == 0
          ? await _inventarioService.getTiposMobil()
          : await _inventarioService.getTiposEquipa();
      setState(() {
        _tipos = tipos;
      });
    } catch (e) {
      print('Error al cargar tipos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _buscar = (_actualIndice == 0);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Textos(
                texts: const ['Mobiliarios', 'Equipamientos'],
                seleccionActual: _actualIndice,
                alSeleccionar: (int nuevoIndice) {
                  setState(() {
                    _actualIndice = nuevoIndice;
                    _tipos = [];
                    _filtroAplicado = "Todos";
                    _cargando = true;
                  });
                  _actualizarEstadosPorIndice();
                  _datosBaseDatos();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Row(
                children: [
                  // Botón de Filtro de Categoría
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_tipos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cargando categorías...'),
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                          await _cargarTipos();
                        }

                        final listaNombres = _tipos
                            .map((t) => t['nombre']?.toString() ?? '')
                            .where((n) => n.isNotEmpty)
                            .toList();

                        if (mounted) {
                          final String? seleccionado =
                              await showModalBottomSheet<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Filtro(
                                    tipos: listaNombres,
                                    titulo: "Categoría",
                                  );
                                },
                              );

                          if (seleccionado != null) {
                            _aplicarFiltro(seleccionado);
                          }
                        }
                      },
                      child: Container(
                        decoration: ContainerStyles.sombreado,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _filtroAplicado,
                                overflow: TextOverflow.ellipsis,
                                style: TextEstilos.labelCard.copyWith(
                                  fontSize: 12,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.category,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de Filtro de Estado
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final String? seleccionado =
                            await showModalBottomSheet<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return Filtro(
                                  tipos: _nombresEstados.values.toList(),
                                  titulo: "Estado",
                                );
                              },
                            );

                        if (seleccionado != null) {
                          final codigo = _nombresEstados.entries
                              .firstWhere(
                                (e) => e.value == seleccionado,
                                orElse: () => const MapEntry('Todos', 'Todos'),
                              )
                              .key;
                          _aplicarFiltroEstado(codigo);
                        }
                      },
                      child: Container(
                        decoration: ContainerStyles.sombreado,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _nombresEstados[_filtroEstadoAplicado] ??
                                    "Estado",
                                overflow: TextOverflow.ellipsis,
                                style: TextEstilos.labelCard.copyWith(
                                  fontSize: 12,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.settings_suggest,
                              size: 20,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _cargando
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _datosMostrados.length,
                    itemBuilder: (context, index) {
                      final itemActual = _datosMostrados[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: ContainerStyles.sombreado,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TarjetaMobiliarioElegante(
                                          item: itemActual,
                                          fullList: _datosObtenidos,
                                          esEquipamiento: _actualIndice != 0,
                                          onUpdate: _datosBaseDatos,
                                          estados: _nombresEstados,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Nombre: ",
                                        style: TextEstilos.labelCard.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          () {
                                            final data = _actualIndice != 0
                                                ? itemActual['equipamiento']
                                                : itemActual['mobiliario'];
                                            if (data is Map)
                                              return data['nombre']
                                                      ?.toString() ??
                                                  'Sin nombre';
                                            return 'ID: ${data.toString()}';
                                          }(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: AppColores.foreground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        "Cantidad: ",
                                        style: TextEstilos.labelCard.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        itemActual['cantidad']?.toString() ??
                                            '0',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: AppColores.foreground,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColores.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          () {
                                            final data = _actualIndice != 0
                                                ? itemActual['estado_equipa']
                                                : itemActual['estado_mobil'];
                                            String? codigo;
                                            String? nombreFallback;
                                            if (data is Map) {
                                              codigo =
                                                  data['codigo']?.toString();
                                              nombreFallback =
                                                  data['nombre']?.toString();
                                            } else {
                                              codigo = data?.toString();
                                            }
                                            return _nombresEstados[codigo] ??
                                                nombreFallback ??
                                                'N/A';
                                          }(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColores.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Click para cambiar de estado",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColores.foreground.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontStyle: FontStyle.italic,
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
          ],
        ),
      ),
    );
  }
}

class TarjetaMobiliarioElegante extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<dynamic> fullList;
  final bool esEquipamiento;
  final VoidCallback onUpdate;
  final Map<String, String> estados;

  const TarjetaMobiliarioElegante({
    super.key,
    required this.item,
    required this.fullList,
    required this.esEquipamiento,
    required this.onUpdate,
    required this.estados,
  });

  @override
  State<TarjetaMobiliarioElegante> createState() =>
      _TarjetaMobiliarioEleganteState();
}

class _TarjetaMobiliarioEleganteState extends State<TarjetaMobiliarioElegante> {
  final InventarioService _inventarioService = InventarioService();
  final TextEditingController _cantidadController = TextEditingController();

  String? _estadoOrigen;
  String? _estadoDestino;
  bool _procesando = false;
  bool _cargandoResumen = true;
  List<Map<String, dynamic>> _resumenEstados = [];
  int _totalFisico = 0;
  Map<String, String> _nombresEstados = {};

  @override
  void initState() {
    super.initState();
    _nombresEstados = Map<String, String>.from(widget.estados);
    final data = widget.esEquipamiento
        ? widget.item['estado_equipa']
        : widget.item['estado_mobil'];

    if (data is Map) {
      _estadoOrigen = data['codigo']?.toString();
    } else {
      _estadoOrigen = data?.toString();
    }
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargandoResumen = true);
    try {
      final resumen = widget.esEquipamiento
          ? await _inventarioService.getResumenEstadosEquipa(widget.item['id'])
          : await _inventarioService.getResumenEstadosMob(widget.item['id']);

      if (resumen['status'] == 'success') {
        _resumenEstados = List<Map<String, dynamic>>.from(
          resumen['data'] ?? [],
        );
        _totalFisico = resumen['total'] ?? 0;
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
    if (mounted) setState(() => _cargandoResumen = false);
  }

  Future<void> _cambiarEstado() async {
    if (_estadoDestino == null || _cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    final int? cantidadMover = int.tryParse(_cantidadController.text);
    final int cantidadActual = widget.item['cantidad'] ?? 0;

    if (cantidadMover == null || cantidadMover <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cantidad no válida')));
      return;
    }

    if (cantidadMover > cantidadActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad mayor a la disponible')),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      // 1. Reducir cantidad del registro de ORIGEN
      final int nuevaCantidadOrigen = cantidadActual - cantidadMover;
      bool okOrigen = false;

      if (widget.esEquipamiento) {
        okOrigen = await _inventarioService.updateInventarioEquipa(
          widget.item['id'],
          nuevaCantidadOrigen,
          _estadoOrigen!,
        );
      } else {
        okOrigen = await _inventarioService.updateInventarioMob(
          widget.item['id'],
          nuevaCantidadOrigen,
          _estadoOrigen!,
        );
      }

      if (!okOrigen) throw Exception('Error al actualizar origen');

      // 2. Aumentar cantidad del registro de DESTINO
      // Buscamos si ya existe el elemento en ese estado en la lista completa
      final int elementoBaseId = widget.esEquipamiento
          ? (widget.item['equipamiento'] is Map
                ? widget.item['equipamiento']['id']
                : widget.item['equipamiento'])
          : (widget.item['mobiliario'] is Map
                ? widget.item['mobiliario']['id']
                : widget.item['mobiliario']);

      Map<String, dynamic>? itemDestino;
      try {
        itemDestino = widget.fullList.firstWhere((item) {
          final itemMuebleId = widget.esEquipamiento
              ? (item['equipamiento'] is Map
                    ? item['equipamiento']['id']
                    : item['equipamiento'])
              : (item['mobiliario'] is Map
                    ? item['mobiliario']['id']
                    : item['mobiliario']);

          final itemEstadoCod = widget.esEquipamiento
              ? (item['estado_equipa'] is Map
                    ? item['estado_equipa']['codigo']
                    : item['estado_equipa'])
              : (item['estado_mobil'] is Map
                    ? item['estado_mobil']['codigo']
                    : item['estado_mobil']);

          return itemMuebleId == elementoBaseId &&
              itemEstadoCod == _estadoDestino;
        });
      } catch (_) {
        itemDestino = null; // No existe
      }

      bool okDestino = false;
      if (itemDestino != null) {
        // ACTUALIZAR (PATCH)
        final int nuevaCantidadDestino =
            (itemDestino['cantidad'] ?? 0) + cantidadMover;
        if (widget.esEquipamiento) {
          okDestino = await _inventarioService.updateInventarioEquipa(
            itemDestino['id'],
            nuevaCantidadDestino,
            _estadoDestino!,
          );
        } else {
          okDestino = await _inventarioService.updateInventarioMob(
            itemDestino['id'],
            nuevaCantidadDestino,
            _estadoDestino!,
          );
        }
      } else {
        // CREAR (POST)
        if (widget.esEquipamiento) {
          okDestino = await _inventarioService.createInventarioEquipa(
            elementoBaseId,
            cantidadMover,
            _estadoDestino!,
          );
        } else {
          okDestino = await _inventarioService.createInventarioMob(
            elementoBaseId,
            cantidadMover,
            _estadoDestino!,
          );
        }
      }

      if (!okDestino) throw Exception('Error al actualizar destino');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento realizado con éxito')),
      );

      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = (() {
      final data = widget.esEquipamiento
          ? widget.item['equipamiento']
          : widget.item['mobiliario'];
      if (data is Map) return data['nombre']?.toString() ?? 'Sin nombre';
      return 'ID: ${data.toString()}';
    })();

    final String estadoActualNombre = (() {
      final data = widget.esEquipamiento
          ? widget.item['estado_equipa']
          : widget.item['estado_mobil'];
      String? codigo;
      String? nombreFallback;
      if (data is Map) {
        codigo = data['codigo']?.toString();
        nombreFallback = data['nombre']?.toString();
      } else {
        codigo = data?.toString();
      }
      return _nombresEstados[codigo] ?? nombreFallback ?? 'N/A';
    })();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: AppColores.primary.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColores.backgroundComponent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 40, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${widget.esEquipamiento ? 'Equipamiento' : 'Mobiliario'}: $nombre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColores.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: AppColores.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              _buildInfoRow("Estado Actual", estadoActualNombre, Colors.blue),
              _buildInfoRow(
                "Cantidad Total",
                widget.item['cantidad']?.toString() ?? '0',
                Colors.green,
              ),
              const SizedBox(height: 10),
              if (_cargandoResumen)
                const Center(child: CircularProgressIndicator())
              else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen por estado:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColores.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._resumenEstados.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '• ${e['estado_nombre']}: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColores.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${e['cantidad']} uds',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total físico:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$_totalFisico uds',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColores.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(color: AppColores.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              Text(
                "Registrar Movimiento:",
                style: TextStyle(
                  color: AppColores.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _selectInput(
                      "A (estado)",
                      Icons.input_rounded,
                      _nombresEstados.entries
                          .where((e) => e.key != _estadoOrigen)
                          .map((e) => {'codigo': e.key, 'nombre': e.value})
                          .toList(),
                      _estadoDestino,
                      (val) => setState(() => _estadoDestino = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: _buildSmallInput(
                      "Cantidad",
                      Icons.numbers,
                      controller: _cantidadController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _procesando ? null : _cambiarEstado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _procesando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.swap_horiz_rounded),
                      label: Text(
                        _procesando ? "Procesando..." : "Cambiar Estado",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text("$label: ", style: TextStyle(color: AppColores.foreground)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColores.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectInput(
    String label,
    IconData icon,
    List<Map<String, String>> opciones,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColores.foreground),
        prefixIcon: Icon(icon, size: 20, color: AppColores.primary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColores.primary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColores.primary.withValues(alpha: 0.3),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion['codigo'],
          child: Text(
            opcion['nombre']!,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSmallInput(
    String label,
    IconData icon, {
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColores.foreground),
        prefixIcon: Icon(icon, size: 20, color: AppColores.primary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColores.primary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColores.primary.withValues(alpha: 0.3),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class Filtro extends StatefulWidget {
  final List tipos;
  final String titulo;

  const Filtro({super.key, required this.tipos, this.titulo = "Filtro"});

  @override
  State<Filtro> createState() => _FiltroState();
}

class _FiltroState extends State<Filtro> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "Seleccione ${widget.titulo}:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColores.foreground,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.all_inclusive, color: AppColores.primary),
            title: const Text("Mostrar Todos"),
            onTap: () {
              Navigator.pop(context, "Todos");
            },
          ),
          Divider(color: AppColores.primary.withValues(alpha: 0.3)),
          ...widget.tipos.map((tipo) {
            return ListTile(
              leading: Icon(
                widget.titulo == "Estado"
                    ? Icons.settings_suggest
                    : Icons.category,
                color: AppColores.primary,
              ),
              title: Text(tipo),
              onTap: () {
                Navigator.pop(context, tipo);
              },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
