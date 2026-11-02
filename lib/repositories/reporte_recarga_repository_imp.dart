import 'package:app_gestion_vehicular/data/database_helper.dart';
import 'package:app_gestion_vehicular/models/reporte_recarga.dart';
import 'package:app_gestion_vehicular/models/tramo_rendimiento.dart';
import 'package:app_gestion_vehicular/repositories/reporte_recarga_repository.dart';

class ReporteRecargaRepositoryImpl implements ReporteRecargaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<ReporteRecarga?> obtenerReporteRecarga({
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
        MIN(m.fecha) AS inicio,
        MAX(m.fecha) AS fin,
        SUM(m.total) AS costo
      FROM movimientos m
      WHERE m.id_vehiculo = ?
        $whereFecha
        AND m.tipo_movimiento = 'combustible'
    ''',
      args,
    );

    final totalEntradas = (resumen.first['total'] as int?) ?? 0;
    if (totalEntradas == 0) return null;

    final fechaInicio = DateTime.parse(resumen.first['inicio'] as String);
    final fechaFin = DateTime.parse(resumen.first['fin'] as String);
    final costoTotal = (resumen.first['costo'] as num?)?.toDouble() ?? 0;

    final dias = fechaFin.difference(fechaInicio).inDays + 1;
    final double costoPorDia = dias > 0 ? costoTotal / dias : 0;

    // 🔹 KM
    final kmRes = await db.rawQuery(
      '''
      SELECT MAX(m.odometro) - MIN(m.odometro) AS km
      FROM movimientos m
      WHERE m.id_vehiculo = ?
        AND m.tipo_movimiento = 'combustible'
        $whereFecha
    ''',
      args,
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
      args,
    );

    final litrosTotales = (litrosRes.first['litros'] as num?)?.toDouble() ?? 0;

    // 🔹 EFICIENCIAS
    // Sin filtro de fechas: un tramo del periodo puede cerrarse con una recarga posterior
    final recargas = await db.rawQuery(
      '''
      SELECT
        m.fecha,
        m.odometro,
        md.precio_unitario,
        md.cantidad,
        md.subtotal,
        md.tanque_lleno
      FROM movimientos m
      JOIN movimiento_detalle md
        ON md.id_movimiento = m.id_movimiento
      WHERE m.id_vehiculo = ?
        AND m.tipo_movimiento = 'combustible'
      ORDER BY m.fecha ASC
    ''',
      [vehiculoId],
    );

    final tanques = recargas.map(RecargaTanque.fromMap).toList();
    final eficiencias = <double>[];
    final puntos = <PuntoRecarga>[];
    var kmTramos = 0.0;
    var litrosTramos = 0.0;

    for (var i = 0; i < recargas.length; i++) {
      final fecha = DateTime.parse(recargas[i]['fecha'] as String);
      if (desde != null && hasta != null) {
        if (fecha.isBefore(desde) || fecha.isAfter(hasta)) continue;
      }

      final tramo = calcularTramo(tanques[i], tanques.skip(i + 1));
      if (tramo != null) {
        eficiencias.add(tramo.rendimiento);
        kmTramos += tramo.km;
        litrosTramos += tramo.litros;
      }

      puntos.add(
        PuntoRecarga(
          fecha: fecha,
          precioLitro: (recargas[i]['precio_unitario'] as num).toDouble(),
          rendimiento: tramo?.rendimiento,
        ),
      );
    }

    final double rendimientoPromedio = litrosTramos > 0
        ? kmTramos / litrosTramos
        : 0;

    return ReporteRecarga(
      totalEntradas: totalEntradas,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      costoTotal: costoTotal,
      costoPorDia: costoPorDia,
      costoPorKm: costoPorKm,
      litrosTotales: litrosTotales,
      rendimientoPromedio: rendimientoPromedio,
      eficienciaUltima: eficiencias.isNotEmpty ? eficiencias.last : 0,
      eficienciaMaxima: eficiencias.isNotEmpty
          ? eficiencias.reduce((a, b) => a > b ? a : b)
          : 0,
      eficienciaMinima: eficiencias.isNotEmpty
          ? eficiencias.reduce((a, b) => a < b ? a : b)
          : 0,
      puntos: puntos,
    );
  }
}
