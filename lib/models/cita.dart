
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
  final String version;            // version (concurrencia optimista)

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
    this.version = '',
  });

 
  DateTime get termina => inicia.add(const Duration(minutes: 30));
  bool get atendida => estado == EstadoCita.atendida;

  Cita copyWith({EstadoCita? estado, String? notaMedica, String? version}) {
    return Cita(
      id: id,
      pacienteId: pacienteId,
      pacienteNombre: pacienteNombre,
      doctorId: doctorId,
      doctorNombre: doctorNombre,
      especialidadNombre: especialidadNombre,
      inicia: inicia,
      motivo: motivo,
      estado: estado ?? this.estado,
      notaMedica: notaMedica ?? this.notaMedica,
      version: version ?? this.version,
    );
  }

  factory Cita.fromJson(Map<String, dynamic> json) {
    String texto(String clave) => (json[clave] as String?) ?? '';
    return Cita(
      id: texto('id'),
      pacienteId: texto('patientId'),
      pacienteNombre: texto('patientName'),
      doctorId: texto('doctorId'),
      doctorNombre: texto('doctorName'),
      especialidadNombre: texto('specialtyName'),
      inicia: DateTime.parse(json['startsAt'] as String).toLocal(),
      motivo: texto('reason'),
      estado: _estadoDesde(texto('status')),
      notaMedica: json['medicalNote'] as String?,
      version: texto('version'),
    );
  }
}

EstadoCita _estadoDesde(String valor) {
  switch (valor.toUpperCase()) {
    case 'ATTENDED':
    case 'COMPLETED':
      return EstadoCita.atendida;
    case 'CANCELLED':
    case 'CANCELED':
      return EstadoCita.cancelada;
    case 'SCHEDULED':
    case 'PENDING':
    default:
      return EstadoCita.programada;
  }
}