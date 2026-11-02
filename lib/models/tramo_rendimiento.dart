class RecargaTanque {
  final double odometro;
  final double litros;
  final double costo;
  final bool tanqueLleno;

  const RecargaTanque({
    required this.odometro,
    required this.litros,
    required this.costo,
    required this.tanqueLleno,
  });

  factory RecargaTanque.fromMap(Map<String, dynamic> map) => RecargaTanque(
    odometro: (map['odometro'] as num).toDouble(),
    litros: (map['cantidad'] as num).toDouble(),
    costo: (map['subtotal'] as num).toDouble(),
    tanqueLleno: map['tanque_lleno'] == 1,
  );
}

class TramoRendimiento {
  final double km;
  final double litros;
  final double costo;

  const TramoRendimiento({
    required this.km,
    required this.litros,
    required this.costo,
  });

  double get rendimiento => km / litros;
  double get costoPorKm => costo / km;
}

/// Método de tanque lleno a tanque lleno: lo consumido desde [actual] es lo que
/// se cargó después, incluidas las recargas parciales, hasta volver a llenar.
/// [siguientes] va en orden cronológico. Es null si [actual] no llenó el tanque
/// o si todavía no hay otra recarga que lo llene.
TramoRendimiento? calcularTramo(
  RecargaTanque actual,
  Iterable<RecargaTanque> siguientes,
) {
  if (!actual.tanqueLleno) return null;

  var litros = 0.0;
  var costo = 0.0;

  for (final s in siguientes) {
    litros += s.litros;
    costo += s.costo;
    if (!s.tanqueLleno) continue;

    final km = s.odometro - actual.odometro;
    if (km <= 0 || litros <= 0) return null;
    return TramoRendimiento(km: km, litros: litros, costo: costo);
  }

  return null;
}
