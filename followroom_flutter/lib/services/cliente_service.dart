import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:followroom_flutter/services/session_data.dart';

class ClienteService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<Map<String, dynamic>?> getDatosCliente() async {
    final email = SessionData.email;

    if (email == null) {
      return null;
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/datos-cliente/',
        queryParameters: {'correo': email},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          return Map<String, dynamic>.from(data.first);
        }
      }
      return null;
    } catch (e) {
      print('Error al cargar datos del cliente: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> guardarDatosCliente(
    Map<String, dynamic> datos,
  ) async {
    final email = SessionData.email;

    if (email == null) {
      throw Exception('No hay sesión');
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      datos['correo_electronico'] = email;

      final response = await dio.post('/perfil/', data: datos);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Error al guardar datos del cliente: $e');
      return null;
    }
  }
}
