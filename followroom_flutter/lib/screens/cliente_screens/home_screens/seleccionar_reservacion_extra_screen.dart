import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:followroom_flutter/services/reservacion_service.dart';
// import 'package:followroom_flutter/screens/cliente_screens/home_screens/solicitudes_screen.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';

class SeleccionarReservacionExtraScreen extends StatefulWidget {
  final Function(int, Map<String, dynamic>)? onReservacionSeleccionada;

  const SeleccionarReservacionExtraScreen({
    super.key,
    this.onReservacionSeleccionada,
  });

  @override
  State<SeleccionarReservacionExtraScreen> createState() =>
      _SeleccionarReservacionExtraScreenState();
}

class _SeleccionarReservacionExtraScreenState
    extends State<SeleccionarReservacionExtraScreen> {
  final ReservacionService _reservacionService = ReservacionService();
  List<Map<String, dynamic>> _reservaciones = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarReservaciones();
  }

  Future<void> _cargarReservaciones() async {
    try {
      final email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        setState(() {
          _error = 'No hay sesión activa';
          _cargando = false;
        });
        return;
      }

      final reservaciones = await _reservacionService.getMisReservaciones(
        email,
      );

      final reservacionesActivas = reservaciones.where((r) {
        final estado = r['estado_codigo']?.toString().toUpperCase();
        return estado == 'SOLIC' ||
            estado == 'PEN' ||
            estado == 'CONF' ||
            estado == 'CON' ||
            estado == 'PROC' ||
            estado == 'ENPRO';
      }).toList();

      final enproReservaciones = reservacionesActivas
          .where((r) => r['estado_codigo']?.toString().toUpperCase() == 'ENPRO')
          .toList();
      final otrasReservaciones = reservacionesActivas
          .where((r) => r['estado_codigo']?.toString().toUpperCase() != 'ENPRO')
          .toList();
      final reservacionesOrdenadas = [
        ...enproReservaciones,
        ...otrasReservaciones,
      ];

      setState(() {
        _reservaciones = reservacionesOrdenadas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  String _getEstadoTexto(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'SOLIC':
        return 'Solicitado';
      case 'PEN':
        return 'Pendiente';
      case 'CONF':
      case 'CON':
        return 'Confirmado';
      case 'PROC':
        return 'En Proceso';
      case 'ENPRO':
        return 'En Proceso';
      default:
        return estado ?? 'Desconocido';
    }
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'SOLIC':
        return Colors.orange;
      case 'PEN':
        return Colors.blue;
      case 'CONF':
      case 'CON':
        return Colors.green;
      case 'PROC':
        return Colors.purple;
      case 'ENPRO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Selecciona una reservación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarReservaciones,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _reservaciones.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tienes reservaciones activas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservaciones.length,
                    itemBuilder: (context, index) {
                      final reservacion = _reservaciones[index];
                      final estado = reservacion['estado_codigo']?.toString();
                      final salonNombre =
                          reservacion['salon_nombre'] ?? 'Sin salón';
                      final fecha = reservacion['fecha'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: ContainerStyles.sombreado,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              final info = {
                                'id': reservacion['id'],
                                'nombre': reservacion['nombre'],
                                'fecha': fecha != null
                                    ? fecha.toString().substring(0, 10)
                                    : 'Sin fecha',
                                'salon': salonNombre,
                                'estado': _getEstadoTexto(estado),
                              };
                              if (widget.onReservacionSeleccionada != null) {
                                widget.onReservacionSeleccionada!(
                                  reservacion['id'],
                                  info,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reservacion['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getEstadoColor(
                                            estado,
                                          ).withAlpha(51),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          _getEstadoTexto(estado),
                                          style: TextStyle(
                                            color: _getEstadoColor(estado),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fecha?.toString().split('T')[0] ??
                                            'Sin fecha',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.room,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          salonNombre,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
