import 'dart:ui';

import 'package:flutter/material.dart';

/// Fondo con degradado diagonal + dos "blobs" de color difuminados.
/// Equivalente al fondo usado en el front web (login, registro y portal paciente).
class GradientBlobBackground extends StatelessWidget {
  final Widget child;

  const GradientBlobBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Degradado diagonal de fondo (equivalente a bg-gradient-to-br)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE6F1FB), // primary-50
                  Color(0xFFF1EFE8), // neutral-50
                  Color(0xFFE0F2FE), // sky-100
                ],
              ),
            ),
          ),
        ),

        // Blob superior izquierdo (azul primario)
        const Positioned(
          top: -96,
          left: -96,
          child: _Blob(color: Color(0xFF85B7EB), opacity: 0.4, size: 320),
        ),

        // Blob inferior derecho (azul cielo)
        const Positioned(
          bottom: -96,
          right: -96,
          child: _Blob(color: Color(0xFFBAE6FD), opacity: 0.4, size: 320),
        ),

        // Contenido real de la pantalla, encima de todo
        child,
      ],
    );
  }
}

/// Círculo de color muy difuminado (equivalente a la utilidad blur-3xl de Tailwind).
class _Blob extends StatelessWidget {
  final Color color;
  final double opacity;
  final double size;

  const _Blob({required this.color, required this.opacity, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}
