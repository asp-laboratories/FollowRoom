// === SERVICIO PARA SUBIR IMAGEN DE PERFIL A FIREBASE STORAGE ===
// (comentado para revisión)
//
// PASOS PARA ACTIVAR:
// 1. Agregar dependencias en pubspec.yaml:
//    firebase_storage: latest
//    image_picker: latest
//
// 2. Ejecutar migraciones en Django:
//    python manage.py makemigrations
//    python manage.py migrate
//
// 3. Descomentar el código debajo

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:followroom_flutter/services/ip_config.dart';
// import 'package:followroom_flutter/services/session_data.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagenPerfilService {
//   static const String baseUrl = 'http://${IpConfig.ip}/api';
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   Future<String?> _subirAFirebaseStorage(File imagen, String uid) async {
//     try {
//       String nombreArchivo = 'perfil_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       Reference ref = _storage.ref().child('perfiles').child(nombreArchivo);
//       await ref.putFile(imagen, SettableMetadata(contentType: 'image/jpeg'));
//       String url = await ref.getDownloadURL();
//       return url;
//     } catch (e) {
//       print('Error al subir imagen a Firebase: $e');
//       return null;
//     }
//   }

//   Future<String?> seleccionarYSubirImagen(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 500,
//         maxHeight: 500,
//         imageQuality: 80,
//       );

//       if (pickedFile == null) return null;

//       final File imagen = File(pickedFile.path);
//       final String? uid = SessionData.cuentaId?.toString();

//       if (uid == null) {
//         throw Exception('No hay sesión');
//       }

//       final String? url = await _subirAFirebaseStorage(imagen, uid);
//       return url;
//     } catch (e) {
//       print('Error al seleccionar/subir imagen: $e');
//       return null;
//     }
//   }

//   Future<bool> guardarImagenPerfil(String imagenUrl) async {
//     final email = SessionData.email;
//     if (email == null) return false;

//     try {
//       var dio = Dio();
//       dio.options.baseUrl = baseUrl;
//       final response = await dio.post(
//         '/perfil/',
//         data: {
//           'email': email,
//           'imagen_url': imagenUrl,
//         },
//       );
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error al guardar imagen en Django: $e');
//       return false;
//     }
//   }
// }

// === RESUMEN DEL FLUJO ===
// 1. Usuario selecciona imagen (cámara/galería) con ImagePicker
// 2. Se sube a Firebase Storage: firebase_storage
// 3. Se obtiene URL pública con getDownloadURL()
// 4. Se envía URL a Django vía POST
// 5. Django guarda en campo imagen_url del modelo Cuenta
// 6. Flutter muestra con Image.network(elemento.imagen_url)
