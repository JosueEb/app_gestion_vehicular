import 'package:flutter/material.dart';

import '../models/reporte_movimiento.dart';
import '../repositories/reporte_repository.dart';
import '../repositories/reporte_repository_impl.dart';

/// Vive con su pestaña (GASTO o SERVICIO), por eso no se registra en main.dart
class ReporteMovimientoViewModel extends ChangeNotifier {
  final ReporteRepository _repository = ReporteRepositoryImpl();
  final String tipoMovimiento;

  ReporteMovimientoViewModel(this.tipoMovimiento);

  bool isLoading = false;
  String? error;
  ReporteMovimiento? reporte;
  bool _disposed = false;

  Future<void> cargarReporte({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      reporte = await _repository.obtenerReporteMovimiento(
        vehiculoId: vehiculoId,
        tipoMovimiento: tipoMovimiento,
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

  // La pestaña puede cerrarse mientras la consulta sigue en curso
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
