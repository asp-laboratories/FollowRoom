import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class DisponibilidadService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getDisponibilidadSalones(
    String fecha,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/disponibilidad-salones/',
        queryParameters: {'fecha': fecha},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar disponibilidad');
      }
    } catch (e) {
      print('Error al cargar disponibilidad: $e');
      throw Exception('Error al cargar disponibilidad');
    }
  }

  Future<List<Map<String, dynamic>>> getEstadosSalones(String fecha) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/estado-salon/',
        queryParameters: {'fecha': fecha},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar estados de salones');
      }
    } catch (e) {
      print('Error al cargar estados de salones: $e');
      throw Exception('Error al cargar estados de salones');
    }
  }
}
