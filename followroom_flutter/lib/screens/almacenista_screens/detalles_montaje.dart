import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class Detalles extends StatefulWidget {
  final String numeroReservacion;

  const Detalles({super.key, required this.numeroReservacion});

  @override
  State<Detalles> createState() => _DetallesState();
}

class _DetallesState extends State<Detalles> {
  List<Map<String, dynamic>> _mobiliarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMobiliarios();
  }

  Future<void> _cargarMobiliarios() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _mobiliarios = [
        {
          'nomre': "Mesa",
          'caracteristicas': ["rojo", 'madera'],
          'descripcion': "Mesa para banquetes",
          'tipoMobiliario': "Mesa",
          'completado': false,
          'icono': Icons.table_restaurant,
        },
        {
          'nomre': "Silla",
          'caracteristicas': ["azul", 'madera'],
          'descripcion': "Silla para banquetes",
          'tipoMobiliario': "silla",
          'completado': true,
          'icono': Icons.chair,
        },
        {
          'nomre': "Taburete",
          'caracteristicas': ["cafe", 'madera'],
          'descripcion': "Taburete para banquetes",
          'tipoMobiliario': "taburete",
          'completado': false,
          'icono': Icons.event_seat,
        },
        {
          'nomre': "Mesa Redonda",
          'caracteristicas': ["blanco", 'madera'],
          'descripcion': "Mesa para banquetes",
          'tipoMobiliario': "Mesa",
          'completado': true,
          'icono': Icons.table_restaurant,
        },
        {
          'nomre': "Podium",
          'caracteristicas': ["negro", "madera", "plegable", "regulable"],
          'descripcion': "Podium para presentaciones",
          'tipoMobiliario': "Podium",
          'completado': false,
          'icono': Icons.mic,
        },
      ];
      _isLoading = false;
    });
  }

  void _toggleCompletado(int index) {
    setState(() {
      _mobiliarios[index]['completado'] = !_mobiliarios[index]['completado'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final completados = _mobiliarios
        .where((m) => m['completado'] == true)
        .length;
    final total = _mobiliarios.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inventario Requerido",
          style: TextStyle(color: AppColores.foreground),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: AppColores.backgroundComponent,
        foregroundColor: AppColores.foreground,
      ),
      backgroundColor: AppColores.background2,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColores.primary),
            )
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(color: AppColores.background2),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColores.primary, AppColores.secundary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Resumen del Montaje",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$completados de $total elementos completados",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              total > 0
                                  ? "${((completados / total) * 100).round()}%"
                                  : "0%",
                              style: TextStyle(
                                color: AppColores.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Detalles del Inventario",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColores.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mobiliarios.length,
                      itemBuilder: (context, index) {
                        return _buildMobiliarioCard(index);
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ContainerStyles.sombreado,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.checklist, color: AppColores.primary),
                              const SizedBox(width: 8),
                              Text(
                                "Lista de Verificación",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_mobiliarios.length, (index) {
                            return _buildChecklistItem(index);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "$completados de $total elementos completados",
                              ),
                              backgroundColor: AppColores.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Guardar Estado"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMobiliarioCard(int index) {
    final mobiliario = _mobiliarios[index];
    final isCompleted = mobiliario['completado'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : AppColores.backgroundComponent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : AppColores.primary.withValues(alpha: 0.2),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleCompletado(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.2)
                        : AppColores.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mobiliario['icono'] ?? Icons.category,
                    color: isCompleted ? Colors.green : AppColores.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mobiliario['nomre']?.toString().toUpperCase() ??
                                  '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColores.foreground,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCompleted ? "Listo" : "Pendiente",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mobiliario['descripcion']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColores.foreground.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            mobiliario['tipoMobiliario']?.toString() ?? '',
                            Icons.category,
                          ),
                          ...((mobiliario['caracteristicas'] as List?)
                                      ?.take(4)
                                      .toList() ??
                                  [])
                              .map(
                                (c) => _buildChip(c.toString(), Icons.palette),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColores.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColores.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppColores.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index) {
    final mobiliario = _mobiliarios[index];
    final isCompleted = mobiliario['completado'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.05)
            : AppColores.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleCompletado(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mobiliario['nomre'] ?? '',
                        style: TextStyle(
                          color: AppColores.foreground,
                          fontSize: 16,
                          fontWeight: isCompleted
                              ? FontWeight.w500
                              : FontWeight.normal,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        mobiliario['tipoMobiliario']?.toString() ?? '',
                        style: TextStyle(
                          color: AppColores.foreground.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
