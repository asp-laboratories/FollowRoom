import 'package:flutter/material.dart';
import 'package:followroom_flutter/components/widget_seccion_busqueda.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/core/estados_widgets.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';
import 'package:followroom_flutter/screens/coordinador_screens/detalles_reservacion_coordinador.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';

class InicioCoordinador extends StatefulWidget {
  const InicioCoordinador({super.key});

  @override
  State<InicioCoordinador> createState() => _InicioCoordinadorState();
}

class _InicioCoordinadorState extends State<InicioCoordinador> {
  final ReservacionService _reservacionService = ReservacionService();

  int _actualIndice = 0;

  DateTime? _fechaSeleccionada;
  String _textoBusqueda = '';

  bool _cargando = true;
  List<Map<String, dynamic>> _reservaciones = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final resultados = await Future.wait([
        _reservacionService.getTodasReservaciones(),
      ]);

      if (!mounted) return;
      setState(() {
        _reservaciones = resultados[0];
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'Error al cargar reservaciones';
      });
    }
  }

  void _onFechaChanged(DateTime? fecha) {
    setState(() => _fechaSeleccionada = fecha);
  }

  void _onSalonChanged(String? salon) {
    print("ola");
  }

  void _onBusquedaChanged(String texto) {
    setState(() => _textoBusqueda = texto);
  }

  List<Map<String, dynamic>> get _reservacionesFiltradas {
    if (_reservaciones.isEmpty) return [];

    final estadoCodigo = switch (_actualIndice) {
      0 => 'CON',
      1 => 'ENPRO',
      _ => 'FIN',
    };

    return _reservaciones.where((r) {
      final codigo = r['estado_codigo']?.toString() ?? '';
      if (codigo != estadoCodigo) return false;

      if (_textoBusqueda.isNotEmpty) {
        final nombnre = r['nombreEvento']?.toString().toLowerCase() ?? '';
        if (!nombnre.contains(_textoBusqueda.toLowerCase())) return false;
        return true;
      }

      if (_fechaSeleccionada != null) {
        final fechaRaw = r['fechaEvento'];
        if (fechaRaw != null) {
          final fecha = DateTime.tryParse(fechaRaw.toString());
          if (fecha != null) {
            final coincideFecha =
                fecha.year == _fechaSeleccionada!.year &&
                fecha.month == _fechaSeleccionada!.month &&
                fecha.day == _fechaSeleccionada!.day;
            if (!coincideFecha) return false;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const LoadingWidget(mensaje: 'Cargando reservaciones...');
    }

    if (_error != null) {
      return ErrorDisplay.conexion(mensaje: _error!, onRetry: _cargarDatos);
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
                  setState(() => _actualIndice = nuevoIndice);
                },
              ),
            ),

            _actualIndice != 1
                ? FiltroReservacionesWidget(
                    salones: [],
                    onFechaChanged: _onFechaChanged,
                    onSalonChanged: _onSalonChanged,
                    onBusquedaChanged: _onBusquedaChanged,
                    seccionSalones: false,
                  )
                : SizedBox(),

            const SizedBox(height: 8),

            reservacionesMostrar.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_available,
                          size: 56,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay reservaciones',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'para los filtros seleccionados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: reservacionesMostrar.length,
                    itemBuilder: (context, index) {
                      final itemActual = reservacionesMostrar[index];
                      return _buildCardReservacion(itemActual);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardReservacion(Map<String, dynamic> item) {
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
                  idReservacion: item['id'].toString(),
                ),
              ),
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
                      "Titulo: ",
                      style: TextEstilos.labelCard.copyWith(fontSize: 14),
                    ),
                    Text(
                      item['nombreEvento'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 14,
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
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Text(
                      item['fechaEvento'] ?? 'Sin fecha',
                      style: const TextStyle(
                        fontSize: 12,
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
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Text(
                      item['horaInicio'] ?? 'Sin hora',
                      style: const TextStyle(
                        fontSize: 12,
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
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Text(
                      item['salon_nombre'] ?? 'Sin salón',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColores.foreground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Montaje: ",
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Text(
                      item['montaje_tipo'] ?? 'Sin montaje',
                      style: const TextStyle(
                        fontSize: 12,
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
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Icon(
                      (item['equipamentos'] as List?)?.isNotEmpty == true
                          ? Icons.check
                          : Icons.close,
                      color: (item['equipamentos'] as List?)?.isNotEmpty == true
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Servicios: ",
                      style: TextEstilos.labelCard.copyWith(fontSize: 12),
                    ),
                    Icon(
                      (item['servicios'] as List?)?.isNotEmpty == true
                          ? Icons.check
                          : Icons.close,
                      color: (item['servicios'] as List?)?.isNotEmpty == true
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  "Click para ver detalles del evento",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColores.foreground.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
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
