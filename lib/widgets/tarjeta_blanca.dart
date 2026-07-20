import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Panel del calendario (semanal y mensual) con el mismo estilo "glass" del
/// login —borde blanco tenue y sombra suave— para que combine con el fondo.
class TarjetaBlanca extends StatelessWidget {
  final Widget child;
  const TarjetaBlanca({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: GlassCard(
        padding: const EdgeInsets.only(top: 8),
        child: child,
      ),
    );
  }
}
