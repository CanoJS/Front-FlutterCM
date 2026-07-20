import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/citas_store.dart';
import '../../models/cita.dart';
import '../../theme/app_colors.dart';
import '../../theme/estado_cita_colors.dart';
import '../../utils/fechas.dart';

/// Rejilla de la semana (lunes a viernes, 08:00–17:30) con cada cita en su franja.
class RejillaSemana extends StatefulWidget {
  final DateTime lunes;
  final void Function(Cita) onTap;
  const RejillaSemana({super.key, required this.lunes, required this.onTap});

  @override
  State<RejillaSemana> createState() => _RejillaSemanaState();
}

class _RejillaSemanaState extends State<RejillaSemana> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Reconstruye cada 60 s para mover la línea roja de "ahora".
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dias = List.generate(5, (i) => widget.lunes.add(Duration(days: i)));
    // Las canceladas no ocupan espacio en la rejilla (se ve el hueco libre).
    final citasSemana = citasStore.agenda
        .where((c) =>
            c.estado != EstadoCita.cancelada && enSemana(c.inicia, widget.lunes))
        .toList();
    final mapa = _mapaCitas(citasSemana);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: _rejilla(dias, mapa),
    );
  }

  Widget _rejilla(List<DateTime> dias, Map<String, Cita> mapa) {
    const anchoHora = 44.0;
    const altoSlot = 44.0;
    final fmtDia = DateFormat('E', 'es_MX');
    final slots = _slots();

    final filas = slots.map((slot) {
      final (h, m) = slot;
      final etiqueta =
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      return SizedBox(
        height: altoSlot,
        child: Row(
          children: [
            SizedBox(
              width: anchoHora,
              child: Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.neutral900)),
            ),
            ...List.generate(5, (i) {
              final cita = mapa[_clave(dias[i].weekday, h, m)];
              return Expanded(child: _celda(cita));
            }),
          ],
        ),
      );
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: anchoHora),
            ...dias.map((d) => Expanded(
                  child: Column(
                    children: [
                      Text(cap(fmtDia.format(d)),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('${d.day}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.neutral900)),
                    ],
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final anchoDia = (constraints.maxWidth - anchoHora) / 5;
            return SizedBox(
              height: slots.length * altoSlot,
              child: Stack(
                children: [
                  Column(children: filas),
                  ..._lineaAhora(dias, anchoHora, anchoDia, altoSlot, slots.length),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Línea roja tipo Google/Microsoft Calendar que marca la hora actual.
  /// Solo aparece sobre la columna de hoy (lunes–viernes) si la semana visible
  /// contiene el día de hoy y la hora está dentro del horario (08:00–18:00).
  List<Widget> _lineaAhora(List<DateTime> dias, double anchoHora,
      double anchoDia, double altoSlot, int numSlots) {
    final ahora = DateTime.now();
    final indiceHoy = dias.indexWhere((d) => mismoDia(d, ahora));
    if (indiceHoy == -1) return const [];

    final minutos = (ahora.hour - 8) * 60 + ahora.minute;
    if (minutos < 0 || minutos >= numSlots * 30) return const [];

    const rojo = Color(0xFFE53935);
    final top = minutos * (altoSlot / 30);
    final left = anchoHora + indiceHoy * anchoDia;

    return [
      Positioned(
        top: top - 4, // centra el punto de 8px sobre la hora exacta
        left: left,
        width: anchoDia,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: rojo, shape: BoxShape.circle),
            ),
            Expanded(child: Container(height: 2, color: rojo)),
          ],
        ),
      ),
    ];
  }

  Widget _celda(Cita? cita) {
    // Celda vacía: solo el divisor de la hora (color anterior).
    if (cita == null) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral400),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // Con cita: tarjeta blanca con franja de estado a la izquierda y texto negro.
    final (_, borde) = cita.estado.colores;
    return SizedBox.expand(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(cita),
        child: Container(
          margin: const EdgeInsets.all(1.5),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: borde),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      _primerNombre(cita.pacienteNombre),
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w600,
                          height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

// Helpers propios de la rejilla semanal.

List<(int, int)> _slots() {
  final lista = <(int, int)>[];
  for (int h = 8; h < 18; h++) {
    lista.add((h, 0));
    lista.add((h, 30));
  }
  return lista; // 08:00 … 17:30
}

Map<String, Cita> _mapaCitas(List<Cita> citas) {
  final mapa = <String, Cita>{};
  for (final c in citas) {
    mapa.putIfAbsent(
        _clave(c.inicia.weekday, c.inicia.hour, c.inicia.minute), () => c);
  }
  return mapa;
}

String _clave(int weekday, int hora, int minuto) => '$weekday-$hora-$minuto';

String _primerNombre(String nombre) =>
    nombre; //Cambiar a primer nombre y primer apellido
