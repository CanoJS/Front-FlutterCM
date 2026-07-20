import 'package:flutter/foundation.dart';

import '../../models/cita.dart';
import '../api/citas_api.dart';

/// Estado en memoria de las citas del médico, cargadas desde la API.
class CitasStore extends ChangeNotifier {
  CitasStore._();
  static final CitasStore instance = CitasStore._();

  List<Cita> _citas = [];
  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  /// Todas las citas (la agenda las filtra por semana/día).
  List<Cita> get agenda => _citas;

  /// Solo las atendidas, de la más reciente a la más antigua.
  List<Cita> get historial {
    final atendidas = _citas.where((c) => c.atendida).toList()
      ..sort((a, b) => b.inicia.compareTo(a.inicia));
    return atendidas;
  }

  /// Carga (o recarga) las citas desde la API.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _citas = await citasApi.obtenerCitas();
    } catch (_) {
      _error = 'No se pudieron cargar las citas.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Marca una cita como atendida en el backend (guardando la nota médica)
  /// y recarga las citas para reflejar el estado real del servidor.
  Future<void> marcarAtendida(Cita cita, String nota) async {
    await citasApi.atenderCita(
      id: cita.id,
      medicalNote: nota.trim(),
      version: cita.version,
    );
    await cargar();
  }
}

/// Instancia compartida por las pantallas.
final citasStore = CitasStore.instance;
