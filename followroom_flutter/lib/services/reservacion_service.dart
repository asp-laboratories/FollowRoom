import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class ReservacionService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getListaReservaciones() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservaciones-coordinador/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar reservaciones');
      }
    } catch (e) {
      print('Error al cargar reservaciones: $e');
      throw Exception('Error al cargar reservaciones');
    }
  }

  Future<Map<String, dynamic>> getDetalleReservacion(int id) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservacion/$id/');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar reservación');
      }
    } catch (e) {
      print('Error al cargar reservación: $e');
      throw Exception('Error al cargar reservación');
    }
  }

  Future<Response> crearReservacion(Map<String, dynamic> reservacionInfo) async {

    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post(
        '/reservacion/',
        data: reservacionInfo
      );
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception("Error al registrar la reservacion: ${response.statusCode}");
      }
    
    } on DioException catch (e) {
      if (e.response != null){
        print("Problema con django: ${e.response?.data}");
        throw Exception("Error en el servidor: ${e.response?.data}");
      } else {
        print("Problkema de conexio: ${e.message}");
        throw Exception("Error en la conexion con el servidor");
      }

    }
    catch(e) {
      print("Error al crear reservacion: ($e)");
      throw Exception('Error al crear reservacion');
    }

  }

}
