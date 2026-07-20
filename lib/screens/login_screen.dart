import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/auth_store.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_cargando) return;
    setState(() {
      _error = null;
      _cargando = true;
    });

    final resultado =
        await authStore.iniciarSesion(_correoCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _cargando = false);

    switch (resultado) {
      case ResultadoLogin.exito:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      case ResultadoLogin.camposVacios:
        setState(() => _error = 'Ingresa tu correo y contraseña.');
      case ResultadoLogin.credencialesInvalidas:
        setState(() => _error = 'Correo o contraseña incorrectos.');
      case ResultadoLogin.cuentaInactiva:
        setState(() => _error =
            'Tu cuenta está inactiva. Contacta al equipo de MediClick.');
      case ResultadoLogin.errorConexion:
        setState(() => _error =
            'No se pudo conectar. Revisa tu internet e inténtalo de nuevo.');
    }
  }

  void _limpiarError() {
    if (_error != null) setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo-centro-medico.svg',
                    height: 72,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MediClick',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _tarjeta(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjeta() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iniciar sesión',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Accede con tu correo y contraseña.',
            style: TextStyle(fontSize: 14, color: AppColors.neutral400),
          ),
          const SizedBox(height: 24),

          _etiqueta('Correo'),
          const SizedBox(height: 8),
          TextField(
            controller: _correoCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _limpiarError(),
            decoration: _decoracion(),
          ),
          const SizedBox(height: 18),

          _etiqueta('Contraseña'),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _limpiarError(),
            onSubmitted: (_) => _iniciarSesion(),
            decoration: _decoracion(),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 18, color: AppColors.canceladaBorde),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.canceladaBorde),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _cargando ? null : _iniciarSesion,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _cargando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text(
              'En caso de olvidar la contraseña, contáctese con el equipo de MediClick.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, color: AppColors.neutral400, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t) => Text(
        t,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900),
      );

  InputDecoration _decoracion() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary400, width: 1.5),
        ),
      );
}