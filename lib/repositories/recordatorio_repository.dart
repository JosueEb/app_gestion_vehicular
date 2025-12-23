import '../models/recordatorio.dart';

abstract class RecordatorioRepository {
  Future<int> crear(Recordatorio recordatorio);

  Future<List<Recordatorio>> obtenerTodos(int idVehiculo);

  Future<Recordatorio?> obtenerPorId(int idRecordatorio);

  Future<void> actualizar(Recordatorio recordatorio);

  Future<void> eliminar(int idRecordatorio);

  Future<List<Recordatorio>> obtenerPendientesPorVehiculo(int vehiculoId);

  Future<void> marcarNotificado({
    required int idRecordatorio,
    DateTime? fechaNotificacion,
  });
}
