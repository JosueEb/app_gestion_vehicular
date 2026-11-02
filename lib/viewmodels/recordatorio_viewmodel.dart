import 'package:flutter/material.dart';
import '../models/recordatorio.dart';
import '../repositories/recordatorio_repository.dart';
import '../repositories/recordatorio_repository_imp.dart';
import '../services/app_preferences.dart';
import '../services/recordatorio_notification_service.dart';

class RecordatorioViewModel extends ChangeNotifier {
  final RecordatorioRepository _repo = RecordatorioRepositoryImpl();

  bool isLoading = false;
  List<Recordatorio> _recordatorios = [];

  List<Recordatorio> get recordatorios =>
      List.unmodifiable(_recordatorios);

  // =====================
  // CRUD
  // =====================

  Future<void> cargarRecordatorios() async {
    isLoading = true;
    notifyListeners();

    final idVehiculo = await AppPreferences.getVehiculoActivo();
    if (idVehiculo == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    await RecordatorioNotificationService.marcarVencidos(idVehiculo);
    _recordatorios = await _repo.obtenerTodos(idVehiculo);

    isLoading = false;
    notifyListeners();
  }

  Future<void> crearRecordatorio(Recordatorio recordatorio) async {
    isLoading = true;
    notifyListeners();

    final id = await _repo.crear(recordatorio);
    final guardado = await _repo.obtenerPorId(id);
    if (guardado != null) {
      await RecordatorioNotificationService.programarPorFecha(guardado);
    }
    await cargarRecordatorios();
  }

  Future<Recordatorio?> obtenerPorId(int id) {
    return _repo.obtenerPorId(id);
  }

  Future<void> actualizarRecordatorio(Recordatorio recordatorio) async {
    isLoading = true;
    notifyListeners();

    await _repo.actualizar(recordatorio);
    await RecordatorioNotificationService.cancelar(
      recordatorio.idRecordatorio!,
    );
    await RecordatorioNotificationService.programarPorFecha(recordatorio);
    await cargarRecordatorios();
  }

  Future<void> eliminarRecordatorio(int idRecordatorio) async {
    isLoading = true;
    notifyListeners();

    await _repo.eliminar(idRecordatorio);
    await RecordatorioNotificationService.cancelar(idRecordatorio);
    await cargarRecordatorios();
  }
}
