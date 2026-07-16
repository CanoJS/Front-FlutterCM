import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_citas.dart';
import '../models/cita.dart';
import '../theme/app_colors.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _controller = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Cita> get _consultas {
    if (_filtro.trim().isEmpty) return historialMock;
    final q = _filtro.toLowerCase();
    return historialMock
        .where((c) => c.pacienteNombre.toLowerCase().contains(q))
        .toList();
  }

  void _mostrarDetalle(Cita cita) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DetalleConsulta(cita: cita),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consultas = _consultas;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Consultas')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _filtro = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por paciente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: consultas.isEmpty
                  ? const Center(child: Text('Sin consultas para ese paciente'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: consultas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _TarjetaConsulta(
                        cita: consultas[i],
                        onTap: () => _mostrarDetalle(consultas[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaConsulta extends StatelessWidget {
  final Cita cita;
  final VoidCallback onTap;

  const _TarjetaConsulta({required this.cita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat("d 'de' MMMM 'de' y", 'es_MX').format(cita.inicia);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        clipBehavior: Clip.antiAlias, // recorta la franja a las esquinas
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: IntrinsicHeight( // hace que la franja tome el alto completo
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: AppColors.atendidaBorde), // ← franja verde
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary50,
                        child: const Icon(Icons.person_outline,
                            color: AppColors.primary600),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cita.motivo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text('$fecha · ${cita.pacienteNombre}',
                                style: const TextStyle(
                                    color: AppColors.neutral400, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.neutral200),
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

class _DetalleConsulta extends StatelessWidget {
  final Cita cita;

  const _DetalleConsulta({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat("EEEE d 'de' MMMM 'de' y", 'es_MX').format(cita.inicia);
    final hora = DateFormat('h:mm a', 'es_MX').format(cita.inicia);

    return SingleChildScrollView( // por si el texto grande no cabe
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cita.pacienteNombre,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('$fecha · $hora',
                style: const TextStyle(color: AppColors.neutral400, fontSize: 15)),
            const Divider(height: 40),
            _Campo(etiqueta: 'Motivo', valor: cita.motivo),
            const SizedBox(height: 28),
            _Campo(
              etiqueta: 'Nota médica',
              valor: cita.notaMedica ?? 'Sin nota registrada',
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Campo({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.neutral400)),
        const SizedBox(height: 6),
        Text(valor, style: const TextStyle(fontSize: 16, height: 1.4)),
      ],
    );
  }
}