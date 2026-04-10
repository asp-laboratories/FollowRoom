import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class TipoEventoService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getTipoEventos() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-evento/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de evento');
      }
    } catch (e) {
      print('Error al cargar tipos de evento: $e');
      throw Exception('Error al cargar tipos de evento');
    }
  }
}
