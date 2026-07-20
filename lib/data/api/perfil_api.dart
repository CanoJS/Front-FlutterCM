import '../../models/doctor.dart';
import 'api_client.dart';

/// Identidad del usuario autenticado (GET /api/v1/users/me).
class UsuarioActual {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool active;

  const UsuarioActual({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.active,
  });

  String get nombreCompleto => '$firstName $lastName'.trim();

  factory UsuarioActual.fromJson(Map<String, dynamic> json) {
    String t(String k) => (json[k] as String?) ?? '';
    return UsuarioActual(
      id: t('id'),
      firstName: t('firstName'),
      lastName: t('lastName'),
      email: t('email'),
      role: t('role'),
      active: (json['active'] as bool?) ?? true,
    );
  }
}

/// Llamadas relacionadas con el perfil del médico.
class PerfilApi {
  PerfilApi._();
  static final PerfilApi instance = PerfilApi._();

  /// GET /api/v1/users/me — identidad del usuario en sesión.
  Future<UsuarioActual> obtenerUsuarioActual() async {
    final data = await apiClient.getJson('/api/v1/users/me');
    return UsuarioActual.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/v1/doctors — médicos activos (incluye especialidad).
  Future<List<Doctor>> obtenerDoctores() async {
    final data = await apiClient.getJson('/api/v1/doctors');
    final lista = (data as List).cast<Map<String, dynamic>>();
    return lista.map(Doctor.fromJson).toList();
  }
}

/// Instancia compartida.
final perfilApi = PerfilApi.instance;
