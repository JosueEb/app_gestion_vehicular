import 'package:app_gestion_vehicular/models/reporte_recarga.dart';

abstract class ReporteRecargaRepository {
  /// null si no hay recargas en el periodo
  Future<ReporteRecarga?> obtenerReporteRecarga({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  });
}
