import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';

class InventarioService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getInventarioMobiliario({
    int? tipoId,
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      String endpoint = '/inventario-mob/';
      if (tipoId != null) {
        endpoint += '?mobiliario__tipo_movil=$tipoId';
      }

      final response = await dio.get(endpoint);
      print(
        'Response inventario-mob: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200) {
        var data = response.data;
        // DRF viewsets may wrap results in 'results' key
        if (data is Map && data.containsKey('results')) {
          data = data['results'];
        }
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        return [];
      } else {
        throw Exception('Error al cargar inventario de mobiliarios');
      }
    } catch (e) {
      print('Error al cargar inventario mobiliarios: $e');
      throw Exception('Error al cargar inventario de mobiliarios');
    }
  }

  Future<List<Map<String, dynamic>>> getInventarioEquipamiento({
    int? tipoId,
  }) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      String endpoint = '/inventarioequipa/';
      if (tipoId != null) {
        endpoint += '?equipamiento__tipo_equipa=$tipoId';
      }

      final response = await dio.get(endpoint);
      print(
        'Response inventarioequipa: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map && data.containsKey('results')) {
          data = data['results'];
        }
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        return [];
      } else {
        throw Exception('Error al cargar inventario de equipamiento');
      }
    } catch (e) {
      print('Error al cargar inventario equipamiento: $e');
      throw Exception('Error al cargar inventario de equipamiento');
    }
  }

  //getEstadosMobil() // No existe endpoint en API
  //getEstadosEquipa() // No existe endpoint en API

  Future<bool> updateInventarioMob(
    int id,
    int cantidad,
    String estadoCodigo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final response = await dio.patch(
        '/inventario-mob/$id/',
        data: {'cantidad': cantidad, 'estado_mobil': estadoCodigo},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar mobiliario: $e');
      return false;
    }
  }

  Future<bool> updateInventarioEquipa(
    int id,
    int cantidad,
    String estadoCodigo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;

      final response = await dio.patch(
        '/inventarioequipa/$id/',
        data: {'cantidad': cantidad, 'estado_equipa': estadoCodigo},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar equipamiento: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTiposMobil() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-mobil/');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de mobiliario');
      }
    } catch (e) {
      print('Error al cargar tipos mobiliario: $e');
      throw Exception('Error al cargar tipos de mobiliario');
    }
  }

  Future<List<Map<String, dynamic>>> getTiposEquipa() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-equipamiento/');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de equipamiento');
      }
    } catch (e) {
      print('Error al cargar tipos equipamiento: $e');
      throw Exception('Error al cargar tipos de equipamiento');
    }
  }
}
