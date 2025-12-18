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
}
