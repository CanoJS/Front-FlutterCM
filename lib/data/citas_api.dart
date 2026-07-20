import '../models/cita.dart';
import 'api_client.dart';

/// Llamadas a la API relacionadas con las citas (appointments).
class CitasApi {
  CitasApi._();
  static final CitasApi instance = CitasApi._();

  /// GET /api/v1/appointments — citas del usuario autenticado.
  /// La API las filtra por el médico según el token.
  Future<List<Cita>> obtenerCitas() async {
    final data = await apiClient.getJson('/api/v1/appointments');
    final lista = (data as List).cast<Map<String, dynamic>>();
    return lista.map(Cita.fromJson).toList();
  }

  /// PATCH /api/v1/appointments/{id}/attend — marca la cita como atendida
  /// y guarda la nota médica.
  Future<void> atenderCita({
    required String id,
    required String medicalNote,
    required String version,
  }) async {
    await apiClient.patchJson(
      '/api/v1/appointments/$id/attend',
      body: {'medicalNote': medicalNote, 'version': version},
    );
  }
}

/// Instancia compartida.
final citasApi = CitasApi.instance;
