import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class PaqueteService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getPaquetes() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/paquetes/');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar paquetes');
      }
    } catch (e) {
      print('Error al cargar paquetes: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaquete(int id) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/paquete/$id/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Paquete no encontrado');
      }
    } catch (e) {
      print('Error al cargar paquete: $e');
      rethrow;
    }
  }
}
