import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  static int? _cuentaId;
  static String? _nombre;
  static String? _email;
  static String? _rol;
  static String? _tipo;

  static int? get cuentaId => _cuentaId;
  static String? get nombre => _nombre;
  static String? get email => _email;
  static String? get rol => _rol;
  static String? get tipo => _tipo;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cuentaId = prefs.getInt('cuenta_id');
    _nombre = prefs.getString('nombre');
    _email = prefs.getString('email');
    _rol = prefs.getString('rol');
    _tipo = prefs.getString('tipo');
  }

  static Future<void> setFromLogin(Map<String, dynamic> userData) async {
    _cuentaId = userData['cuenta_id'];
    _nombre = userData['nombre'];
    _email = userData['email'];
    _rol = userData['rol'];
    _tipo = userData['tipo'];

    final prefs = await SharedPreferences.getInstance();
    if (_cuentaId != null) await prefs.setInt('cuenta_id', _cuentaId!);
    if (_nombre != null) await prefs.setString('nombre', _nombre!);
    if (_email != null) await prefs.setString('email', _email!);
    if (_rol != null) await prefs.setString('rol', _rol!);
    if (_tipo != null) await prefs.setString('tipo', _tipo!);
  }

  static Future<void> clear() async {
    _cuentaId = null;
    _nombre = null;
    _email = null;
    _rol = null;
    _tipo = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cuenta_id');
    await prefs.remove('nombre');
    await prefs.remove('email');
    await prefs.remove('rol');
    await prefs.remove('tipo');
  }
}
