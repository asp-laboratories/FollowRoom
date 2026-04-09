import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class MobiliarioService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getMobiliarios() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/mobiliario/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar mobiliarios');
      }
    } catch (e) {
      print('Error al cargar mobiliarios: $e');
      throw Exception('Error al cargar mobiliarios');
    }
  }

  Future<List<Map<String, dynamic>>> getMobiliariosPorTipo(int tipoId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/mobiliario/?tipo_movil=$tipoId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar mobiliarios');
      }
    } catch (e) {
      print('Error al cargar mobiliarios: $e');
      throw Exception('Error al cargar mobiliarios');
    }
  }

  Future<List<Map<String, dynamic>>> getTiposMobil() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-mobil/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de mobiliario');
      }
    } catch (e) {
      print('Error al cargar tipos de mobiliario: $e');
      throw Exception('Error al cargar tipos de mobiliario');
    }
  }
}
