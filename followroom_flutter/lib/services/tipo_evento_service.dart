import 'dart:convert';
import 'package:followroom_flutter/services/ip_config.dart';
import 'package:http/http.dart' as http;

class TipoEventoService {
  static const String baseUrl = 'http://${IpConfig.ip}/api';

  Future<List<dynamic>> getTiposEventos() async {
    final response = await http.get(Uri.parse('$baseUrl/tipo-evento/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar tipos de eventos');
    }
  }
}
