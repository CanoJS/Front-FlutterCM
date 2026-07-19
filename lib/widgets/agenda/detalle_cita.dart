import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/citas_store.dart';
import '../../models/cita.dart';
import '../../theme/app_colors.dart';
import '../../utils/fechas.dart';
import '../tarjeta_cita.dart';

/// Hoja de detalle de una cita: muestra la info como tarjeta y permite marcarla
/// como atendida agregando la nota médica.
class DetalleCita extends StatefulWidget {
  final Cita cita;
  const DetalleCita({super.key, required this.cita});

  @override
  State<DetalleCita> createState() => _DetalleCitaState();
}

class _DetalleCitaState extends State<DetalleCita> {
  final _notaCtrl = TextEditingController();
  bool _agregandoNota = false;

  @override
  void dispose() {
    _notaCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    citasStore.marcarAtendida(widget.cita, _notaCtrl.text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita marcada como atendida')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    final fecha =
        cap(DateFormat("EEEE d 'de' MMMM 'de' y", 'es_MX').format(cita.inicia));
    final atendida = cita.estado == EstadoCita.atendida;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La información se muestra como una tarjeta de cita.
          TarjetaCita(cita: cita, onTap: () {}),
          const SizedBox(height: 8),
          Text(fecha,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 13)),
          const SizedBox(height: 16),

          if (atendida) ...[
            const Text('Nota médica',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral400)),
            const SizedBox(height: 6),
            Text(cita.notaMedica ?? 'Sin nota registrada',
                style: const TextStyle(fontSize: 16, height: 1.4)),
          ] else if (!_agregandoNota) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => setState(() => _agregandoNota = true),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como Atendida'),
              ),
            ),
          ] else ...[
            const Text('Nota médica',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral400)),
            const SizedBox(height: 8),
            TextField(
              controller: _notaCtrl,
              autofocus: true,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Nota médica de la consulta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: _notaCtrl.text.trim().isEmpty ? null : _guardar,
                  child: const Text('Guardar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _agregandoNota = false;
                    _notaCtrl.clear();
                  }),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
