import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:followroom_flutter/services/session_data.dart';

class PerfilService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<Map<String, dynamic>> getPerfil() async {
    final email = SessionData.email;

    if (email == null) {
      throw Exception('No hay sesión guardada');
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/perfil/',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar perfil');
      }
    } catch (e) {
      print('Error al cargar perfil: $e');
      throw Exception('Error al cargar perfil');
    }
  }

  Future<bool> actualizarPerfil({required String nombreUsuario}) async {
    final email = SessionData.email;

    if (email == null) {
      throw Exception('No hay sesión guardada');
    }

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final response = await dio.put(
        '/perfil/',
        data: {'correo_electronico': email, 'nombre_usuario': nombreUsuario},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al actualizar perfil: $e');
      rethrow;
    }
  }
}
