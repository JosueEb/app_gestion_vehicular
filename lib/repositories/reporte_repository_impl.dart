import 'package:app_gestion_vehicular/models/gasto_mensual.dart';
import 'package:app_gestion_vehicular/models/gasto_por_tipo.dart';
import 'package:app_gestion_vehicular/models/punto_odometro.dart';

import '../data/database_helper.dart';
import '../models/reporte_general_data.dart';
import 'reporte_repository.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<ReporteGeneralData> obtenerReporteGeneral({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await _dbHelper.database;

    final whereFecha = (desde != null && hasta != null)
        ? 'AND fecha BETWEEN ? AND ?'
        : '';

    final args = <dynamic>[vehiculoId];
    if (desde != null && hasta != null) {
      args.addAll([desde.toIso8601String(), hasta.toIso8601String()]);
    }

    /// 🔹 COSTOS (gastos + recargas + servicios)
    final costos = await db.rawQuery('''
      SELECT 
        COUNT(*) AS total_entradas,
        IFNULL(SUM(total), 0) AS total
      FROM movimientos
      WHERE id_vehiculo = ?
      $whereFecha
      ''', args);

    final totalEntradas = costos.first['total_entradas'] as int;
    final costoTotal = (costos.first['total'] as num).toDouble();

    /// 🔹 DISTANCIA
    final distancia = await db.rawQuery('''
      SELECT 
        IFNULL(
          MAX(odometro) - MIN(odometro),
          0
        ) AS km_totales,
        MIN(fecha) AS fecha_inicio,
        MAX(fecha) AS fecha_fin
      FROM movimientos
      WHERE id_vehiculo = ?
      $whereFecha
      ''', args);

    final kmTotales = (distancia.first['km_totales'] as num).toDouble();
    final fechaInicio = distancia.first['fecha_inicio'] != null
        ? DateTime.parse(distancia.first['fecha_inicio'] as String)
        : null;
    final fechaFin = distancia.first['fecha_fin'] != null
        ? DateTime.parse(distancia.first['fecha_fin'] as String)
        : null;

    /// 🔹 DERIVADOS
    final dias = (fechaInicio != null && fechaFin != null)
        ? fechaFin.difference(fechaInicio).inDays + 1
        : 1;

    final double costoPorDia = dias > 0 ? costoTotal / dias : 0;
    final double costoPorKm = kmTotales > 0 ? costoTotal / kmTotales : 0;
    final double kmPromedioDiario = dias > 0 ? kmTotales / dias : 0;

    return ReporteGeneralData(
      totalEntradas: totalEntradas,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      costoTotal: costoTotal,
      costoPorDia: costoPorDia,
      costoPorKm: costoPorKm,
      kmTotales: kmTotales,
      kmPromedioDiario: kmPromedioDiario,
    );
  }

  @override
  Future<List<GastoMensual>> obtenerGastosMensuales({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await _dbHelper.database;

    final whereFecha = (desde != null && hasta != null)
        ? 'AND fecha BETWEEN ? AND ?'
        : '';

    final args = <dynamic>[vehiculoId];
    if (desde != null && hasta != null) {
      args.addAll([desde.toIso8601String(), hasta.toIso8601String()]);
    }

    final res = await db.rawQuery('''
    SELECT
      strftime('%Y', fecha) AS anio,
      strftime('%m', fecha) AS mes,
      SUM(total) AS total
    FROM movimientos
    WHERE id_vehiculo = ?
      AND tipo_movimiento = 'gasto'
      $whereFecha
    GROUP BY anio, mes
    ORDER BY anio, mes
  ''', args);

    return res.map((e) {
      return GastoMensual(
        int.parse(e['anio'] as String),
        int.parse(e['mes'] as String),
        (e['total'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<List<PuntoOdometro>> obtenerOdometro(int vehiculoId) async {
    final db = await _dbHelper.database;

    final res = await db.query(
      'movimientos',
      columns: ['fecha', 'odometro'],
      where: 'id_vehiculo = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fecha',
    );

    return res
        .map(
          (e) => PuntoOdometro(
            fecha: DateTime.parse(e['fecha'] as String),
            odometro: (e['odometro'] as num).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<List<GastoPorTipo>> obtenerGastosPorTipo({
    required int vehiculoId,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await _dbHelper.database;

    final whereFecha = (desde != null && hasta != null)
        ? 'AND m.fecha BETWEEN ? AND ?'
        : '';

    final args = <dynamic>[vehiculoId];
    if (desde != null && hasta != null) {
      args.addAll([desde.toIso8601String(), hasta.toIso8601String()]);
    }

    final res = await db.rawQuery('''
    SELECT
      tg.nombre AS nombre,
      SUM(md.subtotal) AS total
    FROM movimientos m
    JOIN movimiento_detalle md
      ON md.id_movimiento = m.id_movimiento
    JOIN tipos_gasto tg
      ON tg.id_tipo_gasto = md.id_referencia
    WHERE m.id_vehiculo = ?
      AND m.tipo_movimiento = 'gasto'
      $whereFecha
    GROUP BY tg.nombre
    ORDER BY total DESC
  ''', args);

    return res.map((e) {
      return GastoPorTipo(
        e['nombre'] as String,
        (e['total'] as num).toDouble(),
      );
    }).toList();
  }
}
