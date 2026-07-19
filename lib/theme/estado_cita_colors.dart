import 'package:flutter/material.dart';

import '../models/cita.dart';
import 'app_colors.dart';

/// Colores (fondo, borde) para pintar tarjetas y badges según el estado de la
/// cita. Uso: `cita.estado.colores`.
extension EstadoCitaColores on EstadoCita {
  (Color fondo, Color borde) get colores {
    switch (this) {
      case EstadoCita.atendida:
        return (AppColors.atendidaFondo, AppColors.atendidaBorde);
      case EstadoCita.cancelada:
        return (AppColors.canceladaFondo, AppColors.canceladaBorde);
      case EstadoCita.programada:
        return (AppColors.pendienteFondo, AppColors.pendienteBorde);
    }
  }
}
