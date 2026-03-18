import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:followroom_flutter/core/colores.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
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
        {"nombre": "Silla", "cantidad": 2},
        {"nombre": "Mesa", "cantidad": 1},
      ];

      equipamiento = [
        {"nombre": "Proyector", "cantidad": 1},
        {"nombre": "Bocina", "cantidad": 0},
      ];
    });
  }

  void actualizarCantidad(
      List<Map<String, dynamic>> lista, int index, int nuevaCantidad) {
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...seleccionados.map((e) => ListTile(
                    title: Text(e["nombre"]),
                    trailing: Text("x${e["cantidad"]}"),
                  )),
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
              children: [
                _buildLista(mobiliario),
                _buildLista(equipamiento),
              ],
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
                child: const Text(
                  "Solicitar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text("No hay elementos disponibles"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        final cantidad = getCantidad(lista, index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColores.backgroundComponent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cantidad > 0
                  ? AppColores.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item["nombre"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColores.foreground,
                    ),
                  ),
                ),

                Row(

                  children: [
                    IconButton(
                      onPressed: cantidad > 0
                          ? () => actualizarCantidad(
                                lista,
                                index,
                                cantidad - 1,
                              )
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text("$cantidad"),
                    IconButton(
                      onPressed: () => actualizarCantidad(
                        lista,
                        index,
                        cantidad + 1,
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
