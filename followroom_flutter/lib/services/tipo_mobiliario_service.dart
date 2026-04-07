import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class TipoMobiliarioService {

  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getTiposMobiliarios() async {

    try{
      var dio = Dio();

      dio.options.baseUrl = baseUrl;

      final response = await dio.get(
        '/tipo-mobiliario/'
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        return data.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['id'] = int.parse(map['id'].toString());
          return map;
        }).toList();
      } else {
        throw Exception("Error al cargar los tipos de mobiliarios");
      }

    }
    catch (e) {
      print("error al cargar los tipos de mobiliarios: $e");
      throw Exception("Error al cargar tipos de mobiliarios");
    }

  }

}