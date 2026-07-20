import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/citas_store.dart';
import '../models/cita.dart';
import '../theme/app_colors.dart';
import '../utils/fechas.dart';
import '../widgets/agenda/detalle_cita.dart';
import '../widgets/agenda/rejilla_semana.dart';
import '../widgets/agenda/vista_mes.dart';
import '../widgets/perfil_medico.dart';
import '../widgets/tarjeta_blanca.dart';
import '../widgets/tarjeta_cita.dart';

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
    _lunesVisible = lunesSemanaAgenda();
    _mesVisible = primerDiaMes(DateTime.now());
  }

  void _cambiarSemana(int delta) {
    setState(() => _lunesVisible = _lunesVisible.add(Duration(days: 7 * delta)));
  }

  void _cambiarMes(int delta) {
    setState(() =>
        _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + delta, 1));
  }

  void _irAHoy() => setState(() => _lunesVisible = lunesSemanaAgenda());

  void _irAMesActual() =>
      setState(() => _mesVisible = primerDiaMes(DateTime.now()));


  void _mostrarDetalle(Cita cita) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => DetalleCita(cita: cita),
    );
  }

  Widget _errorCarga() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColors.neutral400),
          const SizedBox(height: 12),
          Text(citasStore.error ?? 'Ocurrió un error',
              style: const TextStyle(color: AppColors.neutral400)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              citasStore.cargar();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: const [AvatarMedico()],
      ),
      endDrawer: const MedicoDrawer(),
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
                  if (citasStore.cargando && citasStore.agenda.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (citasStore.error != null && citasStore.agenda.isEmpty) {
                    return _errorCarga();
                  }
                  switch (_vista) {
                    case _Vista.mes:
                      return TarjetaBlanca(
                        child: Column(
                          children: [
                            _BarraMes(
                              mes: _mesVisible,
                              onAnterior: () => _cambiarMes(-1),
                              onSiguiente: () => _cambiarMes(1),
                              onHoy: _irAMesActual,
                            ),
                            Expanded(
                              child: VistaMes(
                                  mes: _mesVisible, onTap: _mostrarDetalle),
                            ),
                          ],
                        ),
                      );
                    case _Vista.semana:
                      return RefreshIndicator(
                        onRefresh: citasStore.cargar,
                        child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TarjetaBlanca(
                              child: Column(
                                children: [
                                  _BarraSemana(
                                    lunes: _lunesVisible,
                                    onAnterior: () => _cambiarSemana(-1),
                                    onSiguiente: () => _cambiarSemana(1),
                                    onHoy: _irAHoy,
                                  ),
                                  RejillaSemana(
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
    final mesAnio = cap(DateFormat('MMMM y', 'es_MX').format(lunes));
    final rango =
        '${DateFormat('d', 'es_MX').format(lunes)} – ${cap(DateFormat("d 'de' MMM", 'es_MX').format(viernes))}';
    final esActual = mismoDia(lunes, lunesSemanaAgenda());

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

// ───────────────────────── Apartado "Citas de hoy" ─────────────────────────

class _CitasDeHoy extends StatelessWidget {
  final void Function(Cita) onTap;
  const _CitasDeHoy({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final citasHoy = citasStore.agenda.where((c) => mismoDia(c.inicia, hoy)).toList()
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
            TarjetaCita(cita: c, onTap: () => onTap(c)),
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
    final citas = citasStore.agenda.where((c) => enSemana(c.inicia, lunes)).toList()
      ..sort((a, b) => a.inicia.compareTo(b.inicia));

    Widget contenido;
    if (citas.isEmpty) {
      contenido = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No hay citas esta semana')),
        ],
      );
    } else {
      final porDia = <DateTime, List<Cita>>{};
      for (final c in citas) {
        final dia = DateTime(c.inicia.year, c.inicia.month, c.inicia.day);
        porDia.putIfAbsent(dia, () => []).add(c);
      }
      final dias = porDia.keys.toList()..sort();

      contenido = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          for (final dia in dias) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                cap(DateFormat("EEEE d 'de' MMMM", 'es_MX').format(dia)),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            for (final c in porDia[dia]!) ...[
              TarjetaCita(cita: c, onTap: () => onTap(c)),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: citasStore.cargar,
      child: contenido,
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
    final titulo = cap(DateFormat("MMMM 'de' y", 'es_MX').format(mes));
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
