import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class SolicitudesExtraService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getSolicitudesExtra() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/solicitudes-extra/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['reservaciones'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar solicitudes extra');
      }
    } catch (e) {
      print('Error al cargar solicitudes extra: $e');
      throw Exception('Error al cargar solicitudes extra');
    }
  }

  Future<List<Map<String, dynamic>>> getMisSolicitudesExtra(
    String email,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/mis-solicitudes-extra/',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['solicitudes'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar mis solicitudes extra');
      }
    } catch (e) {
      print('Error al cargar mis solicitudes extra: $e');
      throw Exception('Error al cargar mis solicitudes extra');
    }
  }

  Future<bool> completarItems({
    required int reservacionId,
    List<Map<String, dynamic>> mobiliarios = const [],
    List<Map<String, dynamic>> equipamentos = const [],
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final data = {
        'mobiliarios': mobiliarios
            .map((m) => {'id': m['id'], 'completado': m['completado'] ?? true})
            .toList(),
        'equipamentos': equipamentos
            .map((e) => {'id': e['id'], 'completado': e['completado'] ?? true})
            .toList(),
      };

      print('Enviando completados para reservación $reservacionId: $data');
      final response = await dio.patch(
        '/solicitudes-extra/$reservacionId/completar/',
        data: data,
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      print('Error al completar items: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> aceptarSolicitud({
    required int reservacionId,
    List<int> mobiliariosIds = const [],
    List<int> equipamentosIds = const [],
    List<int> serviciosIds = const [],
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final data = {
        'mobiliarios_ids': mobiliariosIds,
        'equipamentos_ids': equipamentosIds,
        'servicios_ids': serviciosIds,
      };

      print('Aceptando solicitud $reservacionId: $data');
      final response = await dio.post(
        '/solicitudes-extra/$reservacionId/aceptar/',
        data: data,
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      print('Error al aceptar solicitud: $e');
      return null;
    }
  }
}
