import 'dart:convert';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;

class ServicioService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<dynamic>> getServicios() async {
    final response = await http.get(Uri.parse('$baseUrl/servicio/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar servicios');
    }
  }

  Future<List<dynamic>> getServiciosPorTipo(int tipoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicio/?tipo_servicio=$tipoId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar servicios por tipo');
    }
  }
}
