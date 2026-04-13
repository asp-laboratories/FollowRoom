import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class MontajeService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getMontajes() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/montaje/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar montajes');
      }
    } catch (e) {
      print('Error al cargar montajes: $e');
      throw Exception('Error al cargar montajes');
    }
  }

  Future<List<Map<String, dynamic>>> getMontajesPorSalon(int salonId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-montaje/?salon=$salonId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar montajes');
      }
    } catch (e) {
      print('Error al cargar montajes: $e');
      throw Exception('Error al cargar montajes');
    }
  }

  Future<List<Map<String, dynamic>>> getTipoMontaje() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-montaje/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de montaje');
      }
    } catch (e) {
      print('Error al cargar tipos de montaje: $e');
      throw Exception('Error al cargar tipos de montaje');
    }
  }
}
