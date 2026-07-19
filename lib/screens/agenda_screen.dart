import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/citas_store.dart';
import '../models/cita.dart';
import '../theme/app_colors.dart';

enum _Vista { semana, mes, lista }

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  _Vista _vista = _Vista.semana;
  late DateTime _lunesVisible;
  late DateTime _mesVisible;

  @override
  void initState() {
    super.initState();
    _lunesVisible = _lunesDeEstaSemana();
    _mesVisible = _primerDiaMes(DateTime.now());
  }

  void _cambiarSemana(int delta) {
    setState(() => _lunesVisible = _lunesVisible.add(Duration(days: 7 * delta)));
  }

  void _cambiarMes(int delta) {
    setState(() =>
        _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + delta, 1));
  }

  void _irAHoy() => setState(() => _lunesVisible = _lunesDeEstaSemana());

  void _irAMesActual() =>
      setState(() => _mesVisible = _primerDiaMes(DateTime.now()));


  void _mostrarDetalle(Cita cita) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DetalleCita(cita: cita),
    );
  }

  Widget _segmento(String texto, IconData icono, _Vista v) {
    final seleccionado = _vista == v;
    final color = seleccionado ? AppColors.primary600 : AppColors.neutral400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
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
              child: CupertinoSlidingSegmentedControl<_Vista>(
                groupValue: _vista,
                backgroundColor: AppColors.neutral100,
                thumbColor: Colors.white,
                padding: const EdgeInsets.all(4),
                onValueChanged: (v) {
                  if (v != null) setState(() => _vista = v);
                },
                children: {
                  _Vista.mes:
                      _segmento('Mes', Icons.calendar_month, _Vista.mes),
                  _Vista.semana: _segmento(
                      'Semana', Icons.calendar_view_week, _Vista.semana),
                  _Vista.lista:
                      _segmento('Lista', Icons.view_list, _Vista.lista),
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: citasStore,
                builder: (_, _) {
                  switch (_vista) {
                    case _Vista.mes:
                      return _TarjetaBlanca(
                        child: Column(
                          children: [
                            _BarraMes(
                              mes: _mesVisible,
                              onAnterior: () => _cambiarMes(-1),
                              onSiguiente: () => _cambiarMes(1),
                              onHoy: _irAMesActual,
                            ),
                            Expanded(
                              child: _VistaMes(
                                  mes: _mesVisible, onTap: _mostrarDetalle),
                            ),
                          ],
                        ),
                      );
                    case _Vista.semana:
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TarjetaBlanca(
                              child: Column(
                                children: [
                                  _BarraSemana(
                                    lunes: _lunesVisible,
                                    onAnterior: () => _cambiarSemana(-1),
                                    onSiguiente: () => _cambiarSemana(1),
                                    onHoy: _irAHoy,
                                  ),
                                  _RejillaSemana(
                                      lunes: _lunesVisible, onTap: _mostrarDetalle),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _CitasDeHoy(onTap: _mostrarDetalle),
                            ),
                          ],
                        ),
                      );
                    case _Vista.lista:
                      return Column(
                        children: [
                          _BarraSemana(
                            lunes: _lunesVisible,
                            onAnterior: () => _cambiarSemana(-1),
                            onSiguiente: () => _cambiarSemana(1),
                            onHoy: _irAHoy,
                          ),
                          Expanded(
                            child: _VistaLista(
                                lunes: _lunesVisible, onTap: _mostrarDetalle),
                          ),
                        ],
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Contenedor blanco del calendario ─────────────────────────

class _TarjetaBlanca extends StatelessWidget {
  final Widget child;
  const _TarjetaBlanca({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: child,
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

class _RejillaSemana extends StatelessWidget {
  final DateTime lunes;
  final void Function(Cita) onTap;
  const _RejillaSemana({required this.lunes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dias = List.generate(5, (i) => lunes.add(Duration(days: i)));
    final citasSemana = citasStore.agenda.where((c) => _enSemana(c.inicia, lunes)).toList();
    final mapa = _mapaCitas(citasSemana);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: _rejilla(dias, mapa),
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
                          style: const TextStyle(fontSize: 12, color: AppColors.neutral900)),
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
                      style: const TextStyle(fontSize: 10, color: AppColors.neutral900)),
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
    final (_, borde) = _coloresEstado(cita.estado);
    return SizedBox.expand(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(cita),
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

// ───────────────────────── Barra de navegación de mes ─────────────────────────

class _BarraMes extends StatelessWidget {
  final DateTime mes;
  final VoidCallback onAnterior, onSiguiente, onHoy;
  const _BarraMes({
    required this.mes,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onHoy,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = _cap(DateFormat("MMMM 'de' y", 'es_MX').format(mes));
    final ahora = DateTime.now();
    final esActual = mes.year == ahora.year && mes.month == ahora.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(onPressed: onAnterior, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: Text(titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

// ───────────────────────── Vista de mes (calendario) ─────────────────────────

class _VistaMes extends StatelessWidget {
  final DateTime mes; // primer día del mes visible
  final void Function(Cita) onTap;
  const _VistaMes({required this.mes, required this.onTap});

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
    final citas = citasStore.agenda.where((c) => _mismoDia(c.inicia, dia)).toList()
      ..sort((a, b) => a.inicia.compareTo(b.inicia));
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _HojaDia(dia: dia, citas: citas, onTap: onTap),
    );
  }
}

// ───────────────────────── Hoja con las citas de un día ─────────────────────────

class _HojaDia extends StatelessWidget {
  final DateTime dia;
  final List<Cita> citas;
  final void Function(Cita) onTap;
  const _HojaDia({required this.dia, required this.citas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final titulo = _cap(DateFormat("EEEE d 'de' MMMM", 'es_MX').format(dia));

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
            _TarjetaCita(
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

// ───────────────────────── Helpers ─────────────────────────

DateTime _lunesDeEstaSemana() {
  final hoy = DateTime.now();
  final base = DateTime(hoy.year, hoy.month, hoy.day);
  return base.subtract(Duration(days: base.weekday - 1));
}

DateTime _primerDiaMes(DateTime d) => DateTime(d.year, d.month, 1);

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

String _primerNombre(String nombre) => nombre; //Cambiar a primer nombre y primer apellido 

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