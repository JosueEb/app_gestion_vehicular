import '../models/combustible.dart';
import '../data/database_helper.dart';
import 'combustible_repository.dart';

class CombustibleRepositoryImpl implements CombustibleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Combustible>> obtenerCombustibles() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'combustibles',
      orderBy: 'nombre ASC',
    );

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

}
