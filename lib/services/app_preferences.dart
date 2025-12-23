import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  /* VEHICULO */
  static const _vehiculoActivoKey = 'vehiculo_activo_id';

  static Future<void> setVehiculoActivo(int idVehiculo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_vehiculoActivoKey, idVehiculo);
  }

  static Future<int?> getVehiculoActivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_vehiculoActivoKey);
  }

  static Future<void> clearVehiculoActivo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehiculoActivoKey);
  }

  /* UNIDADES */
  static const _unidadDistanciaKey = 'unidad_distancia';
  static const _unidadVolumenKey = 'unidad_volumen';

  static Future<void> setUnidadDistancia(String unidad) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unidadDistanciaKey, unidad);
  }

  static Future<String> getUnidadDistancia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unidadDistanciaKey) ?? 'km';
  }

  static Future<void> setUnidadVolumen(String unidad) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unidadVolumenKey, unidad);
  }

  static Future<String> getUnidadVolumen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unidadVolumenKey) ?? 'litros';
  }

  /*combustible*/
  static const _combustibleActivoKey = 'combustible_activo_id';

  static Future<void> setCombustibleActivo(int idCombustible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_combustibleActivoKey, idCombustible);
  }

  static Future<int?> getCombustibleActivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_combustibleActivoKey) ?? 1;
  }

  static const _notifHourKey = 'notif_hour';
  static const _notifMinuteKey = 'notif_minute';

  static Future<void> setHoraNotificacion(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notifHourKey, time.hour);
    await prefs.setInt(_notifMinuteKey, time.minute);
  }

  static Future<TimeOfDay> getHoraNotificacion() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_notifHourKey) ?? 17; // 5 PM default
    final minute = prefs.getInt(_notifMinuteKey) ?? 05;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
