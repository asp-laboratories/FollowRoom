import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.100.10:8000/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await userCredential.user!.getIdToken();
      print('Token Firebase: ${idToken!.substring(0, 20)}...');

      final dio = Dio();
      dio.options.baseUrl = baseUrl;
      dio.options.connectTimeout = Duration(seconds: 10);

      print('Enviando request a: $baseUrl/flutter-login/');

      final response = await dio.post(
        '/flutter-login/',
        data: {'token': idToken},
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['user'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['error'] ?? 'Error en el servidor');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_obtenerMensajeError(e.code));
    } on DioException catch (e) {
      print('Error de Dio: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('Data del error: ${e.response?.data}');
        throw Exception(e.response?.data['error'] ?? 'Error en el servidor Django');
      }
      throw Exception('Error de conexión con el servidor (Django)');
    } catch (e) {
      print('Error inesperado: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _obtenerMensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error al iniciar sesión';
    }
  }
}
