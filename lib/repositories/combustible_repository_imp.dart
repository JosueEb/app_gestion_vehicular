/*combustible_repository.dart*/
import '../models/combustible.dart';
import '../data/database_helper.dart';
import 'combustible_repository.dart';
import 'package:sqflite/sqflite.dart';

class CombustibleRepositoryImpl implements CombustibleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Combustible>> obtenerCombustibles() async {
    final db = await _dbHelper.database;

    final result = await db.query('combustibles', orderBy: 'nombre ASC');

    return result.map((e) => Combustible.fromMap(e)).toList();
  }

  @override
  Future<int> insertarCombustible(Combustible combustible) async {
    final db = await _dbHelper.database;
    return await db.insert('combustibles', combustible.toMap());
  }

  @override
  Future<Combustible?> obtenerCombustiblePorId(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'combustibles',
      where: 'id_combustible = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Combustible.fromMap(result.first);
  }

  @override
  Future<double?> obtenerUltimoCostoLitro(int idCombustible) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT dm.precio_unitario
      FROM movimientos m
      JOIN movimiento_detalle dm
        ON m.id_movimiento = dm.id_movimiento
      WHERE m.tipo_movimiento = 'combustible'
        AND dm.tipo_detalle = 'combustible'
        AND dm.id_referencia = ?
      ORDER BY m.fecha DESC
      LIMIT 1
    ''',
      [idCombustible],
    );

    if (result.isEmpty) return null;

    // print(result.first['precio_unitario']);

    return (result.first['precio_unitario'] as num).toDouble();
  }
}
