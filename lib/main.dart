import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  runApp(const PortalMedicoApp());
}

class PortalMedicoApp extends StatelessWidget {
  const PortalMedicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Médico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeShell(), // temporal — aquí normalmente iría LoginScreen
    );
  }
}