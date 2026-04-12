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

  Future<Map<String, dynamic>> getReservacionProxima(String? rfcCliente) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/reservacion-proxima/$rfcCliente/');
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

  Future<List<Map<String, dynamic>>> getPaquetes() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/lista-paquetes/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception("Error al cargar los paquetes");
      }
    } catch (e) {
      print("Error al cargar paquetes: $e");
      throw Exception('Error al cargar los paquetes');
    }
  }

  Future<List<Map<String, dynamic>>> getReservacionesCliente(
    String rfc,
    String estado,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final respuesta = await dio.get(
        '/reservaciones-cliente/$rfc/',
        queryParameters: {'estado': estado},
      );
      if (respuesta.statusCode == 200) {
        List<dynamic> datos = respuesta.data;
        return datos.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception("Error al cargar las reservaciones.");
      }
    } catch (e) {
      print("Error al cargar las reservaciones del cliente $rfc: $e");
      throw Exception('Error al cargar las reservaciones');
    }
  }

  Future<Response> modificarReservacion(int idReservacion, Map<String, dynamic> datosActualizar) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.patch('/reservacion/$idReservacion/', data: datosActualizar);
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
          "Error al modificar la reservacion: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Problema con django: ${e.response?.data}");
        throw Exception("Error en el servidor: ${e.response?.data}");
      } else {
        print("Problkema de conexio: ${e.message}");
        throw Exception("Error en la conexion con el servidor");
      }
    } catch (e) {
      print("Error al crear reservacion: ($e)");
      throw Exception('Error al crear reservacion');
    }
  }

  Future<Response> crearReservacion(
    Map<String, dynamic> reservacionInfo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post('/reservacion/', data: reservacionInfo);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
          "Error al registrar la reservacion: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Problema con django: ${e.response?.data}");
        throw Exception("Error en el servidor: ${e.response?.data}");
      } else {
        print("Problkema de conexio: ${e.message}");
        throw Exception("Error en la conexion con el servidor");
      }
    } catch (e) {
      print("Error al crear reservacion: ($e)");
      throw Exception('Error al crear reservacion');
    }
  }
}
