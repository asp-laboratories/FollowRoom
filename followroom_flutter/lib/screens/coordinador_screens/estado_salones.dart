import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/services/salon_service.dart';

class PantallaEstadoSalones extends StatefulWidget {
  const PantallaEstadoSalones({super.key});

  @override
  State<PantallaEstadoSalones> createState() => _PantallaEstadoSalonesState();
}

class _PantallaEstadoSalonesState extends State<PantallaEstadoSalones> {
  int _estadoSeleccionado = 0;
  final SalonService _salonService = SalonService();
  List<Map<String, dynamic>> salones = [];
  bool _cargando = true;

  final List<String> estados = [
    "Todos",
    "Disponible",
    "Reservado",
    "En limpieza",
    "No disponible",
  ];

  @override
  void initState() {
    super.initState();
    _cargarSalones();
  }

  List<Map<String, dynamic>> salonesMostrados = [];

  Future<void> _cargarSalones() async {
    setState(() => _cargando = true);
    try {
      final data = await _salonService.getSalonesConEstado();
      setState(() {
        salones = data.map((item) {
          return {
            'id': item['id'],
            'nombre': item['nombre'],
            'estado': item['estado_nombre'],
            'estado_codigo': item['estado_codigo'],
          };
        }).toList();
        salonesMostrados = List.from(salones);
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void filtrarPorEstado(int index) {
    setState(() {
      _estadoSeleccionado = index;

      if (estados[index] == "Todos") {
        salonesMostrados = List.from(salones);
      } else {
        salonesMostrados = salones.where((salon) {
          return salon['estado'] == estados[index];
        }).toList();
      }
    });
  }

  Future<void> cambiarEstado(
    int index,
    String nuevoEstado,
    String nuevoCodigo,
  ) async {
    final salonId = salonesMostrados[index]['id'];
    try {
      await _salonService.actualizarEstado(salonId, nuevoCodigo);
      setState(() {
        salonesMostrados[index]['estado'] = nuevoEstado;
        final originalIndex = salones.indexWhere((s) => s['id'] == salonId);
        if (originalIndex != -1) {
          salones[originalIndex]['estado'] = nuevoEstado;
          salones[originalIndex]['estado_codigo'] = nuevoCodigo;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar estado')));
      }
    }
  }

  void abrirModalEstado(int index) async {
    final Map<String, String>? nuevoEstado =
        await showModalBottomSheet<Map<String, String>>(
          context: context,
          builder: (context) {
            return _ModalEstados();
          },
        );
    if (nuevoEstado != null) {
      cambiarEstado(index, nuevoEstado['nombre']!, nuevoEstado['codigo']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: estados.length,
                itemBuilder: (context, index) {
                  final seleccionado = index == _estadoSeleccionado;
                  return GestureDetector(
                    onTap: () => filtrarPorEstado(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColores.backgroundComponent,
                        border: Border.all(
                          color: seleccionado
                              ? AppColores.primary
                              : AppColores.primary.withValues(alpha: 0.3),
                          width: seleccionado ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: seleccionado
                                ? AppColores.primary.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        estados[index],
                        style: TextStyle(
                          color: seleccionado
                              ? AppColores.primary
                              : AppColores.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _cargando
                ? Center(
                    child: CircularProgressIndicator(color: AppColores.primary),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    itemCount: salonesMostrados.length,
                    itemBuilder: (context, index) {
                      final salon = salonesMostrados[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: ContainerStyles.sombreado,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => abrirModalEstado(index),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          salon['nombre'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColores.foreground,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _getEstadoIcon(salon['estado']),
                                            SizedBox(width: 5),
                                            Text(
                                              salon['estado'],
                                              style: TextStyle(
                                                color: _getEstadoColor(
                                                  salon['estado'],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColores.primary,
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

  Widget _getEstadoIcon(String estado) {
    Color color = _getEstadoColor(estado);
    IconData icon;

    switch (estado) {
      case 'Disponible':
        icon = Icons.check_circle;
        break;
      case 'Reservado':
        icon = Icons.event_busy;
        break;
      case 'En limpieza':
        icon = Icons.cleaning_services;
        break;
      default:
        icon = Icons.cancel;
    }
    return Icon(icon, size: 16, color: color);
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Disponible':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'En limpieza':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
}

class _ModalEstados extends StatefulWidget {
  @override
  State<_ModalEstados> createState() => _ModalEstadosState();
}

class _ModalEstadosState extends State<_ModalEstados> {
  final List<Map<String, String>> estados = [
    {"nombre": "Disponible", "codigo": "DISP"},
    {"nombre": "No disponible", "codigo": "NODISP"},
    {"nombre": "Reservado", "codigo": "RESV"},
    {"nombre": "En limpieza", "codigo": "LIM"},
  ];

  DateTime _fechaSeleccionada = DateTime.now();
  DateTime _primerDia = DateTime.now();
  DateTime _ultimoDia = DateTime.now().add(Duration(days: 365));

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: _primerDia,
      lastDate: _ultimoDia,
      helpText: "Selecciona la fecha",
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cambiar estado del salón",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "Fecha específica:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColores.foreground,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _seleccionarFecha(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColores.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatearFecha(_fechaSeleccionada),
                    style: TextStyle(fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Seleccionar estado:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColores.foreground,
            ),
          ),
          SizedBox(height: 8),
          ...estados.map((estado) {
            return ListTile(
              leading: Icon(Icons.circle),
              title: Text(estado['nombre']!),
              onTap: () {
                Navigator.pop(context, {
                  ...estado,
                  'fecha': _fechaSeleccionada.toIso8601String(),
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
