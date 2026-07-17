import 'package:flutter/foundation.dart';

import '../models/cita.dart';
import 'mock_citas.dart';

/// Estado en memoria de las citas.
///
/// Parte de los datos mock y vive solo mientras la app está abierta:
/// al reiniciar la aplicación se vuelve a sembrar desde los mocks, por eso
/// "marcar como atendida" es únicamente una simulación que no persiste.
class CitasStore extends ChangeNotifier {
  CitasStore._();
  static final CitasStore instance = CitasStore._();

  final List<Cita> agenda = List.of(agendaMock);
  final List<Cita> historial = List.of(historialMock);

  /// Marca una cita de la agenda como atendida, le agrega la nota médica y la
  /// coloca al inicio del historial (como la consulta más reciente).
  void marcarAtendida(Cita cita, String nota) {
    final texto = nota.trim();
    final atendida = cita.copyWith(
      estado: EstadoCita.atendida,
      notaMedica: texto.isEmpty ? null : texto,
    );

    final i = agenda.indexWhere((c) => c.id == cita.id);
    if (i != -1) agenda[i] = atendida;

    historial.removeWhere((c) => c.id == atendida.id);
    historial.insert(0, atendida);

    notifyListeners();
  }
}

/// Instancia compartida por las pantallas.
final citasStore = CitasStore.instance;
