// Utilidades de fecha y texto compartidas entre pantallas.

/// Lunes (00:00) de la semana actual.
DateTime lunesDeEstaSemana() {
  final hoy = DateTime.now();
  final base = DateTime(hoy.year, hoy.month, hoy.day);
  return base.subtract(Duration(days: base.weekday - 1));
}

/// Lunes de la semana que la agenda debe mostrar por defecto.
///
/// En fin de semana (sábado o domingo) salta a la semana siguiente, ya que la
/// jornada laboral es de lunes a viernes y la semana actual ya terminó.
DateTime lunesSemanaAgenda() {
  final lunes = lunesDeEstaSemana();
  final hoy = DateTime.now();
  final esFinDeSemana =
      hoy.weekday == DateTime.saturday || hoy.weekday == DateTime.sunday;
  return esFinDeSemana ? lunes.add(const Duration(days: 7)) : lunes;
}

/// Primer día del mes al que pertenece [d].
DateTime primerDiaMes(DateTime d) => DateTime(d.year, d.month, 1);

/// True si [fecha] cae de lunes a viernes de la semana que empieza en [lunes].
bool enSemana(DateTime fecha, DateTime lunes) {
  final inicio = DateTime(lunes.year, lunes.month, lunes.day);
  final fin = inicio.add(const Duration(days: 5)); // hasta el sábado 00:00
  return !fecha.isBefore(inicio) && fecha.isBefore(fin);
}

/// True si [a] y [b] son el mismo día natural.
bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Pone en mayúscula la primera letra (útil para nombres de mes/día).
String cap(String t) =>
    t.isEmpty ? t : '${t[0].toUpperCase()}${t.substring(1)}';
