import 'dart:io';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:followroom_flutter/features/auth/screens/login_screen.dart';
import 'package:followroom_flutter/services/perfil_service.dart';
import 'package:followroom_flutter/services/session_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final PerfilService _perfilService = PerfilService();
  File? _imageFile;
  bool _cargando = true;

  String _tipoUsuario = '';
  String _nombreCompleto = '[Sin nombre]';
  String _noEmpleado = '';
  String _rfc = '[Sin RFC]';
  String _telefono = '[Sin teléfono]';
  String _nombreFiscal = '[Sin nombre fiscal]';
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    _cargarImagenLocal();
  }

  Future<void> _cargarImagenLocal() async {
    try {
      final email = SessionData.email;
      debugPrint('SessionData.email: $email');
      if (email == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = 'imagen_perfil_${email.hashCode}';
      debugPrint('Buscando imagen con key: $key');
      final savedPath = prefs.getString(key);
      debugPrint('savedPath: $savedPath');
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          debugPrint('Imagen encontrada: ${file.path}');
          setState(() {
            _imageFile = file;
          });
        } else {
          debugPrint('El archivo no existe');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar imagen local: $e');
    }
  }

  Future<void> _guardarImagenLocal(File image) async {
    try {
      final email = SessionData.email;
      if (email == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = 'imagen_perfil_${email.hashCode}';
      await prefs.setString(key, image.path);
    } catch (e) {
      debugPrint('Error al guardar imagen local: $e');
    }
  }

  Future<void> _cargarPerfil() async {
    try {
      final data = await _perfilService.getPerfil();
      setState(() {
        _tipoUsuario = data['tipo_usuario'] ?? '';

        if (_tipoUsuario == 'trabajador') {
          _nombreCompleto =
              '${data['nombre'] ?? ''} ${data['apellidoPaterno'] ?? ''}'.trim();
          if (_nombreCompleto.isEmpty) _nombreCompleto = '[Sin nombre]';

          _noEmpleado = data['no_empleado'] ?? '';
          _rfc = data['rfc'] ?? '[Sin RFC]';
          _telefono = data['telefono'] ?? '[Sin teléfono]';
          _nombreFiscal = '';
        } else {
          _nombreCompleto =
              '${data['nombre'] ?? ''} ${data['apellidoPaterno'] ?? ''} ${data['apellidoMaterno'] ?? ''}'
                  .trim();
          if (_nombreCompleto.isEmpty) _nombreCompleto = '[Sin nombre]';

          _noEmpleado = '';
          _rfc = data['rfc'] ?? '[Sin RFC]';
          _telefono = data['telefono'] ?? '[Sin teléfono]';
          _nombreFiscal = data['nombre_fiscal'] ?? '[Sin nombre fiscal]';
        }

        _nombreController.text = data['nombre_usuario'] ?? '';
        _correoController.text = data['correo_electronico'] ?? '';
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _actualizarPerfil() async {
    if (_actualizando) return;

    setState(() {
      _actualizando = true;
    });

    try {
      final success = await _perfilService.actualizarPerfil(
        nombreUsuario: _nombreController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Perfil actualizado' : 'Error al actualizar',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  Future<void> _enviarCorreoCambioContrasena() async {
    final email = SessionData.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el correo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo enviado a $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColores.primary),
                  title: const Text("Tomar foto"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColores.primary),
                  title: const Text("Elegir de galería"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // === GUARDAR IMAGEN LOCALMENTE (actual) ===
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savedPath = path.join(appDir.path, fileName);

        final File savedImage = await File(pickedFile.path).copy(savedPath);

        setState(() {
          _imageFile = savedImage;
        });

        // Guardar ruta de imagen en preferences
        await _guardarImagenLocal(savedImage);
        //       );
        //     }
        //   }
        // }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColores.foreground),
      prefixIcon: Icon(icon, color: AppColores.primary, size: 22),
      filled: true,
      fillColor: AppColores.backgroundComponent,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColores.primary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColores.primary.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColores.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColores.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColores.background2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    // === MOSTRAR IMAGEN DE PERFIL (comentado para revisión) ===
                                    // child: _imagenUrl != null
                                    //     ? Image.network(_imagenUrl!, fit: BoxFit.cover)
                                    //     : (_imageFile != null
                                    //         ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    //         : Icon(Icons.person, size: 50, color: Colors.white))
                                    child: _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColores.background2,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: AppColores.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _cargando
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nombre completo: ",
                                      style: TextEstilos.simpleTexto,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _nombreCompleto,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_tipoUsuario == 'trabajador') ...[
                                      Text(
                                        "Numero de trabajador: ",
                                        style: TextEstilos.simpleTexto,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _noEmpleado,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ] else ...[
                                      Text(
                                        "Nombre fiscal: ",
                                        style: TextEstilos.simpleTexto,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _nombreFiscal,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text("RFC", style: TextEstilos.simpleTexto),
                                    const SizedBox(height: 4),
                                    Text(
                                      _rfc,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Telefono",
                                      style: TextEstilos.simpleTexto,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _telefono,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColores.backgroundComponent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Editar Perfil", style: TextEstilos.subtitulos),
                    const SizedBox(height: 20),
                    Text(
                      "Nombre de usuario",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColores.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nombreController,
                      decoration: _inputDecoration("", Icons.person),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Correo electrónico",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColores.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _correoController,
                      readOnly: true,
                      decoration: _inputDecoration("", Icons.email),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Contraseña",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColores.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _enviarCorreoCambioContrasena,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColores.primary,
                          side: BorderSide(color: AppColores.primary),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.lock_reset),
                        label: const Text(
                          "Enviar correo para cambiar contraseña",
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _actualizando
                            ? null
                            : () async {
                                setState(() => _actualizando = true);
                                try {
                                  final success = await _perfilService
                                      .actualizarPerfil(
                                        nombreUsuario: _nombreController.text
                                            .trim(),
                                      );
                                  if (mounted) {
                                    if (success) {
                                      AnimatedSnackBar(
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Perfil actualizado con éxito',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).show(context);
                                    } else {
                                      AnimatedSnackBar(
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Error al actualizar perfil',
                                                  style: TextStyle(
                                                    color: Colors.red.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).show(context);
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AnimatedSnackBar(
                                      builder: (context) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Error: ${e.toString()}',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).show(context);
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _actualizando = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Actualizar perfil",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
