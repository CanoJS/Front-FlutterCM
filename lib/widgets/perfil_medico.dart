import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../screens/login_screen.dart';
import '../theme/app_colors.dart';

/// Avatar circular con las iniciales del médico (para el AppBar).
/// Al tocarlo abre el panel lateral con su información.
class AvatarMedico extends StatelessWidget {
  const AvatarMedico({super.key});

  @override
  Widget build(BuildContext context) {
    final medico = authStore.medicoActual;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Tooltip(
        message: 'Perfil',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              _iniciales(medico?.nombreCompleto ?? ''),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel lateral (a la derecha) con la información del médico y cerrar sesión.
class MedicoDrawer extends StatelessWidget {
  const MedicoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final medico = authStore.medicoActual;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: medico == null
            ? const Center(child: Text('No hay sesión activa'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado: avatar grande + nombre y especialidad.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary600,
                          child: Text(
                            _iniciales(medico.nombreCompleto),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medico.diminutivo,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                medico.especialidad.nombre,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.neutral400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Información completa (sin contraseña).
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _Campo(etiqueta: 'Nombre', valor: medico.nombreCompleto),
                        _Campo(etiqueta: 'Correo', valor: medico.email),
                        _Campo(
                            etiqueta: 'Especialidad',
                            valor: medico.especialidad.nombre),
                        _Campo(
                            etiqueta: 'Estado',
                            valor: medico.activo ? 'Activo' : 'Inactivo'),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _cerrarSesion(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.canceladaBorde,
                          side:
                              const BorderSide(color: AppColors.canceladaBorde),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _cerrarSesion(BuildContext context) {
    authStore.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

/// Campo etiqueta (gris) + valor (negro), como en las tarjetas de las citas.
class _Campo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Campo({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral400),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 15, color: AppColors.neutral900),
          ),
        ],
      ),
    );
  }
}

/// Iniciales: primera letra del primer y segundo término del nombre.
String _iniciales(String nombre) {
  final partes =
      nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return '?';
  if (partes.length == 1) return partes.first[0].toUpperCase();
  return (partes[0][0] + partes[1][0]).toUpperCase();
}
