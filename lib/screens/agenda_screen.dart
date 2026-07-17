import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/citas_store.dart';
import '../models/cita.dart';
import '../theme/app_colors.dart';

enum _Vista { semana, lista }

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  _Vista _vista = _Vista.semana;
  late DateTime _lunesVisible;

  @override
  void initState() {
    super.initState();
    _lunesVisible = _lunesDeEstaSemana();
  }

  void _cambiarSemana(int delta) {
    setState(() => _lunesVisible = _lunesVisible.add(Duration(days: 7 * delta)));
  }

  void _irAHoy() => setState(() => _lunesVisible = _lunesDeEstaSemana());


  void _mostrarDetalle(Cita cita) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DetalleCita(cita: cita),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<_Vista>(
                segments: const [
                  ButtonSegment(
                      value: _Vista.semana,
                      icon: Icon(Icons.calendar_view_week),
                      label: Text('Semana')),
                  ButtonSegment(
                      value: _Vista.lista,
                      icon: Icon(Icons.view_list),
                      label: Text('Lista')),
                ],
                selected: {_vista},
                onSelectionChanged: (s) => setState(() => _vista = s.first),
              ),
            ),
            _BarraSemana(
              lunes: _lunesVisible,
              onAnterior: () => _cambiarSemana(-1),
              onSiguiente: () => _cambiarSemana(1),
              onHoy: _irAHoy,
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: citasStore,
                builder: (_, _) => _vista == _Vista.semana
                    ? _VistaSemana(lunes: _lunesVisible, onTap: _mostrarDetalle)
                    : _VistaLista(lunes: _lunesVisible, onTap: _mostrarDetalle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Barra de navegación de semana ─────────────────────────

class _BarraSemana extends StatelessWidget {
  final DateTime lunes;
  final VoidCallback onAnterior, onSiguiente, onHoy;
  const _BarraSemana({
    required this.lunes,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onHoy,
  });

  @override
  Widget build(BuildContext context) {
    final viernes = lunes.add(const Duration(days: 4));
    final mesAnio = _cap(DateFormat('MMMM y', 'es_MX').format(lunes));
    final rango =
        '${DateFormat('d', 'es_MX').format(lunes)} – ${_cap(DateFormat("d 'de' MMM", 'es_MX').format(viernes))}';
    final esActual = _mismoDia(lunes, _lunesDeEstaSemana());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(onPressed: onAnterior, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Column(
              children: [
                Text(mesAnio,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(rango,
                    style: const TextStyle(fontSize: 11, color: AppColors.neutral400)),
              ],
            ),
          ),
          IconButton(onPressed: onSiguiente, icon: const Icon(Icons.chevron_right)),
          if (!esActual)
            TextButton(onPressed: onHoy, child: const Text('Hoy'))
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ───────────────────────── Vista de semana (rejilla) ─────────────────────────

class _VistaSemana extends StatelessWidget {
  final DateTime lunes;
  final void Function(Cita) onTap;
  const _VistaSemana({required this.lunes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dias = List.generate(5, (i) => lunes.add(Duration(days: i)));
    final citasSemana = citasStore.agenda.where((c) => _enSemana(c.inicia, lunes)).toList();
    final mapa = _mapaCitas(citasSemana);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rejilla(dias, mapa),
          const SizedBox(height: 24),
          _CitasDeHoy(onTap: onTap),
        ],
      ),
    );
  }

  Widget _rejilla(List<DateTime> dias, Map<String, Cita> mapa) {
    const anchoHora = 44.0;
    final fmtDia = DateFormat('E', 'es_MX');

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: anchoHora),
            ...dias.map((d) => Expanded(
                  child: Column(
                    children: [
                      Text(_cap(fmtDia.format(d)),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('${d.day}',
                          style: const TextStyle(fontSize: 12, color: AppColors.neutral400)),
                    ],
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),
        ..._slots().map((slot) {
          final (h, m) = slot;
          final etiqueta =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
          return SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: anchoHora,
                  child: Text(etiqueta,
                      style: const TextStyle(fontSize: 10, color: AppColors.neutral400)),
                ),
                ...List.generate(5, (i) {
                  final cita = mapa[_clave(dias[i].weekday, h, m)];
                  return Expanded(child: _celda(cita));
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _celda(Cita? cita) {
    if (cita == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral100)
        ),
      );
    }
    final (fondo, borde) = _coloresEstado(cita.estado);
    return GestureDetector(
      onTap: () => onTap(cita),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: fondo,
          border: Border.all(color: borde),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _primerNombre(cita.pacienteNombre),
          style: TextStyle(
              fontSize: 9.5, color: borde, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ───────────────────────── Apartado "Citas de hoy" ─────────────────────────

class _CitasDeHoy extends StatelessWidget {
  final void Function(Cita) onTap;
  const _CitasDeHoy({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final citasHoy = citasStore.agenda.where((c) => _mismoDia(c.inicia, hoy)).toList()
      ..sort((a, b) => a.inicia.compareTo(b.inicia));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Citas de hoy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (citasHoy.isEmpty)
          const Text('No tienes citas para hoy',
              style: TextStyle(color: AppColors.neutral400))
        else
          for (final c in citasHoy) ...[
            _TarjetaCita(cita: c, onTap: () => onTap(c)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// ───────────────────────── Vista de lista (por día) ─────────────────────────

class _VistaLista extends StatelessWidget {
  final DateTime lunes;
  final void Function(Cita) onTap;
  const _VistaLista({required this.lunes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final citas = citasStore.agenda.where((c) => _enSemana(c.inicia, lunes)).toList()
      ..sort((a, b) => a.inicia.compareTo(b.inicia));

    if (citas.isEmpty) {
      return const Center(child: Text('No hay citas esta semana'));
    }

    final porDia = <DateTime, List<Cita>>{};
    for (final c in citas) {
      final dia = DateTime(c.inicia.year, c.inicia.month, c.inicia.day);
      porDia.putIfAbsent(dia, () => []).add(c);
    }
    final dias = porDia.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final dia in dias) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              _cap(DateFormat("EEEE d 'de' MMMM", 'es_MX').format(dia)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final c in porDia[dia]!) ...[
            _TarjetaCita(cita: c, onTap: () => onTap(c)),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ───────────────────────── Tarjeta reutilizable ─────────────────────────

class _TarjetaCita extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;
  const _TarjetaCita({required this.cita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('h:mm a', 'es_MX').format(cita.inicia);
    final (_, borde) = _coloresEstado(cita.estado);

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
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(cita.motivo, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(hora,
                          style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
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

// ───────────────────────── Hoja de detalle ─────────────────────────

class _DetalleCita extends StatefulWidget {
  final Cita cita;
  const _DetalleCita({required this.cita});

  @override
  State<_DetalleCita> createState() => _DetalleCitaState();
}

class _DetalleCitaState extends State<_DetalleCita> {
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
        _cap(DateFormat("EEEE d 'de' MMMM 'de' y", 'es_MX').format(cita.inicia));
    final atendida = cita.estado == EstadoCita.atendida;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La información se muestra como una tarjeta de cita.
          _TarjetaCita(cita: cita, onTap: () {}),
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
              decoration: InputDecoration(
                hintText: 'Escribe la nota de la consulta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _agregandoNota = false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _guardar,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Helpers ─────────────────────────

DateTime _lunesDeEstaSemana() {
  final hoy = DateTime.now();
  final base = DateTime(hoy.year, hoy.month, hoy.day);
  return base.subtract(Duration(days: base.weekday - 1));
}

bool _enSemana(DateTime fecha, DateTime lunes) {
  final inicio = DateTime(lunes.year, lunes.month, lunes.day);
  final fin = inicio.add(const Duration(days: 5)); // hasta el sábado 00:00
  return !fecha.isBefore(inicio) && fecha.isBefore(fin);
}

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
    mapa.putIfAbsent(_clave(c.inicia.weekday, c.inicia.hour, c.inicia.minute), () => c);
  }
  return mapa;
}

String _clave(int weekday, int hora, int minuto) => '$weekday-$hora-$minuto';

bool _mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _cap(String t) => t.isEmpty ? t : '${t[0].toUpperCase()}${t.substring(1)}';

String _primerNombre(String nombre) => nombre.split(' ').first;

/// (fondo, borde) según el estado de la cita.
(Color, Color) _coloresEstado(EstadoCita estado) {
  switch (estado) {
    case EstadoCita.atendida:
      return (AppColors.atendidaFondo, AppColors.atendidaBorde);
    case EstadoCita.cancelada:
      return (AppColors.canceladaFondo, AppColors.canceladaBorde);
    case EstadoCita.programada:
      return (AppColors.pendienteFondo, AppColors.pendienteBorde);
  }
}