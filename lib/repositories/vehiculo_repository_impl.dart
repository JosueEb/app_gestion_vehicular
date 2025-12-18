import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/vehiculo.dart';
import 'vehiculo_repository.dart';

class VehiculoRepositoryImpl implements VehiculoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Vehiculo>> obtenerVehiculos() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehiculos',
      where: 'activo = 1',
    );

    return maps.map((e) => Vehiculo.fromMap(e)).toList();
  }

  @override
  Future<int> insertarVehiculo(Vehiculo vehiculo) async {
    final db = await _dbHelper.database;
    return await db.insert('vehiculos', vehiculo.toMap());
  }

  @override
  Future<int> actualizarVehiculo(Vehiculo vehiculo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'vehiculos',
      vehiculo.toMap(),
      where: 'id_vehiculo = ?',
      whereArgs: [vehiculo.idVehiculo],
    );
  }

  @override
  Future<int> eliminarVehiculo(int idVehiculo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'vehiculos',
      {'activo': 0},
      where: 'id_vehiculo = ?',
      whereArgs: [idVehiculo],
    );
  }

  @override
  Future<int?> obtenerUltimoKilometraje(int vehiculoId) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
    SELECT IFNULL(odometro, 0) AS odometro
    FROM movimientos
    WHERE id_vehiculo = ?
    ORDER BY fecha DESC
    LIMIT 1
    ''',
      [vehiculoId],
    );

    if (result.isEmpty) return null;

    final value = result.first['odometro'];

    if (value == null) return null;

    return (value as num).toInt();
  }
}
