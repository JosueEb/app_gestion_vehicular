import '../data/database_helper.dart';
import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import 'recarga_repository.dart';

class RecargaRepositoryImpl implements RecargaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> registrarRecarga({
    required Movimiento movimiento,
    required MovimientoDetalle detalleSinId,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1️⃣ Insertar encabezado
      final movimientoId = await txn.insert('movimientos', movimiento.toMap());

      // 2️⃣ Insertar detalle usando el ID generado
      final detalleMap = detalleSinId.toMap();
      detalleMap['id_movimiento'] = movimientoId;

      await txn.insert('movimiento_detalle', detalleMap);
    });
  }

  @override
  Future<List<Movimiento>> obtenerRecargasPorVehiculo(int idVehiculo) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'movimientos',
      where: 'id_vehiculo = ? AND tipo_movimiento = ?',
      whereArgs: [idVehiculo, 'combustible'],
      orderBy: 'fecha DESC',
    );

    return result.map(Movimiento.fromMap).toList();
  }

  @override
  Future<void> actualizarRecarga({
    required Movimiento movimiento,
    required MovimientoDetalle detalle,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Actualizar encabezado del movimiento
      await txn.update(
        'movimientos',
        movimiento.toMap(),
        where: 'id_movimiento = ?',
        whereArgs: [movimiento.idMovimiento],
      );

      // 2. Actualizar detalle (asumiendo un detalle por recarga)
      await txn.update(
        'movimiento_detalle',
        detalle.toMap(),
        where: 'id_movimiento = ?',
        whereArgs: [movimiento.idMovimiento],
      );
    });
  }

  @override
  Future<void> eliminarRecarga(int idMovimiento) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Eliminar detalles primero por la restricción de llave foránea
      await txn.delete(
        'movimiento_detalle',
        where: 'id_movimiento = ?',
        whereArgs: [idMovimiento],
      );

      // 2. Eliminar el encabezado
      await txn.delete(
        'movimientos',
        where: 'id_movimiento = ?',
        whereArgs: [idMovimiento],
      );
    });
  }

  @override
  Future<Map<String, dynamic>?> obtenerRecargaPorId(int idMovimiento) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
        SELECT
          m.*,
          md.*,
          (
            SELECT m2.odometro
            FROM movimientos m2
            WHERE m2.id_vehiculo = m.id_vehiculo
              AND m2.tipo_movimiento = 'combustible'
              AND m2.fecha < m.fecha
            ORDER BY m2.fecha DESC
            LIMIT 1
          ) AS odometro_anterior,
          ( SELECT m2.odometro
              FROM movimientos m2
              WHERE m2.id_vehiculo = m.id_vehiculo
                AND m2.tipo_movimiento = 'combustible'
                AND m2.fecha > m.fecha
              ORDER BY m2.fecha ASC
              LIMIT 1
            ) AS odometro_siguiente
        FROM movimientos m
        INNER JOIN movimiento_detalle md 
          ON m.id_movimiento = md.id_movimiento
        WHERE m.id_movimiento = ?
    ''',
      [idMovimiento],
    );

    if (result.isEmpty) return null;

    final siguientes = await db.rawQuery(
      '''
        SELECT m.odometro, md.cantidad, md.subtotal, md.tanque_lleno
        FROM movimientos m
        INNER JOIN movimiento_detalle md
          ON m.id_movimiento = md.id_movimiento
        WHERE m.id_vehiculo = ?
          AND m.tipo_movimiento = 'combustible'
          AND m.fecha > ?
        ORDER BY m.fecha ASC
    ''',
      [result.first['id_vehiculo'], result.first['fecha']],
    );

    return {...result.first, 'recargas_siguientes': siguientes};
  }

  @override
  Future<Map<String, double?>> obtenerRangoOdometroPorFecha({
    required int vehiculoId,
    required DateTime fecha,
  }) async {
    final db = await _dbHelper.database;

    // 🔹 Último odómetro ANTES (o igual) a la fecha
    final anterior = await db.rawQuery(
      '''
        SELECT odometro
        FROM movimientos
        WHERE id_vehiculo = ?
          AND fecha < ?
        ORDER BY fecha DESC
        LIMIT 1
    ''',
      [vehiculoId, fecha.toIso8601String()],
    );

    // 🔹 Primer odómetro DESPUÉS de la fecha
    final siguiente = await db.rawQuery(
      '''
        SELECT odometro
        FROM movimientos
        WHERE id_vehiculo = ?
          AND fecha > ?
        ORDER BY fecha ASC
        LIMIT 1
    ''',
      [vehiculoId, fecha.toIso8601String()],
    );

    return {
      'anterior': anterior.isNotEmpty
          ? (anterior.first['odometro'] as num?)?.toDouble()
          : null,
      'siguiente': siguiente.isNotEmpty
          ? (siguiente.first['odometro'] as num?)?.toDouble()
          : null,
    };
  }
}
