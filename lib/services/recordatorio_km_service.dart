import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/recordatorio.dart';
import '../repositories/recordatorio_repository_imp.dart';
import 'notification_service.dart';

class RecordatorioKmService {
  static Future<void> evaluar({
    required int vehiculoId,
    required double odometroActual,
  }) async {
    final repo = RecordatorioRepositoryImpl();
    final recordatorios = await repo.obtenerPendientesPorVehiculo(vehiculoId);

    for (final r in recordatorios) {
      if (!r.porKm || r.kmObjetivo == null) continue;

      if (odometroActual >= r.kmObjetivo!) {
        await _notificar(r);
        await repo.marcarNotificado(
          idRecordatorio: r.idRecordatorio!,
          fechaNotificacion: DateTime.now(),
        );
      }
    }
  }

  static Future<void> _notificar(Recordatorio r) async {
    await NotificationService.plugin.show(
      r.idRecordatorio!,
      'Recordatorio por km',
      r.notas ?? 'Has alcanzado el kilometraje objetivo',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios_km',
          'Recordatorios por km',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
