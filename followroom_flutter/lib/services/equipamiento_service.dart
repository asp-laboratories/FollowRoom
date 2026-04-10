import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;

class EquipamientoService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<Map<String, dynamic>>> getEquipamientos() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/equipamiento/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar equipamientos');
      }
    } catch (e) {
      print('Error al cargar equipamientos: $e');
      throw Exception('Error al cargar equipamientos');
    }
  }

  Future<List<Map<String, dynamic>>> getEquipamientosPorTipo(int tipoId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/equipamiento/?tipo_equipa=$tipoId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar equipamientos por tipo');
      }
    } catch (e) {
      print('Error al cargar equipamientos por tipo: $e');
      throw Exception('Error al cargar equipamientos por tipo');
    }
  }

  Future<List<Map<String, dynamic>>> getServicios() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/servicio/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar servicios');
      }
    } catch (e) {
      print('Error al cargar servicios: $e');
      throw Exception('Error al cargar servicios');
    }
  }

  Future<List<Map<String, dynamic>>> getServiciosPorTipo(int tipoId) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/servicio/?tipo_servicio=$tipoId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar servicios por tipo');
      }
    } catch (e) {
      print('Error al cargar servicios por tipo: $e');
      throw Exception('Error al cargar servicios por tipo');
    }
  }

  Future<List<Map<String, dynamic>>> getTiposServicio() async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get('/tipo-servicio/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error al cargar tipos de servicio');
      }
    } catch (e) {
      print('Error al cargar tipos de servicio: $e');
      throw Exception('Error al cargar tipos de servicio');
    }
  }
}
