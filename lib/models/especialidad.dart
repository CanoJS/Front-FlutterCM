class Especialidad {
  final String id;
  final String nombre;

  const Especialidad({required this.id, required this.nombre});

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      id: json['id'] as String,
      nombre: json['name'] as String,
    );
  }
}