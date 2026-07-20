import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/env.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/gradient_blob_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
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
      // Envuelve TODAS las pantallas con el fondo (degradado + blobs) una sola vez.
      builder: (context, child) =>
          GradientBlobBackground(child: child ?? const SizedBox.shrink()),
      home: const LoginScreen(), // arranca en el login
    );
  }
}