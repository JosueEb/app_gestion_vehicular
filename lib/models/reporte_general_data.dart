class ReporteGeneralData {
  final int totalEntradas;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  final double costoTotal;
  final double costoPorDia;
  final double costoPorKm;

  final double kmTotales;
  final double kmPromedioDiario;

  ReporteGeneralData({
    required this.totalEntradas,
    required this.fechaInicio,
    required this.fechaFin,
    required this.costoTotal,
    required this.costoPorDia,
    required this.costoPorKm,
    required this.kmTotales,
    required this.kmPromedioDiario,
  });
}
