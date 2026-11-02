import 'gasto_mensual.dart';
import 'gasto_por_tipo.dart';

/// Informe de un tipo de movimiento ('gasto' o 'servicio')
class ReporteMovimiento {
  final int totalEntradas;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  final double costoTotal;
  final double costoPorDia;
  final double costoPorKm;

  final List<GastoPorTipo> conceptos;
  final List<GastoMensual> mensual;

  ReporteMovimiento({
    required this.totalEntradas,
    required this.fechaInicio,
    required this.fechaFin,
    required this.costoTotal,
    required this.costoPorDia,
    required this.costoPorKm,
    required this.conceptos,
    required this.mensual,
  });

  double get costoPromedio => costoTotal / totalEntradas;
}
