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
  String _filtroAplicado = "";
  List<Map<String, dynamic>> _tipos = [];

  List<dynamic> _datosObtenidos = [];
  List<dynamic> _datosMostrados = [];

  @override
  void initState() {
    super.initState();
    _datosBaseDatos();
    _cargarTipos();
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
        _datosMostrados = List.from(datosObtenidos);
        _filtroAplicado = "Todos";
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

  void _aplicarFiltro(String tipo) {
    setState(() {
      _filtroAplicado = tipo;

      if (tipo == "Todos") {
        _datosMostrados = List.from(_datosObtenidos);
      } else {
        _datosMostrados = _datosObtenidos.where((item) {
          if (_buscar) {
            return item['equipamiento']?['tipo_equipa']?['nombre']
                    ?.toString() ==
                tipo;
          } else {
            return item['mobiliario']?['tipo_movil']?['nombre']?.toString() ==
                tipo;
          }
        }).toList();
      }
    });
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
    if (_actualIndice == 0) {
      _buscar = true;
    } else {
      _buscar = false;
    }

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
                    _cargando = true;
                  });
                  _datosBaseDatos();
                },
              ),
            ),

            GestureDetector(
              onTap: () async {
                if (_tipos.isEmpty) {
                  await _cargarTipos();
                }
                final listaNombres = _tipos
                    .map((t) => t['nombre']?.toString() ?? '')
                    .toList();

                final String? seleccionado = await showModalBottomSheet<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return Filtro(tipos: listaNombres);
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
                                        padding: EdgeInsets.all(10),
                                        child: TarjetaMobiliarioElegante(
                                          idMobiliario: 1,
                                          equipamientoMobiliario: _buscar,
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
                                          _buscar
                                              ? (itemActual['equipamiento']?['nombre']
                                                        ?.toString() ??
                                                    'Sin nombre')
                                              : (itemActual['mobiliario']?['nombre']
                                                        ?.toString() ??
                                                    'Sin nombre'),
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

class TarjetaMobiliarioElegante extends StatelessWidget {
  final int idMobiliario;
  final bool
  equipamientoMobiliario; // Este nos dice si es equipamiento o mobiliario

  TarjetaMobiliarioElegante({
    super.key,
    required this.idMobiliario,
    required this.equipamientoMobiliario,
  });

  // Logica para obtener datos del mobilairios
  final String nombre = "silla fea";
  final String urlImage =
      "https://thumbs.dreamstime.com/z/silla-fea-maciza-aislada-en-el-fondo-blanco-101306793.jpg";
  final List<Map<String, dynamic>> estaos = [
    {'nombreEstado': "Disponible", 'cantidad': 12},
    {'nombreEstado': "No disponible", 'cantidad': 12},
    {'nombreEstado': "En reparacion", 'cantidad': 12},
  ];
  final List<Map<String, dynamic>> tipos = [
    {'nombreEstado': "Diponible"},
    {'nombreEstado': "En reparacion"},
    {'nombreEstado': "No disponible"},
    {'nombreEstado': "Descompuesta"},
  ];

  @override
  Widget build(BuildContext context) {
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${equipamientoMobiliario ? 'Mobiliario' : 'Equipamiento'}: $nombre",
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
              Divider(color: AppColores.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              Text(
                "Estados:",
                style: TextStyle(
                  color: AppColores.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: estaos.length,
                itemBuilder: (context, index) {
                  final itemActual = estaos[index];
                  return _buildEstadoRow(
                    context,
                    itemActual['nombreEstado'],
                    itemActual['cantidad'].toString(),
                    index == 0
                        ? Colors.green
                        : index == (estaos.length - 1)
                        ? Colors.red
                        : Colors.orange,
                  );
                },
              ),
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
                      context,
                      "De (estado)",
                      Icons.output_rounded,
                      estaos,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Icon(Icons.arrow_forward, color: Colors.grey),
                  ),
                  Expanded(
                    child: _selectInput(
                      context,
                      "A (estado)",
                      Icons.input_rounded,
                      tipos,
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
                      context,
                      "Total",
                      Icons.numbers,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text(
                        "Cambiar Estado",
                        style: TextStyle(
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

  // Widget para las filas de estado (con el punto de color)
  Widget _buildEstadoRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
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
    BuildContext contex,
    String label,
    IconData icon,
    List<Map<String, dynamic>> tipos,
  ) {
    return DropdownButtonFormField(
      isExpanded: true,
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
      items: tipos.map((Map<String, dynamic> mapa) {
        return DropdownMenuItem<dynamic>(
          value: 4,
          child: Text(
            mapa['nombreEstado'].toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      // ignore: non_constant_identifier_names
      onChanged: (None) {},
    );
  }

  // Widget para los campos de texto modernos
  Widget _buildSmallInput(
    BuildContext context,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
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

  const Filtro({super.key, required this.tipos});

  @override
  State<Filtro> createState() => _FiltroState();
}

class _FiltroState extends State<Filtro> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
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
            title: Text("Quitar filtro"),
            onTap: () {
              Navigator.pop(context, "Todos");
            },
          ),
          Divider(color: AppColores.primary.withValues(alpha: 0.3)),
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
