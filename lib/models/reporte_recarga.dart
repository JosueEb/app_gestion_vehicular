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
  });
}
