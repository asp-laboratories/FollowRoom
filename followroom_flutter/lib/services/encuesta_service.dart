import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class EncuestaService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<Map<String, dynamic>> verificarEncuestaExistente(int idReservacion) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/encuesta-realizada/$idReservacion/');
      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      } else {
        throw Exception('Error al cargar reservaciones');
      }
    } catch (e) {
      print('Error al verificar encuesta existente: $e');
      throw Exception(
        "Error al comprobar existencia de encuestas para la reservacion: $idReservacion",
      );
    }
  }

  Future<Response> enviarEncuesta(Map<String, dynamic> datos) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post('/encuesta/', data: datos);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
          "Error al registrar la encuesta: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Problema con django: ${e.response?.data}");
        throw Exception("Error en el servidor: ${e.response?.data}");
      } else {
        print("Problema de conexion: ${e.message}");
        throw Exception("Error en la conexion con el servidor");
      }
    } catch (e) {
      print("Error al crear reservacion: ($e)");
      throw Exception('Error al crear reservacion');
    }
  }
}
