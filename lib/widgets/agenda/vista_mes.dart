import 'package:flutter/material.dart';

import '../../data/citas_store.dart';
import '../../models/cita.dart';
import '../../theme/app_colors.dart';
import '../../utils/fechas.dart';
import 'hoja_dia.dart';

/// Calendario mensual. Marca los días con citas pendientes y su conteo; al tocar
/// un día abre la [HojaDia] con sus citas.
class VistaMes extends StatelessWidget {
  final DateTime mes; // primer día del mes visible
  final void Function(Cita) onTap;
  const VistaMes({super.key, required this.mes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diasEnMes = DateTime(mes.year, mes.month + 1, 0).day;
    final offset = DateTime(mes.year, mes.month, 1).weekday - 1; // lunes = 0
    final filas = ((offset + diasEnMes + 6) ~/ 7);

    // Conteo de citas pendientes por día dentro del mes visible.
    final conteo = <int, int>{};
    for (final c in citasStore.agenda) {
      if (c.estado == EstadoCita.programada &&
          c.inicia.year == mes.year &&
          c.inicia.month == mes.month) {
        conteo[c.inicia.day] = (conteo[c.inicia.day] ?? 0) + 1;
      }
    }

    final hoy = DateTime.now();
    const encabezados = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: Column(
        children: [
          Row(
            children: [
              for (final d in encabezados)
                Expanded(
                  child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral400)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (int fila = 0; fila < filas; fila++)
            Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(
                    child: _celda(
                        context, fila * 7 + col, offset, diasEnMes, conteo, hoy),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _celda(BuildContext context, int indice, int offset, int diasEnMes,
      Map<int, int> conteo, DateTime hoy) {
    final numDia = indice - offset + 1;
    final enMes = numDia >= 1 && numDia <= diasEnMes;

    // Días de otros meses: solo el número en gris (Dart normaliza el desborde).
    if (!enMes) {
      final fecha = DateTime(mes.year, mes.month, numDia);
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('${fecha.day}',
              style: const TextStyle(fontSize: 15, color: AppColors.neutral200)),
        ),
      );
    }

    final cantidad = conteo[numDia] ?? 0;
    final tieneCitas = cantidad > 0;
    final esHoy =
        hoy.year == mes.year && hoy.month == mes.month && hoy.day == numDia;

    final celda = Container(
      height: 60,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: esHoy
            ? AppColors.primary600
            : (tieneCitas ? AppColors.accent50 : null),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$numDia',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: esHoy ? Colors.white : AppColors.neutral900)),
            if (tieneCitas) ...[
              const SizedBox(height: 5),
              _badge(cantidad, esHoy),
            ],
          ],
        ),
      ),
    );

    if (!tieneCitas) return celda;
    return GestureDetector(
      onTap: () => _abrirDia(context, DateTime(mes.year, mes.month, numDia)),
      child: celda,
    );
  }

  Widget _badge(int cantidad, bool esHoy) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: esHoy ? Colors.white : AppColors.accent400,
      ),
      child: Text('$cantidad',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: esHoy ? AppColors.primary600 : Colors.white)),
    );
  }

  void _abrirDia(BuildContext context, DateTime dia) {
    final citas = citasStore.agenda
        .where((c) => mismoDia(c.inicia, dia))
        .toList()
      ..sort((a, b) => a.inicia.compareTo(b.inicia));
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => HojaDia(dia: dia, citas: citas, onTap: onTap),
    );
  }
}
