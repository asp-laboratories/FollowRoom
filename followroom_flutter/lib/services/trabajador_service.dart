import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>> fetchTrabajador() async {
  var dio = Dio();
  dio.options.baseUrl = 'http://192.168.100.10:8000/api';
  try {
    final response = await dio.get('/trabajador/');
    print(response.data); // Dio ya entrega el JSON parseado (Map/List)
    return response.data;
  } catch (e) {
    print('Error al cargar trabajadores: $e');
    rethrow;
  }
}

// services/auth_service.dart

class TrabajadorService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    // 1. Firebase verifica email y contraseña
    final credencialesUsuario = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Firebase devuelve el JWT
    final idToken = await credencialesUsuario.user!.getIdToken();

    // 3. Flutter manda el JWT a Django
    final response = await _dio.post(
      'http://192.168.100.10:8000/api/trabajador/',
      data: {'token': idToken},
    );

    // 4. Django responde con el tipo y rol del usuario
    return response.data;
    // {'tipo': 'trabajador', 'rol': 'recepcionista', 'nombre': 'Carlos'}
  }
}

// [
//     {
//         "no_empleado": "12345",
//         "rol_nombre": "Administrador",
//         "rol_codigo": "ADMIN",
//         "cuenta_nombre": "luise",
//         "rfc": "ABC1234567890",
//         "nombre_fiscal": "LUIS PE",
//         "nombre": "LUIS",
//         "apellidoPaterno": "GA",
//         "apelidoMaterno": "RA",
//         "telefono": "6632081698",
//         "correo_electronico": "luisdagallardo@gmail.com",
//         "rol": "ADMIN",
//         "cuenta": 3
//     }
// ]


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class TrabajadoresService {
//   static const String baseUrl = 'http://192.168.100.10/api';

//   Future<List<dynamic>> getTrabajadores() async {
//     final response = await http.get(Uri.parse('$baseUrl/trabajadores/'));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Error al cargar trabajadores');
//     }
//   }
// }

// // Ejemplo básico http
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// Future<void> fetchData() async {
//   final response = await http.get(Uri.parse('https://example.com'));
//   if (response.statusCode == 200) {
//     print(jsonDecode(response.body)); // Necesita decodificar
//   }
// }
// // Ejemplo básico Dio
// import 'package:dio/dio.dart';

// Future<void> fetchData() async {
//   var dio = Dio();
//   // Configuración global opcional
//   dio.options.baseUrl = 'https://example.com';
  
//   final response = await dio.get('/data');
//   print(response.data); // Dio ya entrega el JSON parseado (Map/List)
// }
