import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/tipo_servicio.dart';
import 'servicio_repository.dart';

class ServicioRepositoryImpl implements ServicioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<TipoServicio>> obtenerServicios() async {
    final Database db = await _dbHelper.database;

    final result = await db.query(
      'tipos_servicio',
      orderBy: 'nombre ASC',
    );

    return result.map((e) => TipoServicio.fromMap(e)).toList();
  }

  @override
  Future<int> insertarServicio(TipoServicio servicio) async {
    final Database db = await _dbHelper.database;
    return await db.insert('tipos_servicio', servicio.toMap());
  }
}
