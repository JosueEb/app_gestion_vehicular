import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/recordatorio.dart';
import 'app_preferences.dart';
import 'notification_service.dart';

class RecordatorioNotificationService {
  static Future<void> programarPorFecha(Recordatorio r) async {
    if (r.fechaObjetivo == null) return;

    final horaGlobal = await AppPreferences.getHoraNotificacion();

    final fechaProgramada = DateTime(
      r.fechaObjetivo!.year,
      r.fechaObjetivo!.month,
      r.fechaObjetivo!.day,
      horaGlobal.hour,
      horaGlobal.minute,
    );

    // ⚠️ Nunca programar en el pasado
    if (fechaProgramada.isBefore(DateTime.now())) return;

    await NotificationService.plugin.zonedSchedule(
      r.idRecordatorio!,
      'Recordatorio',
      r.notas ?? 'Tienes un recordatorio pendiente',
      tz.TZDateTime.from(fechaProgramada, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios',
          'Recordatorios',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
