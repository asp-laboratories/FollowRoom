import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class TipoMontajeService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

    Future<List<Map<String, dynamic>>> getMontajesPorSalon(int salon_id) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
          '/tipo-montaje/',
          queryParameters: {'salon': salon_id}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['id'] = int.parse(map['id'].toString());
          return map;
        }).toList();
      } else {
        throw Exception('Error al cargar tipos de montajes');
      }
    } catch (e) {
      print('Error al cargar tipos de montajes: $e');
      throw Exception('Error al cargar tipos de montajes');
    }
  }

}
