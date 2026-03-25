import 'package:dio/dio.dart';

class CuentaService {
  static const String baseUrl = 'http://192.168.100.8:8000/api';

  Future<Map<String, dynamic>> getCuenta(String nombre) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = baseUrl;
      final response = await dio.get(
        '/cuenta/',
        queryParameters: {'nombre': nombre},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al cargar cuenta');
      }
    } catch (e) {
      print('Error al cargar cuenta: $e');
      throw Exception('Error al cargar cuenta');
    }
  }
}

// [
//     {
//         "id": 1,
//         "nombre_usuario": "admin",
//         "correo_electronico": "admin@test.com",
//         "disposicion": true,
//         "firebase_uid": "test_uid_123",
//         "estado_cuenta": "ACT"
//     },
//     {
//         "id": 2,
//         "nombre_usuario": "",
//         "correo_electronico": "0324108121@uttijuana.edu.mx",
//         "disposicion": true,
//         "firebase_uid": "c1PMf5J3Mahg6joCunPDJKJu6zf2",
//         "estado_cuenta": "ACT"
//     },
//     {
//         "id": 3,
//         "nombre_usuario": "luise",
//         "correo_electronico": "luisdagallardo@gmail.com",
//         "disposicion": true,
//         "firebase_uid": "7A2duPu23vQuxZMLc0xxp2ZS9VX2",
//         "estado_cuenta": "ACT"
//     }
// ]
