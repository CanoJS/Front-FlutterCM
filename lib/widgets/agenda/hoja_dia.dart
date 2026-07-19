import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cita.dart';
import '../../utils/fechas.dart';
import '../tarjeta_cita.dart';

/// Hoja inferior con las citas de un día (se abre desde el calendario del mes).
class HojaDia extends StatelessWidget {
  final DateTime dia;
  final List<Cita> citas;
  final void Function(Cita) onTap;
  const HojaDia(
      {super.key, required this.dia, required this.citas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final titulo = cap(DateFormat("EEEE d 'de' MMMM", 'es_MX').format(dia));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final c in citas) ...[
            TarjetaCita(
              cita: c,
              onTap: () {
                Navigator.of(context).pop();
                onTap(c);
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
