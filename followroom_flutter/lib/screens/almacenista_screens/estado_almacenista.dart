import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';

const String baseUrl = "http://192.168.1.76:8000";

class AlmacenistaEstadoScreen extends StatefulWidget {
  const AlmacenistaEstadoScreen({super.key});

  @override
  State<AlmacenistaEstadoScreen> createState() =>
      _AlmacenistaEstadoScreenState();
}

class _AlmacenistaEstadoScreenState extends State<AlmacenistaEstadoScreen> {
  int _actualIndice = 0;
  bool _cargando = true;
  String _filtroAplicado = "Todos";

  List<dynamic> _datosObtenidos = [];
  List<dynamic> _datosMostrados = [];
  List<dynamic> _estadosDisponibles = []; 

  @override
  void initState() {
    super.initState();
    _datosBaseDatos();
  }

  Future<void> _datosBaseDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      // Definimos los endpoints según la pestaña (0 = Mobiliario, 1 = Equipamiento)
      final endpointItems = _actualIndice == 0
          ? '/api/inventario/mobiliario/lista/'
          : '/api/inventario/equipamiento/lista/';
          
      final endpointEstados = _actualIndice == 0
          ? '/api/estados/mobiliario/'
          : '/api/estados/equipamiento/';

      // Hacemos ambas peticiones en paralelo
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl$endpointItems')),
        http.get(Uri.parse('$baseUrl$endpointEstados')),
      ]);

      final responseItems = responses[0];
      final responseEstados = responses[1];

      if (responseItems.statusCode == 200 && responseEstados.statusCode == 200) {
        final List<dynamic> dataItems = json.decode(responseItems.body);
        final List<dynamic> dataEstados = json.decode(responseEstados.body);
        
        // Mapeamos el inventario y filtramos los que tienen stock 0
        final List<dynamic> mappedData = dataItems.map((item) {
          int totalDisponible = 0;
          for (var est in item['estados']) {
            totalDisponible += (est['cantidad'] as int);
          }
          
          return {
            'id': item['id'],
            'cosa': item['nombre'],
            'tipo': item['tipo'],
            'cantidadDisponible': totalDisponible,
            'estados': item['estados'],
          };
        }).where((item) => item['cantidadDisponible'] > 0).toList(); // <-- Filtro aplicado

        if (!mounted) return;

        setState(() {
          _datosObtenidos = mappedData;
          _datosMostrados = List.from(mappedData);
          _estadosDisponibles = dataEstados; 
          _filtroAplicado = "Todos";
          _cargando = false;
        });
      } else {
        throw Exception("Items: ${responseItems.statusCode} | Estados: ${responseEstados.statusCode}. Revisa tu servidor.");
      }
    } catch (e) {
      debugPrint("Error obteniendo datos: $e");
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  void _aplicarFiltro(String tipo) {
    setState(() {
      _filtroAplicado = tipo;

      if (tipo == "Todos") {
        _datosMostrados = List.from(_datosObtenidos);
      } else {
        _datosMostrados = _datosObtenidos.where((item) {
          return item['tipo'] == tipo;
        }).toList();
      }
    });
  }

  Future<List<String>> _tipos() async {
    final Set<String> tiposUnicos = {};
    for (var item in _datosObtenidos) {
      tiposUnicos.add(item['tipo'].toString());
    }
    return tiposUnicos.toList();
  }

  @override
  Widget build(BuildContext context) {

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

                  });
                  _datosBaseDatos();
                },
              ),
            ),

            GestureDetector(
              onTap: () async {
                List<String> tipos = await _tipos();

                if (!context.mounted) return;
                final String? seleccionado = await showModalBottomSheet<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return Filtro(tipos: tipos);
                  },
                );

                if (seleccionado != null) {
                  _aplicarFiltro(seleccionado);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Container(
                  decoration: ContainerStyles.sombreado,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        "Filtro: $_filtroAplicado",
                        style: TextEstilos.labelCard.copyWith(
                          color: AppColores.foreground,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 27,
                        color: AppColores.foreground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _cargando
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  )
                : _datosMostrados.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No se encontraron registros con stock."),
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
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: TarjetaMobiliarioElegante(
                                              itemData: itemActual,
                                              estadosDisponibles: _estadosDisponibles, 
                                              isEquipamiento: _actualIndice == 1,
                                              alActualizarExitosamente: () {
                                                Navigator.pop(context);
                                                _datosBaseDatos();
                                              },
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
                                              itemActual['cosa'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: AppColores.foreground,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            "Disponibles: ",
                                            style: TextEstilos.labelCard.copyWith(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            itemActual['cantidadDisponible'].toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: AppColores.foreground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Click para cambiar de estado",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColores.foreground.withOpacity(0.5),
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
  final Map<String, dynamic> itemData;
  final List<dynamic> estadosDisponibles; 
  final bool isEquipamiento;
  final VoidCallback alActualizarExitosamente;

  const TarjetaMobiliarioElegante({
    super.key,
    required this.itemData,
    required this.estadosDisponibles,
    required this.isEquipamiento,
    required this.alActualizarExitosamente,
  });

  @override
  State<TarjetaMobiliarioElegante> createState() =>
      _TarjetaMobiliarioEleganteState();
}

class _TarjetaMobiliarioEleganteState extends State<TarjetaMobiliarioElegante> {
  final String urlImage =
      "https://thumbs.dreamstime.com/z/silla-fea-maciza-aislada-en-el-fondo-blanco-101306793.jpg"; // Placeholder

  int? _idInventarioOrigen;
  String? _codigoEstadoDestino;
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;

  Future<void> _moverEstado() async {
    if (_idInventarioOrigen == null || _codigoEstadoDestino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona origen y destino válidos")),
      );
      return;
    }

    final int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La cantidad debe ser mayor a 0")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final endpoint = widget.isEquipamiento
          ? '/api/inventario/equipamiento/mover/'
          : '/api/inventario/mobiliario/mover/';

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "inventario_id": _idInventarioOrigen,
          "cantidad": cantidad,
          "nuevo_estado_codigo": _codigoEstadoDestino,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Movimiento exitoso"), backgroundColor: Colors.green),
        );
        widget.alActualizarExitosamente();
      } else {
        throw Exception(data['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtramos para que solo salgan en origen los que tienen cantidad > 0
    final List<dynamic> estadosOrigen = (widget.itemData['estados'] as List<dynamic>)
        .where((est) => (est['cantidad'] as int) > 0)
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: AppColores.primary.withOpacity(0.3),
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
                  const SizedBox(width: 24),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      urlImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${widget.isEquipamiento ? 'Equipamiento' : 'Mobiliario'}: ${widget.itemData['cosa']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColores.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: AppColores.primary.withOpacity(0.3)),
              const SizedBox(height: 10),
              Text(
                "Estados Actuales:",
                style: TextStyle(
                  color: AppColores.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              estadosOrigen.isEmpty
                  ? const Text("No hay inventario registrado o disponible.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: estadosOrigen.length,
                      itemBuilder: (context, index) {
                        final est = estadosOrigen[index];
                        return _buildEstadoRow(
                          context,
                          est['nombre_estado'],
                          est['cantidad'].toString(),
                          _getColorForIndex(index),
                        );
                      },
                    ),
              Divider(color: AppColores.primary.withOpacity(0.3)),
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
                    child: _buildDropdownOrigen(estadosOrigen),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward, color: Colors.grey),
                  ),
                  Expanded(
                    child: _buildDropdownDestino(widget.estadosDisponibles),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: _buildSmallInput(
                      context,
                      "Cantidad",
                      Icons.numbers,

                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _moverEstado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.swap_horiz_rounded),
                      label: Text(
                        _isLoading ? "Moviendo..." : "Cambiar Estado",
                        style: const TextStyle(
                          fontSize: 16,
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

  Color _getColorForIndex(int index) {
    const colors = [Colors.green, Colors.orange, Colors.red, Colors.blue];
    return colors[index % colors.length];
  }

  Widget _buildEstadoRow(BuildContext context, String label, String value, Color color) {
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

  Widget _buildDropdownOrigen(List<dynamic> estadosOrigen) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      decoration: _inputDecoration("De (estado)", Icons.output_rounded),
      value: _idInventarioOrigen,
      items: estadosOrigen.map<DropdownMenuItem<int>>((est) {
        return DropdownMenuItem<int>(
          value: est['id_inventario'] as int,
          child: Text(
            "${est['nombre_estado']} (${est['cantidad']})",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _idInventarioOrigen = newValue;
        });
      },
    );
  }

  Widget _buildDropdownDestino(List<dynamic> estadosBaseDatos) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: _inputDecoration("A (estado)", Icons.input_rounded),
      value: _codigoEstadoDestino,
      items: estadosBaseDatos.map<DropdownMenuItem<String>>((mapa) {
        return DropdownMenuItem<String>(
          value: mapa['codigo'].toString(), 
          child: Text(
            mapa['nombre'].toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _codigoEstadoDestino = newValue;
        });
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColores.foreground, fontSize: 12),
      prefixIcon: Icon(icon, size: 20, color: AppColores.primary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColores.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColores.primary.withOpacity(0.3)),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }


  Widget _buildSmallInput(BuildContext context, String label, IconData icon) {
    return TextField(
      controller: _cantidadController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label, icon),
    );
  }
}

class Filtro extends StatefulWidget {
  final List<String> tipos;

  const Filtro({super.key, required this.tipos});

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
              "Seleccione un tipo:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColores.foreground,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.all_inclusive, color: AppColores.primary),
            title: const Text("Quitar filtro"),
            onTap: () {
              Navigator.pop(context, "Todos");
            },
          ),
          Divider(color: AppColores.primary.withOpacity(0.3)),
          ...widget.tipos.map((tipo) {
            return ListTile(
              leading: Icon(Icons.category, color: AppColores.primary),
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
