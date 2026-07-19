import 'package:flutter/foundation.dart';

import '../models/doctor.dart';
import 'mock_medicos.dart';

/// Posibles resultados de un intento de inicio de sesión.
enum ResultadoLogin {
  exito,
  camposVacios,
  credencialesInvalidas,
  cuentaInactiva,
}

/// Estado de sesión (simulado). Guarda en memoria el médico autenticado.
/// Se reinicia al reiniciar la app, igual que el resto de la simulación.
class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  Doctor? _medicoActual;
  Doctor? get medicoActual => _medicoActual;
  bool get haySesion => _medicoActual != null;

  /// Valida las credenciales contra los médicos mock (la "BD").
  ResultadoLogin iniciarSesion(String email, String password) {
    final correo = email.trim().toLowerCase();
    if (correo.isEmpty || password.isEmpty) {
      return ResultadoLogin.camposVacios;
    }

    CuentaMedico? cuenta;
    for (final c in medicosMock) {
      if (c.doctor.email.toLowerCase() == correo && c.password == password) {
        cuenta = c;
        break;
      }
    }

    if (cuenta == null) return ResultadoLogin.credencialesInvalidas;
    if (!cuenta.doctor.activo) return ResultadoLogin.cuentaInactiva;

    _medicoActual = cuenta.doctor;
    notifyListeners();
    return ResultadoLogin.exito;
  }

  void cerrarSesion() {
    _medicoActual = null;
    notifyListeners();
  }
}

/// Instancia compartida.
final authStore = AuthStore.instance;
