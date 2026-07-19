import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cita.dart';
import '../theme/app_colors.dart';
import '../theme/estado_cita_colors.dart';

/// Tarjeta de una cita: franja de estado a la izquierda, nombre, motivo y hora.
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
                      Text(cita.pacienteNombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(cita.motivo, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(hora,
                          style: const TextStyle(
                              color: AppColors.neutral400, fontSize: 12)),
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
