import 'package:app_gestion_vehicular/repositories/reporte_recarga_repository.dart';
import 'package:app_gestion_vehicular/repositories/reporte_recarga_repository_imp.dart';
import 'package:flutter/material.dart';
import '../models/reporte_recarga.dart';

class ReporteRecargaViewModel extends ChangeNotifier {
  final ReporteRecargaRepository _repository = ReporteRecargaRepositoryImpl();

  ReporteRecarga? reporte;
  bool isLoading = false;
  String? error;

  DateTime? _desde;
  DateTime? _hasta;

  DateTime? get desde => _desde;
  DateTime? get hasta => _hasta;

  /// Cargar reporte inicial (sin filtro de fechas)
  Future<void> cargarReporte({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _desde = desde;
      _hasta = hasta;

      reporte = await _repository.obtenerReporteRecarga(
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

  /// Cambiar rango de fechas (para filtros futuros)
  Future<void> actualizarRango({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    await cargarReporte(
      vehiculoId: vehiculoId,
      desde: desde,
      hasta: hasta,
    );
  }

  /// Helpers de UI (para evitar lógica en widgets)
  String get rangoFechasTexto {
    if (reporte == null) return '';
    return '${_fmtFecha(reporte!.fechaInicio)} - ${_fmtFecha(reporte!.fechaFin)}';
  }

  String get resumenEntradas {
    if (reporte == null) return '';
    return '${reporte!.totalEntradas} entradas (${rangoFechasTexto})';
  }

  String _fmtFecha(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
