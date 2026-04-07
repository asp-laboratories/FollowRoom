import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class SalonService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getSalonesConEstado() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/salon/');
          if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) {
        final map = Map<String, dynamic>.from(item);
        map['id'] = int.parse(map['id'].toString());
        return map;
      }).toList();
      } else {
        throw Exception('Error al cargar salones');
      }
    } catch (e) {
      print('Error al cargar salones: $e');
      throw Exception('Error al cargar salones');
    }
  }

  Future<Map<String, dynamic>> actualizarEstado(
    int salonId,
    String estadoCodigo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.patch(
        '/salon/$salonId/',
        data: {'estado_salon': estadoCodigo},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error al actualizar estado: $e');
      rethrow;
    }
  }
}
