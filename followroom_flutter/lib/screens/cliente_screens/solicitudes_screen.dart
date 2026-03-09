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

  Future<void> cargarDatos() async {}

  void incrementar(List lista, int index) {
    setState(() {
      lista[index]["cantidad"]++;
    });
  }

  void disminuir(List lista, int index) {
    setState(() {
      if (lista[index]["cantidad"] > 0) {
        lista[index]["cantidad"]--;
      }
    });
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
            tabs: const [
              Tab(text: "Mobiliario"),
              Tab(text: "Equipamiento"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildLista(mobiliario), _buildLista(equipamiento)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text(
          "No hay elementos disponibles",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColores.backgroundComponent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lista[index]["nombre"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColores.foreground,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Cantidad"),
                    const SizedBox(width: 15),
                    _cantidadButton(
                      icon: Icons.remove,
                      onPressed: () => disminuir(lista, index),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      lista[index]["cantidad"].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _cantidadButton(
                      icon: Icons.add,
                      onPressed: () => incrementar(lista, index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cantidadButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: AppColores.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
