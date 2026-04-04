import 'dart:convert';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;

class EquipamientoService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<dynamic>> getEquipamientos() async {
    final response = await http.get(Uri.parse('$baseUrl/equipamiento/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar equipamientos');
    }
  }

  Future<List<dynamic>> getEquipamientosPorTipo(int tipoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/equipamiento/?tipo_equipa=$tipoId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar equipamientos por tipo');
    }
  }
}
