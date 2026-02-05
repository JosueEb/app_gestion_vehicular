import 'package:app_gestion_vehicular/data/database_helper.dart';
import 'package:app_gestion_vehicular/models/reporte_recarga.dart';
import 'package:app_gestion_vehicular/repositories/reporte_recarga_repository.dart';

class ReporteRecargaRepositoryImpl implements ReporteRecargaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<ReporteRecarga> obtenerReporteRecarga({
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

    // 🔹 RESUMEN
    final resumen = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        MIN(fecha) AS inicio,
        MAX(fecha) AS fin,
        SUM(total) AS costo
      FROM movimientos
      WHERE id_vehiculo = ?
        $whereFecha
        AND tipo_movimiento = 'combustible'
    ''',
      [vehiculoId],
    );

    final totalEntradas = (resumen.first['total'] as int?) ?? 0;
    final fechaInicio = DateTime.parse(resumen.first['inicio'] as String);
    final fechaFin = DateTime.parse(resumen.first['fin'] as String);
    final costoTotal = (resumen.first['costo'] as num?)?.toDouble() ?? 0;

    final dias = fechaFin.difference(fechaInicio).inDays + 1;
    final double costoPorDia = dias > 0 ? costoTotal / dias : 0;

    // 🔹 KM
    final kmRes = await db.rawQuery(
      '''
      SELECT MAX(odometro) - MIN(odometro) AS km
      FROM movimientos
      WHERE id_vehiculo = ?
        AND tipo_movimiento = 'combustible'
    ''',
      [vehiculoId],
    );

    final kmRecorridos = (kmRes.first['km'] as num?)?.toDouble() ?? 0;
    final double costoPorKm = kmRecorridos > 0 ? costoTotal / kmRecorridos : 0;

    // 🔹 LITROS
    final litrosRes = await db.rawQuery(
      '''
      SELECT SUM(md.cantidad) AS litros
      FROM movimientos m
      JOIN movimiento_detalle md
        ON md.id_movimiento = m.id_movimiento
      WHERE m.id_vehiculo = ?
        AND m.tipo_movimiento = 'combustible'
        $whereFecha
    ''',
      [vehiculoId],
    );

    final litrosTotales = (litrosRes.first['litros'] as num?)?.toDouble() ?? 0;

    final double rendimientoPromedio = litrosTotales > 0
        ? kmRecorridos / litrosTotales
        : 0;

    // 🔹 EFICIENCIAS
    final eficienciaRes = await db.rawQuery(
      '''
      SELECT
        m.odometro,
        md.cantidad AS litros,
        md.tanque_lleno AS tanque_lleno,
        (
          SELECT m2.odometro
          FROM movimientos m2
          WHERE m2.id_vehiculo = m.id_vehiculo
            AND m2.tipo_movimiento = 'combustible'
            AND m2.fecha > m.fecha
          ORDER BY m2.fecha ASC
          LIMIT 1
        ) AS odometro_siguiente
      FROM movimientos m
      JOIN movimiento_detalle md
        ON md.id_movimiento = m.id_movimiento
      WHERE m.id_vehiculo = ?
        AND m.tipo_movimiento = 'combustible'
        $whereFecha
      ORDER BY m.fecha DESC
    ''',
      [vehiculoId],
    );

    final eficiencias = <double>[];

    for (final r in eficienciaRes) {
      final stats = calcularEficiencia(
        odometroActual: (r['odometro'] as num).toDouble(),
        odometroSiguiente: (r['odometro_siguiente'] as num?)?.toDouble(),
        litrosCargados: (r['litros'] as num).toDouble(),
        tanqueLleno: (r['tanque_lleno'] as int) == 1,
      );

      if (stats != null) {
        eficiencias.add(stats['rendimiento']!);
      }
    }

    return ReporteRecarga(
      totalEntradas: totalEntradas,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      costoTotal: costoTotal,
      costoPorDia: costoPorDia,
      costoPorKm: costoPorKm,
      litrosTotales: litrosTotales,
      rendimientoPromedio: rendimientoPromedio,
      eficienciaUltima: eficiencias.isNotEmpty ? eficiencias.first : 0,
      eficienciaMaxima: eficiencias.isNotEmpty
          ? eficiencias.reduce((a, b) => a > b ? a : b)
          : 0,
      eficienciaMinima: eficiencias.isNotEmpty
          ? eficiencias.reduce((a, b) => a < b ? a : b)
          : 0,
    );
  }
}

Map<String, double>? calcularEficiencia({
  required double odometroActual,
  required double? odometroSiguiente,
  required double litrosCargados,
  required bool tanqueLleno,
}) {
  // ❌ SI NO SE LLENÓ EL TANQUE → NO CALCULAR
  if (!tanqueLleno) return null;

  if (odometroSiguiente == null) return null;
  if (litrosCargados <= 0) return null;

  final kmRecorridos = odometroSiguiente - odometroActual;
  if (kmRecorridos <= 0) return null;

  final rendimiento = kmRecorridos / litrosCargados;

  return {
    'litros': litrosCargados,
    'kmRecorridos': kmRecorridos,
    'rendimiento': rendimiento,
    'porcentajeTanque': 100.0,
  };
}
