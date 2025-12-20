import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/tipo_gasto.dart';
import 'gasto_repository.dart';

class GastoRepositoryImpl implements GastoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<TipoGasto>> obtenerGastos() async {
    final Database db = await _dbHelper.database;

    final result = await db.query(
      'tipos_gasto',
      orderBy: 'nombre ASC',
    );

    return result.map((e) => TipoGasto.fromMap(e)).toList();
  }

  @override
  Future<int> insertarTipoGasto(TipoGasto gasto) async {
    final Database db = await _dbHelper.database;
    return await db.insert('tipos_gasto', gasto.toMap());
  }
}
