
enum EstadoCita { programada, atendida, cancelada }

class Cita {
  final String id;
  final String pacienteId;            // patientId
  final String pacienteNombre;     // patientName  (denormalizado)
  final String doctorId;              // doctorId
  final String doctorNombre;       // doctorName   (denormalizado)
  final String especialidadNombre; // specialtyName(denormalizado)
  final DateTime inicia;           // startsAt (ISO 8601)
  final String motivo;             // reason
  final EstadoCita estado;         // status
  final String? notaMedica;        // medicalNote (puede ser null)

  const Cita({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.doctorId,
    required this.doctorNombre,
    required this.especialidadNombre,
    required this.inicia,
    required this.motivo,
    required this.estado,
    required this.notaMedica,
  });

 
  DateTime get termina => inicia.add(const Duration(minutes: 30));
  bool get atendida => estado == EstadoCita.atendida;

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as String,
      pacienteId: json['patientId'] as String,
      pacienteNombre: json['patientName'] as String,
      doctorId: json['doctorId'] as String,
      doctorNombre: json['doctorName'] as String,
      especialidadNombre: json['specialtyName'] as String,
      inicia: DateTime.parse(json['startsAt'] as String),
      motivo: json['reason'] as String,
      estado: _estadoDesde(json['status'] as String),
      notaMedica: json['medicalNote'] as String?,
    );
  }
}

EstadoCita _estadoDesde(String valor) {
  switch (valor) {
    case 'SCHEDULED':
      return EstadoCita.programada;
    case 'ATTENDED':
      return EstadoCita.atendida;
    case 'CANCELLED':
      return EstadoCita.cancelada;
    default:
      throw ArgumentError('Estado de cita desconocido: $valor');
  }
}