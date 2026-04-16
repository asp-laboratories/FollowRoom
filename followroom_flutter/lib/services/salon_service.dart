import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class SalonService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getSalonesConEstado() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/salon/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar salones');
      }
    } catch (e) {
      print('Error al cargar salones: $e');
      throw Exception('Error al cargar salones');
    }
  }

  Future<Map<String, dynamic>> actualizarEstado(
    int salonId,
    String estadoCodigo,
    String? fecha,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      Map<String, dynamic> data = {'estado_salon': estadoCodigo};
      if (fecha != null) {
        data['fecha'] = fecha;
      }

      final response = await dio.patch('/salon/$salonId/', data: data);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error al actualizar estado: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSalonesDisponibles(String fecha) async {
    try {
      String fechaFormateada = fecha;
      if (fecha.contains('/')) {
        final partes = fecha.split('/');
        if (partes.length == 3) {
          String dia = partes[0].padLeft(2, '0');
          String mes = partes[1].padLeft(2, '0');
          String anio = partes[2];
          fechaFormateada = '$anio-$mes-$dia';
        }
      }
      
      print('SalonService: GET /disponibilidad-salones/ con fecha=$fechaFormateada');
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      
      final response = await dio.get(
        '/disponibilidad-salones/',
        queryParameters: {'fecha': fechaFormateada},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('SalonService: Recibidos ${data.length} salones para la fecha $fechaFormateada');
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar disponibilidad de salones: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar disponibilidad: $e');
      throw Exception('Error al cargar disponibilidad de salones');
    }
  }
}
