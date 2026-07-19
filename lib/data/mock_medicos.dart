import '../models/doctor.dart';
import '../models/especialidad.dart';

/// Cuenta de un médico para la simulación de login (médico + contraseña).
class CuentaMedico {
  final Doctor doctor;
  final String password;
  const CuentaMedico({required this.doctor, required this.password});
}

const _medicinaGeneral = Especialidad(
    id: 'e0000000-0000-4000-8000-000000000001', nombre: 'Medicina General');
const _pediatria = Especialidad(
    id: 'e0000000-0000-4000-8000-000000000002', nombre: 'Pediatría');
const _cardiologia = Especialidad(
    id: 'e0000000-0000-4000-8000-000000000003', nombre: 'Cardiología');

/// Médicos "registrados en la BD". Solo estos correos + contraseñas pueden entrar.
const List<CuentaMedico> medicosMock = [
  CuentaMedico(
    doctor: Doctor(
      id: 'd0000000-0000-4000-8000-000000000001',
      nombreCompleto: 'García López',
      email: 'garcia@mediclick.com',
      especialidad: _medicinaGeneral,
      activo: true,
    ),
    password: 'medico123',
  ),
  CuentaMedico(
    doctor: Doctor(
      id: 'd0000000-0000-4000-8000-000000000002',
      nombreCompleto: 'Ramírez Soto',
      email: 'ramirez@mediclick.com',
      especialidad: _pediatria,
      activo: true,
    ),
    password: 'pediatria2024',
  ),
  // Cuenta inactiva: sirve para probar el bloqueo de acceso.
  CuentaMedico(
    doctor: Doctor(
      id: 'd0000000-0000-4000-8000-000000000003',
      nombreCompleto: 'Herrera Cruz',
      email: 'herrera@mediclick.com',
      especialidad: _cardiologia,
      activo: false,
    ),
    password: 'corazon123',
  ),
];
