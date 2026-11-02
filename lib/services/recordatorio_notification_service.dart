import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/recordatorio.dart';
import '../repositories/recordatorio_repository_imp.dart';
import 'app_preferences.dart';
import 'notification_service.dart';

class RecordatorioNotificationService {
  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'recordatorios',
      'Recordatorios',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static DateTime fechaProgramada(DateTime fechaObjetivo, TimeOfDay hora) =>
      DateTime(
        fechaObjetivo.year,
        fechaObjetivo.month,
        fechaObjetivo.day,
        hora.hour,
        hora.minute,
      );

  static Future<void> programarPorFecha(Recordatorio r) async {
    if (r.fechaObjetivo == null || r.notificado) return;

    // Un fallo al notificar no debe hacer parecer fallido un recordatorio ya guardado
    try {
      final horaGlobal = await AppPreferences.getHoraNotificacion();
      final fecha = fechaProgramada(r.fechaObjetivo!, horaGlobal);
      final titulo = 'Recordatorio';
      final cuerpo = r.notas ?? 'Tienes un recordatorio pendiente';

      // Se eligió hoy y la hora global ya pasó: se avisa ahora para no perderlo
      if (fecha.isBefore(DateTime.now())) {
        await NotificationService.plugin.show(
          r.idRecordatorio!,
          titulo,
          cuerpo,
          _detalles,
        );
        await RecordatorioRepositoryImpl().marcarNotificado(
          idRecordatorio: r.idRecordatorio!,
        );
        return;
      }

      await NotificationService.plugin.zonedSchedule(
        r.idRecordatorio!,
        titulo,
        cuerpo,
        tz.TZDateTime.from(fecha, tz.local),
        _detalles,
        // Inexacto: un aviso diario no justifica pedir el permiso de alarmas exactas
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error al programar recordatorio: $e');
    }
  }

  static Future<void> cancelar(int idRecordatorio) =>
      NotificationService.plugin.cancel(idRecordatorio);

  /// El sistema entrega los avisos por fecha aunque la app esté cerrada, así que
  /// aquí solo se refleja en la base de datos que ya se dispararon.
  static Future<void> marcarVencidos(int vehiculoId) async {
    final repo = RecordatorioRepositoryImpl();
    final horaGlobal = await AppPreferences.getHoraNotificacion();
    final pendientes = await repo.obtenerPendientesPorVehiculo(vehiculoId);

    for (final r in pendientes) {
      if (r.fechaObjetivo == null) continue;

      final fecha = fechaProgramada(r.fechaObjetivo!, horaGlobal);
      if (fecha.isBefore(DateTime.now())) {
        await repo.marcarNotificado(
          idRecordatorio: r.idRecordatorio!,
          fechaNotificacion: fecha,
        );
      }
    }
  }
}
