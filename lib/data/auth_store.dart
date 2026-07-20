import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/doctor.dart';
import '../models/especialidad.dart';

/// Posibles resultados de un intento de inicio de sesión.
enum ResultadoLogin {
  exito,
  camposVacios,
  credencialesInvalidas,
  cuentaInactiva,
  errorConexion,
}

/// Estado de sesión del médico.
///
/// La autenticación se hace contra **Supabase Auth**; el token resultante se
/// usará para llamar a la API de negocio. Se reinicia al reiniciar la app.
class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  SupabaseClient get _supabase => Supabase.instance.client;

  Doctor? _medicoActual;
  Doctor? get medicoActual => _medicoActual;

  bool get haySesion => _supabase.auth.currentSession != null;
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  /// Inicia sesión con correo y contraseña contra Supabase.
  Future<ResultadoLogin> iniciarSesion(String email, String password) async {
    final correo = email.trim();
    if (correo.isEmpty || password.isEmpty) {
      return ResultadoLogin.camposVacios;
    }

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: correo,
        password: password,
      );
      final user = res.user;
      if (user == null) return ResultadoLogin.credencialesInvalidas;

      // Perfil provisional a partir del usuario de Supabase.
      // Se reemplazará por GET /api/v1/users/me al conectar la API.
      _medicoActual = _doctorDesdeUsuario(user);
      notifyListeners();
      return ResultadoLogin.exito;
    } on AuthException {
      // Credenciales incorrectas, usuario no confirmado, etc.
      return ResultadoLogin.credencialesInvalidas;
    } catch (_) {
      // Sin conexión, error de servidor, etc.
      return ResultadoLogin.errorConexion;
    }
  }

  Future<void> cerrarSesion() async {
    await _supabase.auth.signOut();
    _medicoActual = null;
    notifyListeners();
  }

  Doctor _doctorDesdeUsuario(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final rawNombre = metadata['full_name'] ?? metadata['name'];
    final nombre = rawNombre is String && rawNombre.trim().isNotEmpty
        ? rawNombre
        : (user.email ?? 'Médico');

    return Doctor(
      id: user.id,
      nombreCompleto: nombre,
      email: user.email ?? '',
      especialidad: const Especialidad(id: '', nombre: '—'),
      activo: true,
    );
  }
}

/// Instancia compartida.
final authStore = AuthStore.instance;
