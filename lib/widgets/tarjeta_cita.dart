import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cita.dart';
import '../theme/app_colors.dart';
import '../theme/estado_cita_colors.dart';

/// Tarjeta de una cita: franja de estado a la izquierda, hora + badge de estado
/// arriba, y nombre del paciente + motivo debajo.
class TarjetaCita extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;
  const TarjetaCita({super.key, required this.cita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('h:mm a', 'es_MX').format(cita.inicia);
    final (_, borde) = cita.estado.colores;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: borde),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(hora,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.neutral900)),
                          const Spacer(),
                          _BadgeEstado(estado: cita.estado),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(cita.pacienteNombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(cita.motivo,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.neutral400)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip con el estado de la cita (Pendiente / Atendida / Cancelada).
class _BadgeEstado extends StatelessWidget {
  final EstadoCita estado;
  const _BadgeEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (fondo, borde) = estado.colores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borde.withValues(alpha: 0.5)),
      ),
      child: Text(
        _etiquetaEstado(estado),
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: borde),
      ),
    );
  }
}

String _etiquetaEstado(EstadoCita estado) {
  switch (estado) {
    case EstadoCita.programada:
      return 'Pendiente';
    case EstadoCita.atendida:
      return 'Atendida';
    case EstadoCita.cancelada:
      return 'Cancelada';
  }
}
