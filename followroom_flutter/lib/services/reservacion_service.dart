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
}
