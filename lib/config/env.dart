import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables del archivo .env.
class Env {
  Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  /// Base de la API de negocio (se usará al conectar las citas).
  static String get apiBaseUrl => dotenv.env['BACKEND-API'] ?? '';
}
