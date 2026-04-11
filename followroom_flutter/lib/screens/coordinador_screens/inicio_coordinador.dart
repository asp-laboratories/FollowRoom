import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/screens/coordinador_screens/detalles_reservacion_coordinador.dart';
import 'package:followroom_flutter/screens/coordinador_screens/subnavbar_coordinador.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class InicioCoordinador extends StatefulWidget {
  const InicioCoordinador({super.key});

  @override
  State<InicioCoordinador> createState() => _InicioCoordinadorState();
}

class _InicioCoordinadorState extends State<InicioCoordinador> {
  final ReservacionService _reservacionService = ReservacionService();

  int _actualIndice = 0;
  bool _cargando = true;
  List<Map<String, dynamic>> _reservaciones = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarReservaciones();
  }

  Future<void> _cargarReservaciones() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final datos = await _reservacionService.getTodasReservaciones();

      setState(() {
        _reservaciones = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _error = 'Error al cargar reservaciones: $e';
      });
    }
  }

  List<Map<String, dynamic>> get _reservacionesFiltradas {
    if (_reservaciones.isEmpty) return [];

    String estadoCodigo;
    if (_actualIndice == 0) {
      estadoCodigo = 'PROC';
    } else if (_actualIndice == 1) {
      estadoCodigo = 'CON';
    } else {
      estadoCodigo = 'TERMI';
    }

    return _reservaciones.where((r) {
      final codigo = r['estado_codigo']?.toString() ?? '';
      return codigo == estadoCodigo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarReservaciones,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final reservacionesMostrar = _reservacionesFiltradas;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Textos(
                texts: const ['Por Hacer', 'En Marcha', 'Concluidos'],
                seleccionActual: _actualIndice,
                alSeleccionar: (int nuevoIndice) {
                  setState(() {
                    _actualIndice = nuevoIndice;
                  });
                },
              ),
            ),
            const SizedBox(width: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reservacionesMostrar.length,
              itemBuilder: (context, index) {
                final itemActual = reservacionesMostrar[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: ContainerStyles.sombreado,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaDetallesCoordinador(
                              idReservacion: itemActual['id'].toString(),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Titulo: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  itemActual['nombreEvento'] ?? 'Sin título',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColores.foreground,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Fecha: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual['fechaEvento'] ?? 'Sin fecha',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.alarm,
                                  color: AppColores.foreground,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Hora: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual['horaInicio'] ?? 'Sin hora',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Salon: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual['salon_nombre'] ?? 'Sin salón',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Montaje: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  itemActual['montaje_tipo'] ?? 'Sin montaje',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColores.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Equipamientos: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                (itemActual['equipamentos'] as List?)
                                            ?.isNotEmpty ==
                                        true
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      )
                                    : const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                const SizedBox(width: 16),
                                Text(
                                  "Servicios: ",
                                  style: TextEstilos.labelCard.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                (itemActual['servicios'] as List?)
                                            ?.isNotEmpty ==
                                        true
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      )
                                    : const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Click para ver detalles del evento",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColores.foreground.withValues(
                                  alpha: 0.9,
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
