import '../models/cita.dart';

/// Consultas de prueba mientras la API no está lista.
final List<Cita> historialMock = [
  Cita(
    id: 1, pacienteId: 101, pacienteNombre: 'Juan Pérez',
    doctorId: 1, doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: DateTime(2025, 4, 28, 9, 30), motivo: 'Control anual',
    estado: EstadoCita.atendida,
    notaMedica: 'Signos vitales normales. Se solicita biometría de rutina.',
  ),
  Cita(
    id: 2, pacienteId: 102, pacienteNombre: 'María Ruiz',
    doctorId: 1, doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: DateTime(2025, 2, 10, 11, 0), motivo: 'Dolor de garganta',
    estado: EstadoCita.atendida,
    notaMedica: 'Faringitis. Se receta reposo e hidratación.',
  ),
  Cita(
    id: 3, pacienteId: 101, pacienteNombre: 'Juan Pérez',
    doctorId: 1, doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: DateTime(2024, 11, 15, 16, 30), motivo: 'Revisión de presión',
    estado: EstadoCita.atendida,
    notaMedica: 'Presión ligeramente elevada. Control en 1 mes.',
  ),
  Cita(
    id: 4, pacienteId: 103, pacienteNombre: 'Carlos Méndez',
    doctorId: 1, doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: DateTime(2024, 8, 3, 10, 0), motivo: 'Consulta general',
    estado: EstadoCita.atendida, notaMedica: null,
  ),
];