import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class ReservacionService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getListaReservaciones() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservaciones-coordinador/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar reservaciones');
      }
    } catch (e) {
      print('Error al cargar reservaciones: $e');
      throw Exception('Error al cargar reservaciones');
    }
  }

  Future<List<Map<String, dynamic>>> getTodasReservaciones() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservaciones-coordinador/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar reservaciones');
      }
    } catch (e) {
      print('Error al cargar reservaciones: $e');
      throw Exception('Error al cargar reservaciones');
    }
  }

  Future<Map<String, dynamic>> getDetalleReservacion(int id) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservacion/$id/');
      print('DEBUG Service: Response status: ${response.statusCode}');
      print('DEBUG Service: Full response data keys: ${response.data.keys}');
      print(
        'DEBUG Service: checklist_almacenista: ${response.data['checklist_almacenista']}',
      );
      print(
        'DEBUG Service: checklist_coordinador: ${response.data['checklist_coordinador']}',
      );
      print(
        'DEBUG Service: progreso_checklist: ${response.data['progreso_checklist']}',
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar reservación');
      }
    } catch (e) {
      print('Error al cargar reservación: $e');
      throw Exception('Error al cargar reservación');
    }
  }

  Future<Response> crearReservacion_2(
    Map<String, dynamic> reservacionInfo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post('/reservacion/', data: reservacionInfo);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
          "Error al registrar la reservacion: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Problema con django: ${e.response?.data}");
        throw Exception("Error en el servidor: ${e.response?.data}");
      } else {
        print("Problkema de conexio: ${e.message}");
        throw Exception("Error en la conexion con el servidor");
      }
    } catch (e) {
      print("Error al crear reservacion: ($e)");
      throw Exception('Error al crear reservacion');
    }
  }

  Future<bool> crearReservacion({
    required Map<String, String> datosReservacion,
    required Map<String, String> datosCliente,
    required int salonId,
    required int? montageId,
    required List<Map<String, dynamic>> servicios,
    required List<Map<String, dynamic>> equipamentos,
    required List<Map<String, dynamic>> mobiliarios,
    bool confirmarInventario = true,
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      String fechaFormateada = datosReservacion['fecha'] ?? '';
      print('Fecha original: $fechaFormateada');

      // Try different formats
      if (fechaFormateada.contains('/')) {
        final partes = fechaFormateada.split('/');
        if (partes.length == 3) {
          // Try dd/mm/yyyy -> yyyy-mm-dd
          final day = int.tryParse(partes[0]) ?? 0;
          final month = int.tryParse(partes[1]) ?? 0;
          final year = int.tryParse(partes[2]) ?? 0;

          if (day > 0 && month > 0 && year > 0) {
            fechaFormateada =
                '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          }
        }
      } else if (fechaFormateada.contains('-')) {
        // Already has dashes, ensure proper format yyyy-mm-dd
        final partes = fechaFormateada.split('-');
        if (partes.length == 3) {
          // Check if it's dd-mm-yyyy and convert
          final part0 = int.tryParse(partes[0]) ?? 0;
          if (part0 > 31) {
            // Already yyyy-mm-dd
            fechaFormateada = fechaFormateada;
          } else {
            // Probably dd-mm-yyyy
            fechaFormateada = '${partes[2]}-${partes[1]}-${partes[0]}';
          }
        }
      }

      print('Fecha formateada: $fechaFormateada');

      // Format time to HH:mm, handles both "horaInicio - horaFin" and single time
      String parseTimeComponent(String timePart) {
        final match = RegExp(r'(\d+):(\d+)').firstMatch(timePart);
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          final minute = int.parse(match.group(2)!);
          if (timePart.contains('PM') && hour != 12) hour += 12;
          if (timePart.contains('AM') && hour == 12) hour = 0;
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
        return '12:00';
      }

      String formatTime(String? timeStr, {bool isEndTime = false}) {
        if (timeStr == null || timeStr.isEmpty) return '12:00';

        final cleanStr = timeStr.replaceAll(RegExp(r'\s+'), ' ').trim();

        if (cleanStr.contains(' - ')) {
          final parts = cleanStr.split(' - ');
          final timePart = isEndTime ? parts[1] : parts[0];
          return parseTimeComponent(timePart);
        }

        return parseTimeComponent(cleanStr);
      }

      final horaInicioStr = formatTime(datosReservacion['horario']);
      final horaFinStr = formatTime(
        datosReservacion['horario'],
        isEndTime: true,
      );

      final data = {
        'nombre': datosReservacion['nombre'] ?? '',
        'descripEvento': datosReservacion['descripcion'] ?? 'Sin descripción',
        'fechaEvento': fechaFormateada,
        'horaInicio': horaInicioStr,
        'horaFin': horaFinStr,
        'estimaAsistentes':
            int.tryParse(datosReservacion['asistentes'] ?? '0') ?? 0,
        'cliente': datosCliente['rfc'] ?? '',
        'trabajador': '', // Empty string instead of null
        'tipo_evento':
            int.tryParse(datosReservacion['tipoEventoId'] ?? '0') ?? 1,
        'estado_reserva': 'SOLIC', // Estado solicitud para app
        'montaje': {
          'salon': salonId,
          'tipo_montaje': montageId,
          'mobiliarios': mobiliarios
              .map((m) => {'id': m['id'], 'cantidad': m['cantidad'] ?? 1})
              .toList(),
        },
        'reserva_servicio': servicios
            .map((s) => {'servicio': s['id'], 'cantidad': 1})
            .toList(),
        'reserva_equipa': equipamentos
            .map(
              (e) => {'equipamiento': e['id'], 'cantidad': e['cantidad'] ?? 1},
            )
            .toList(),
      };

      data['confirmar_inventario'] = confirmarInventario;

      print('Data being sent: $data');
      final response = await dio.post('/reservacion/', data: data);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
        // Re-throw with detailed error info
        rethrow;
      }
      print('Error al crear reservación: $e');
      return false;
    }
  }

  Future<bool> agregarExtrasAReservacion({
    required int reservacionId,
    List<Map<String, dynamic>> mobiliarios = const [],
    List<Map<String, dynamic>> equipamentos = const [],
    List<Map<String, dynamic>> servicios = const [],
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final data = {
        if (mobiliarios.isNotEmpty)
          'mobiliarios': mobiliarios
              .map((m) => {'id': m['id'], 'cantidad': m['cantidad'] ?? 1})
              .toList(),
        if (equipamentos.isNotEmpty)
          'reserva_equipa': equipamentos
              .map((e) => {'id': e['id'], 'cantidad': e['cantidad'] ?? 1})
              .toList(),
        if (servicios.isNotEmpty)
          'reserva_servicio': servicios.map((s) => {'id': s['id']}).toList(),
      };

      print('Enviando extras a reservación $reservacionId: $data');
      final response = await dio.patch(
        '/reservacion/$reservacionId/',
        data: data,
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      print('Error al agregar extras: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMisReservaciones(String email) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/mis-reservaciones/',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['reservaciones'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar mis reservaciones');
      }
    } catch (e) {
      print('Error al cargar mis reservaciones: $e');
      throw Exception('Error al cargar mis reservaciones');
    }
  }

  Future<Map<String, dynamic>> updateChecklist(
    int reservacionId,
    String tipo,
    Map<String, bool> checklist,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post(
        '/reservacion/$reservacionId/checklist/',
        data: {'tipo': tipo, 'checklist': checklist},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al actualizar checklist');
      }
    } catch (e) {
      print('Error al actualizar checklist: $e');
      throw Exception('Error al actualizar checklist');
    }
  }

  Future<Map<String, dynamic>> getProgresoReservacion(int reservacionId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservacion/$reservacionId/progreso/');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al obtener progreso');
      }
    } catch (e) {
      print('Error al obtener progreso: $e');
      throw Exception('Error al obtener progreso');
    }
  }

  Future<Map<String, dynamic>> getChecklistAlmacenista(
    int reservacionId,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/reservacion/$reservacionId/checklist-almacenista/',
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al obtener checklist de almacenista');
      }
    } catch (e) {
      print('Error al obtener checklist de almacenista: $e');
      throw Exception('Error al obtener checklist de almacenista');
    }
  }

  Future<Map<String, dynamic>> getChecklistCoordinador(
    int reservacionId,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/reservacion/$reservacionId/checklist-coordinador/',
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al obtener checklist de coordinador');
      }
    } catch (e) {
      print('Error al obtener checklist de coordinador: $e');
      throw Exception('Error al obtener checklist de coordinador');
    }
  }

  Future<bool> cambiarEstado(int reservacionId, String estado) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post(
        '/reservacion/$reservacionId/cambiar-estado/',
        data: {'estado': estado},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al cambiar estado: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getEncuesta(int reservacionId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/encuesta/?reservacion=$reservacionId');
      if (response.statusCode == 200) {
        if (response.data is List && (response.data as List).isNotEmpty) {
          return Map<String, dynamic>.from((response.data as List).first);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener encuesta: $e');
      return null;
    }
  }
}
