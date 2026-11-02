import 'package:flutter/material.dart';

import '../models/gasto_mensual.dart';
import '../models/punto_odometro.dart';
import '../models/gasto_por_tipo.dart';
import '../models/reporte_general_data.dart';
import '../repositories/reporte_repository.dart';
import '../repositories/reporte_repository_impl.dart';

class ReporteGeneralViewModel extends ChangeNotifier {
  final ReporteRepository _repository = ReporteRepositoryImpl();

  /// ===== Estado general =====
  bool isLoading = false;
  String? error;

  ReporteGeneralData? data;

  /// ===== Datos para gráficas =====
  List<PuntoOdometro> puntosOdometro = [];
  List<GastoMensual> gastosMensuales = [];
  List<GastoPorTipo> gastosPorTipo = [];

  /// ===== REPORTE GENERAL =====
  Future<void> cargarReporte({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      data = await _repository.obtenerReporteGeneral(
        vehiculoId: vehiculoId,
        desde: desde,
        hasta: hasta,
      );
      gastosMensuales = await _repository.obtenerGastosMensuales(
        vehiculoId: vehiculoId,
        desde: desde,
        hasta: hasta,
      );
      gastosPorTipo = await _repository.obtenerGastosPorTipo(
        vehiculoId: vehiculoId,
        desde: desde,
        hasta: hasta,
      );
      puntosOdometro = await _repository.obtenerOdometro(
        vehiculoId: vehiculoId,
        desde: desde,
        hasta: hasta,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ===== RESET =====
  void limpiar() {
    data = null;
    puntosOdometro.clear();
    gastosMensuales.clear();
    gastosPorTipo.clear();
    error = null;
    notifyListeners();
  }
}
