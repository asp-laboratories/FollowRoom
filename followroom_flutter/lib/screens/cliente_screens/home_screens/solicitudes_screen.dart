import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final List<String> tiposMobiliario = ['oficina', 'eventos', 'infantil'];
  final List<String> tiposEquipamiento = ['audio', 'video', 'iluminacion'];
  String? tipoMobiliarioSeleccionado;
  String? tipoEquipamientoSeleccionado;

  List<Map<String, dynamic>> mobiliario = [];
  List<Map<String, dynamic>> equipamiento = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      mobiliario = [
        {
          "nombre": "Silla",
          "descripcion": "Silla de oficina cómoda",
          "cantidad": 0,
          "tipo": "oficina",
          "precio": 50,
        },
        {
          "nombre": "Mesa",
          "descripcion": "Mesa de trabajo rectangular",
          "cantidad": 0,
          "tipo": "oficina",
          "precio": 150,
        },
        {
          "nombre": "Silla Tiffany",
          "descripcion": "Silla elegante para eventos",
          "cantidad": 0,
          "tipo": "eventos",
          "precio": 80,
        },
        {
          "nombre": "Mesa Redonda",
          "descripcion": "Mesa para banquetes",
          "cantidad": 0,
          "tipo": "eventos",
          "precio": 200,
        },
        {
          "nombre": "Mesa Infantil",
          "descripcion": "Mesa pequeña para niños",
          "cantidad": 0,
          "tipo": "infantil",
          "precio": 100,
        },
        {
          "nombre": "Silla Plastica",
          "descripcion": "Silla resistente para niños",
          "cantidad": 0,
          "tipo": "infantil",
          "precio": 30,
        },
      ];

      equipamiento = [
        {
          "nombre": "Proyector",
          "descripcion": "Proyector HD de alta definición",
          "cantidad": 0,
          "tipo": "video",
          "precio": 500,
        },
        {
          "nombre": "Pantalla",
          "descripcion": "Pantalla de proyección 100\"",
          "cantidad": 0,
          "tipo": "video",
          "precio": 300,
        },
        {
          "nombre": "Bocina",
          "descripcion": "Bocina amplificadora de sonido",
          "cantidad": 0,
          "tipo": "audio",
          "precio": 400,
        },
        {
          "nombre": "Micrófono",
          "descripcion": "Micrófono inalámbrico",
          "cantidad": 0,
          "tipo": "audio",
          "precio": 200,
        },
        {
          "nombre": "Foco LED",
          "descripcion": "Iluminación LEDRGB",
          "cantidad": 0,
          "tipo": "iluminacion",
          "precio": 150,
        },
        {
          "nombre": "Luz Estroboscópica",
          "descripcion": "Luz estroboscópica para eventos",
          "cantidad": 0,
          "tipo": "iluminacion",
          "precio": 250,
        },
      ];
    });
  }

  List<Map<String, dynamic>> get mobiliarioFiltrado {
    if (tipoMobiliarioSeleccionado == null ||
        tipoMobiliarioSeleccionado == 'todos') {
      return mobiliario;
    }
    return mobiliario
        .where((m) => m['tipo'] == tipoMobiliarioSeleccionado)
        .toList();
  }

  List<Map<String, dynamic>> get equipamientoFiltrado {
    if (tipoEquipamientoSeleccionado == null ||
        tipoEquipamientoSeleccionado == 'todos') {
      return equipamiento;
    }
    return equipamiento
        .where((e) => e['tipo'] == tipoEquipamientoSeleccionado)
        .toList();
  }

  void actualizarCantidad(
    List<Map<String, dynamic>> lista,
    int index,
    int nuevaCantidad,
  ) {
    if (nuevaCantidad < 0) return;

    setState(() {
      lista[index]["cantidad"] = nuevaCantidad;
    });
  }

  int getCantidad(List<Map<String, dynamic>> lista, int index) {
    return lista[index]["cantidad"];
  }

  List<Map<String, dynamic>> getSeleccionados() {
    return [
      ...mobiliario.where((e) => e["cantidad"] > 0),
      ...equipamiento.where((e) => e["cantidad"] > 0),
    ];
  }

  void mostrarResumen() {
    final seleccionados = getSeleccionados();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (seleccionados.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No hay solicitudes seleccionadas")),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Resumen de solicitud",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...seleccionados.map(
                (e) => ListTile(
                  title: Text(e["nombre"]),
                  subtitle: Text(e["descripcion"]),
                  trailing: Text("x${e["cantidad"]}"),
                ),
              ),
              const Divider(),
              Text(
                "Total de items: ${seleccionados.fold<int>(0, (sum, e) => sum + (e["cantidad"] as int))}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColores.primary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Confirmar"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          ButtonsTabBar(
            backgroundColor: AppColores.primary,
            unselectedBackgroundColor: Colors.white,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            radius: 50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: "Mobiliario"),
              Tab(text: "Equipamiento"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildMobiliarioLista(), _buildEquipamientoLista()],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: mostrarResumen,
                child: const Text("Solicitar", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobiliarioLista() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        value: tipoMobiliarioSeleccionado,
                        hint: Text("Todos"),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'todos',
                            child: Text("Todos"),
                          ),
                          ...tiposMobiliario.map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          ),
                        ],
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            tipoMobiliarioSeleccionado = nuevoValor;
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
                "Catálogo de mobiliario:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: mobiliarioFiltrado.length,
              itemBuilder: (context, index) {
                final item = mobiliarioFiltrado[index];
                final cantidad = getCantidad(
                  mobiliario,
                  mobiliario.indexOf(item),
                );

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nombre"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColores.foreground,
                                ),
                              ),
                              Text(
                                item["descripcion"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColores.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item["tipo"],
                                      style: TextStyle(
                                        color: AppColores.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '\$${item["precio"]}',
                                    style: TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                              onPressed: cantidad > 0
                                  ? () => actualizarCantidad(
                                      mobiliario,
                                      mobiliario.indexOf(item),
                                      cantidad - 1,
                                    )
                                  : null,
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: cantidad > 0
                                    ? AppColores.primary
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              "$cantidad",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => actualizarCantidad(
                                mobiliario,
                                mobiliario.indexOf(item),
                                cantidad + 1,
                              ),
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppColores.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEquipamientoLista() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        value: tipoEquipamientoSeleccionado,
                        hint: Text("Todos"),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'todos',
                            child: Text("Todos"),
                          ),
                          ...tiposEquipamiento.map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          ),
                        ],
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            tipoEquipamientoSeleccionado = nuevoValor;
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
              itemCount: equipamientoFiltrado.length,
              itemBuilder: (context, index) {
                final item = equipamientoFiltrado[index];
                final cantidad = getCantidad(
                  equipamiento,
                  equipamiento.indexOf(item),
                );

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nombre"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColores.foreground,
                                ),
                              ),
                              Text(
                                item["descripcion"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColores.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item["tipo"],
                                      style: TextStyle(
                                        color: AppColores.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '\$${item["precio"]}',
                                    style: TextStyle(
                                      color: AppColores.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                              onPressed: cantidad > 0
                                  ? () => actualizarCantidad(
                                      equipamiento,
                                      equipamiento.indexOf(item),
                                      cantidad - 1,
                                    )
                                  : null,
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: cantidad > 0
                                    ? AppColores.primary
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              "$cantidad",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => actualizarCantidad(
                                equipamiento,
                                equipamiento.indexOf(item),
                                cantidad + 1,
                              ),
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppColores.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
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
