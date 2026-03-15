import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TipoServicioService {
  static const String baseUrl = 'http://192.168.100.8/api';

  Future<List<dynamic>> getTiposServicio() async {
    final response = await http.get(Uri.parse('$baseUrl/tipo-servicio/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar tipos de servicio');
    }
  }
}
