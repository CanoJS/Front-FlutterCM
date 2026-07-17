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


// ── Datos para la Agenda (citas próximas de esta semana) ──

// Lunes de la semana actual, para que las citas siempre caigan en la vista.
final DateTime _lunesActual = () {
  final hoy = DateTime.now();
  final base = DateTime(hoy.year, hoy.month, hoy.day);
  return base.subtract(Duration(days: base.weekday - 1));
}();

// diaOffset: 0 = lunes ... 4 = viernes
DateTime _slot(int diaOffset, int hora, [int minuto = 0]) =>
    _lunesActual.add(Duration(days: diaOffset, hours: hora, minutes: minuto));

final List<Cita> agendaMock = [
  Cita(
    id: 'ag-01', pacienteId: 'a-01', pacienteNombre: 'Juan Pérez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(0, 9, 0), motivo: 'Control anual',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-02', pacienteId: 'a-04', pacienteNombre: 'Ana López',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(0, 11, 30), motivo: 'Dolor abdominal',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-03', pacienteId: 'a-05', pacienteNombre: 'Pedro Sánchez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(1, 8, 30), motivo: 'Seguimiento',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-04', pacienteId: 'a-02', pacienteNombre: 'María Ruiz',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(2, 10, 0), motivo: 'Revisión de presión',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-05', pacienteId: 'a-06', pacienteNombre: 'Luis Torres',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(2, 16, 0), motivo: 'Consulta general',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-06', pacienteId: 'a-07', pacienteNombre: 'Sofía Ramírez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(3, 12, 0), motivo: 'Chequeo',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-07', pacienteId: 'a-03', pacienteNombre: 'Carlos Méndez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(4, 15, 30), motivo: 'Resultados de laboratorio',
    estado: EstadoCita.programada, notaMedica: null,
  ),
  // ── Próxima semana ──
  Cita(
    id: 'ag-08', pacienteId: 'a-04', pacienteNombre: 'Ana López',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(7, 9, 0), motivo: 'Seguimiento', estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-09', pacienteId: 'a-01', pacienteNombre: 'Juan Pérez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(9, 10, 30), motivo: 'Control', estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-10', pacienteId: 'a-06', pacienteNombre: 'Luis Torres',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(11, 16, 0), motivo: 'Revisión', estado: EstadoCita.programada, notaMedica: null,
  ),
  // ── Semana siguiente ──
  Cita(
    id: 'ag-11', pacienteId: 'a-07', pacienteNombre: 'Sofía Ramírez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(15, 8, 30), motivo: 'Chequeo', estado: EstadoCita.programada, notaMedica: null,
  ),
  Cita(
    id: 'ag-12', pacienteId: 'a-03', pacienteNombre: 'Carlos Méndez',
    doctorId: 'd-01', doctorNombre: 'Dr. García', especialidadNombre: 'Medicina General',
    inicia: _slot(17, 12, 0), motivo: 'Resultados de laboratorio', estado: EstadoCita.programada, notaMedica: null,
  ),
];