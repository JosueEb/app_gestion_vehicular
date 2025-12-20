// import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import 'servicio_movimiento_repository.dart';

class ServicioMovimientoRepositoryImpl implements ServicioMovimientoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> registrarServicio({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      final idMovimiento = await txn.insert('movimientos', movimiento.toMap());

      for (final detalle in detalles) {
        await txn.insert(
          'movimiento_detalle',
          detalle.toMapWithMovimiento(idMovimiento),
        );
      }
    });
  }

  @override
  Future<Movimiento> obtenerMovimientoPorId(int idMovimiento) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'movimientos',
      where: 'id_movimiento = ?',
      whereArgs: [idMovimiento],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Movimiento no encontrado');
    }

    return Movimiento.fromMap(result.first);
  }

  @override
  Future<List<MovimientoDetalle>> obtenerDetallesPorMovimiento(
    int idMovimiento,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'movimiento_detalle',
      where: 'id_movimiento = ?',
      whereArgs: [idMovimiento],
    );

    return result.map((e) => MovimientoDetalle.fromMap(e)).toList();
  }

  @override
  Future<void> actualizarServicio({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Actualizar el encabezado del movimiento
      await txn.update(
        'movimientos',
        movimiento.toMap(),
        where: 'id_movimiento = ?',
        whereArgs: [movimiento.idMovimiento],
      );

      // 2. Eliminar los detalles existentes para este movimiento
      await txn.delete(
        'movimiento_detalle',
        where: 'id_movimiento = ?',
        whereArgs: [movimiento.idMovimiento],
      );

      // 3. Insertar los nuevos detalles
      for (final detalle in detalles) {
        await txn.insert(
          'movimiento_detalle',
          detalle.toMapWithMovimiento(movimiento.idMovimiento!),
        );
      }
    });
  }

  @override
  Future<void> eliminarServicio(int idMovimiento) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Eliminar primero los detalles (Hijos) por integridad referencial
      await txn.delete(
        'movimiento_detalle',
        where: 'id_movimiento = ?',
        whereArgs: [idMovimiento],
      );

      // 2. Eliminar el encabezado del movimiento (Padre)
      await txn.delete(
        'movimientos',
        where: 'id_movimiento = ?',
        whereArgs: [idMovimiento],
      );
    });
  }
}
