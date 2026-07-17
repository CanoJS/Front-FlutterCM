import '../models/cita.dart';

/// Consultas de prueba mientras la API no está lista.
final List<Cita> historialMock = [
  Cita(
    id: 'c0000000-0000-4000-8000-000000000001',
    pacienteId: 'a0000000-0000-4000-8000-000000000001', pacienteNombre: 'Juan Pérez',
    doctorId: 'd0000000-0000-4000-8000-000000000001', doctorNombre: 'Dr. García',
    especialidadNombre: 'Medicina General',
    inicia: DateTime(2025, 4, 28, 9, 30), motivo: 'Control anual',
    estado: EstadoCita.atendida,
    notaMedica: 'Signos vitales normales. Se solicita biometría de rutina.',
  ),
  Cita(
    id: 'c0000000-0000-4000-8000-000000000002',
    pacienteId: 'a0000000-0000-4000-8000-000000000002', pacienteNombre: 'María Ruiz',
    doctorId: 'd0000000-0000-4000-8000-000000000001', doctorNombre: 'Dr. García',
    especialidadNombre: 'Medicina General',
    inicia: DateTime(2025, 2, 10, 11, 0), motivo: 'Dolor de garganta',
    estado: EstadoCita.atendida,
    notaMedica: 'Faringitis. Se receta reposo e hidratación.',
  ),
  Cita(
    id: 'c0000000-0000-4000-8000-000000000003',
    pacienteId: 'a0000000-0000-4000-8000-000000000001', pacienteNombre: 'Juan Pérez',
    doctorId: 'd0000000-0000-4000-8000-000000000001', doctorNombre: 'Dr. García',
    especialidadNombre: 'Medicina General',
    inicia: DateTime(2024, 11, 15, 16, 30), motivo: 'Revisión de presión',
    estado: EstadoCita.atendida,
    notaMedica: 'Presión ligeramente elevada. Control en 1 mes.',
  ),
  Cita(
    id: 'c0000000-0000-4000-8000-000000000004',
    pacienteId: 'a0000000-0000-4000-8000-000000000003', pacienteNombre: 'Carlos Méndez',
    doctorId: 'd0000000-0000-4000-8000-000000000001', doctorNombre: 'Dr. García',
    especialidadNombre: 'Medicina General',
    inicia: DateTime(2024, 8, 3, 10, 0), motivo: 'Consulta general',
    estado: EstadoCita.atendida, notaMedica: null,
  ),
];