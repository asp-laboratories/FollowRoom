import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class PublicReservacionService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getPublicReservaciones({String? fecha}) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      
      final Map<String, dynamic> queryParameters = {};
      if (fecha != null) {
        queryParameters['fecha'] = fecha;
      }

      final response = await dio.get(
        '/reservaciones-publicas/',
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar reservaciones públicas');
      }
    } catch (e) {
      print('Error al cargar reservaciones públicas: $e');
      throw Exception('Error al cargar reservaciones públicas');
    }
  }
}
