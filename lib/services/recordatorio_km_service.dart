import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/recordatorio.dart';
import '../repositories/recordatorio_repository_imp.dart';
import 'notification_service.dart';

class RecordatorioKmService {
  static bool alcanzado(Recordatorio r, double odometroActual) =>
      r.porKm && r.kmObjetivo != null && odometroActual >= r.kmObjetivo!;

  static Future<void> evaluar({
    required int vehiculoId,
    required double odometroActual,
  }) async {
    // Un fallo al notificar no debe hacer parecer fallido un movimiento ya guardado
    try {
      final repo = RecordatorioRepositoryImpl();
      final recordatorios = await repo.obtenerPendientesPorVehiculo(vehiculoId);

      for (final r in recordatorios) {
        if (!alcanzado(r, odometroActual)) continue;

        await _notificar(r);
        await repo.marcarNotificado(
          idRecordatorio: r.idRecordatorio!,
          fechaNotificacion: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error al evaluar recordatorios por km: $e');
    }
  }

  static Future<void> _notificar(Recordatorio r) async {
    // Si también tenía aviso por fecha, ya no debe dispararse
    await NotificationService.plugin.cancel(r.idRecordatorio!);
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
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
