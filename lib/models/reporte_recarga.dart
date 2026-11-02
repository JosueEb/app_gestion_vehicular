class PuntoRecarga {
  final DateTime fecha;
  final double precioLitro;
  final double? rendimiento;

  PuntoRecarga({
    required this.fecha,
    required this.precioLitro,
    this.rendimiento,
  });
}

class ReporteRecarga {
  final int totalEntradas;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  final double costoTotal;
  final double costoPorDia;
  final double costoPorKm;

  final double litrosTotales;
  final double rendimientoPromedio;

  final double eficienciaUltima;
  final double eficienciaMaxima;
  final double eficienciaMinima;

  /// Ordenados del más antiguo al más reciente
  final List<PuntoRecarga> puntos;

  ReporteRecarga({
    required this.totalEntradas,
    required this.fechaInicio,
    required this.fechaFin,
    required this.costoTotal,
    required this.costoPorDia,
    required this.costoPorKm,
    required this.litrosTotales,
    required this.rendimientoPromedio,
    required this.eficienciaUltima,
    required this.eficienciaMaxima,
    required this.eficienciaMinima,
    required this.puntos,
  });

  double get precioPromedioLitro =>
      litrosTotales > 0 ? costoTotal / litrosTotales : 0;

  double get costoPromedio => costoTotal / totalEntradas;
}
