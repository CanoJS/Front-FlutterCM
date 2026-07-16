import 'especialidad.dart';

class Doctor {
  final int id;
  final String nombreCompleto;      // fullName
  final String email;
  final Especialidad especialidad;  // specialty (objeto)
  final bool activo;                // active

  const Doctor({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.especialidad,
    required this.activo,
  });

  String get diminutivo => 'Dr. $nombreCompleto';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      nombreCompleto: json['fullName'] as String,
      email: json['email'] as String,
      especialidad: Especialidad.fromJson(json['specialty'] as Map<String, dynamic>),
      activo: json['active'] as bool,
    );
  }
}