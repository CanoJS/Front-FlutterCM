import 'dart:async';

import 'package:flutter/material.dart';
import '../data/auth_store.dart';
import '../data/citas_store.dart';
import '../theme/app_colors.dart'; // ajusta si tu ruta difiere
import 'agenda_screen.dart';
import 'historial_screen.dart';

/// Shell con navegación inferior del portal del médico.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pantallas = [
    AgendaScreen(),
    HistorialScreen(),
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Carga las citas y el perfil completo del médico al entrar al portal.
    citasStore.cargar();
    authStore.cargarPerfil();
    // Auto-refresco periódico para reflejar nuevas citas agendadas.
    _timer = Timer.periodic(
      const Duration(seconds: 61),
      (_) => citasStore.cargar(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pantallas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppColors.primary600,
        unselectedItemColor: AppColors.neutral400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}