import 'package:app_gestion_vehicular/models/gasto_mensual.dart';
import 'package:app_gestion_vehicular/models/gasto_por_tipo.dart';
import 'package:app_gestion_vehicular/models/punto_odometro.dart';

import '../models/reporte_general_data.dart';

abstract class ReporteRepository {
  /// Datos generales (tab GENERAL)
  Future<ReporteGeneralData> obtenerReporteGeneral({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  });

  Future<List<PuntoOdometro>> obtenerOdometro(int idVehiculo);
  Future<List<GastoMensual>> obtenerGastosMensuales({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  });
  Future<List<GastoPorTipo>> obtenerGastosPorTipo({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  });
}
