import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:followroom_flutter/services/session_data.dart';

class HistorialService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<Map<String, dynamic>?> getReservacionProxima() async {
    final email = SessionData.email;
    if (email == null) {
      return null;
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/reservacion-proxima/',
        queryParameters: {'email': email},
      );

      print('API reservacion-proxima response: ${response.data}');

      if (response.statusCode == 200 && response.data['reservacion'] != null) {
        return Map<String, dynamic>.from(response.data['reservacion']);
      }
      return null;
    } catch (e) {
      print('Error al cargar reservación próxima: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMisReservaciones() async {
    final email = SessionData.email;
    if (email == null) {
      return [];
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/mis-reservaciones/',
        queryParameters: {'email': email},
      );

      print('API mis-reservaciones response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['reservaciones'] ?? [];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error al cargar mis reservaciones: $e');
      return [];
    }
  }
}
