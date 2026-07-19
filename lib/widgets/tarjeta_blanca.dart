import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Contenedor blanco con borde y sombra suave. Panel genérico reutilizable
/// (por ejemplo, para envolver el calendario).
class TarjetaBlanca extends StatelessWidget {
  final Widget child;
  const TarjetaBlanca({super.key, required this.child});

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
