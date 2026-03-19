import 'dart:io';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/texto_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

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
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savedPath = path.join(appDir.path, fileName);

        final File savedImage = await File(pickedFile.path).copy(savedPath);

        setState(() {
          _imageFile = savedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColores.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
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
                                child: _imageFile != null
                                    ? Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nombre completo: ",
                            style: TextEstilos.simpleTexto,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "[Sin nombre]",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Numero de trabajador: ",
                            style: TextEstilos.simpleTexto,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "[Sin número de trabajador]",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("RFC", style: TextEstilos.simpleTexto),
                          const SizedBox(height: 4),
                          Text(
                            "[Sin RFC]",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Telefono", style: TextEstilos.simpleTexto),
                          const SizedBox(height: 4),
                          Text(
                            "[Sin teléfono]",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
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

          const SizedBox(height: 24),

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
                    decoration: _inputDecoration(
                      "Nombre completo",
                      Icons.person,
                    ),
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
                    decoration: _inputDecoration("Correo", Icons.email),
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
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColores.primary,
                      side: BorderSide(color: AppColores.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Enviar correo para cambiar contraseña"),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
