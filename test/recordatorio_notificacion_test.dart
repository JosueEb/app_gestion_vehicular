import 'package:app_gestion_vehicular/models/recordatorio.dart';
import 'package:app_gestion_vehicular/services/recordatorio_km_service.dart';
import 'package:app_gestion_vehicular/services/recordatorio_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Recordatorio _recordatorio({bool porKm = true, double? kmObjetivo = 1000}) =>
    Recordatorio(
      idVehiculo: 1,
      tipoRecordatorio: 'servicio',
      frecuencia: 'una_vez',
      porKm: porKm,
      kmObjetivo: kmObjetivo,
      createdAt: DateTime(2026),
    );

void main() {
  test('el aviso por km se dispara al llegar o pasar el objetivo', () {
    final r = _recordatorio();

    expect(RecordatorioKmService.alcanzado(r, 999), isFalse);
    expect(RecordatorioKmService.alcanzado(r, 1000), isTrue);
    expect(RecordatorioKmService.alcanzado(r, 1001), isTrue);
  });

  test('un recordatorio solo por fecha nunca se dispara por km', () {
    final r = _recordatorio(porKm: false, kmObjetivo: null);

    expect(RecordatorioKmService.alcanzado(r, 999999), isFalse);
  });

  test('el aviso por fecha usa el día objetivo y la hora global', () {
    final fecha = RecordatorioNotificationService.fechaProgramada(
      DateTime(2026, 12, 24, 23, 59),
      const TimeOfDay(hour: 17, minute: 5),
    );

    expect(fecha, DateTime(2026, 12, 24, 17, 5));
  });
}
