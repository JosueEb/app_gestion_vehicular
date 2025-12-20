import '../data/database_helper.dart';
import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import 'gasto_movimiento_repository.dart';


class GastoMovimientoRepositoryImpl implements GastoMovimientoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> resgistrarGasto({
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
}