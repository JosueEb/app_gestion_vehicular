import 'package:app_gestion_vehicular/models/reporte_recarga.dart';

abstract class ReporteRecargaRepository {
  Future<ReporteRecarga> obtenerReporteRecarga({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  });
}
