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

  Future<bool> createInventarioMob(
    int mobiliarioId,
    int cantidad,
    String estadoCodigo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post(
        '/inventario-mob/',
        data: {
          'mobiliario': mobiliarioId,
          'cantidad': cantidad,
          'estado_mobil': estadoCodigo,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error Django (Mob): ${e.response?.data}');
        throw Exception('Error servidor: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<bool> createInventarioEquipa(
    int equipamientoId,
    int cantidad,
    String estadoCodigo,
  ) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.post(
        '/inventarioequipa/',
        data: {
          'equipamiento': equipamientoId,
          'cantidad': cantidad,
          'estado_equipa': estadoCodigo,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error Django (Equipa): ${e.response?.data}');
        throw Exception('Error servidor: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTiposMobil() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-mobil/');

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
      final response = await dio.get('/tipo-equipa/');

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
        throw Exception('Error al cargar tipos de equipamiento');
      }
    } catch (e) {
      print('Error al cargar tipos equipamiento: $e');
      throw Exception('Error al cargar tipos de equipamiento');
    }
  }

  Future<Map<String, dynamic>> getEstadosInventario() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/estados-inventario/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar estados de inventario');
      }
    } catch (e) {
      print('Error estados inventario: $e');
      throw Exception('Error al cargar estados de inventario');
    }
  }

  Future<Map<String, dynamic>> getResumenEstadosEquipa(int inventarioId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/resumen-estados-equipa/$inventarioId/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar resumen de estados');
      }
    } catch (e) {
      print('Error resumen estados equip: $e');
      throw Exception('Error al cargar resumen de estados');
    }
  }

  Future<Map<String, dynamic>> getResumenEstadosMob(int inventarioId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/resumen-estados-mob/$inventarioId/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error al cargar resumen de estados');
      }
    } catch (e) {
      print('Error resumen estados mob: $e');
      throw Exception('Error al cargar resumen de estados');
    }
  }
}
