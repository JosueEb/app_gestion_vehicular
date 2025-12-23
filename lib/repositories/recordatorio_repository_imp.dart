import '../data/database_helper.dart';
import '../models/recordatorio.dart';
import 'recordatorio_repository.dart';

class RecordatorioRepositoryImpl implements RecordatorioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<int> crear(Recordatorio recordatorio) async {
    final db = await _dbHelper.database;
    return await db.insert('recordatorios', recordatorio.toMap());
  }

  @override
  Future<List<Recordatorio>> obtenerTodos(int idVehiculo) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'recordatorios',
      where: 'id_vehiculo = ? AND activo = 1',
      whereArgs: [idVehiculo],
      orderBy: 'created_at DESC',
    );

    return result.map((e) => Recordatorio.fromMap(e)).toList();
  }

  @override
  Future<Recordatorio?> obtenerPorId(int idRecordatorio) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'recordatorios',
      where: 'id_recordatorio = ?',
      whereArgs: [idRecordatorio],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Recordatorio.fromMap(result.first);
  }

  @override
  Future<void> actualizar(Recordatorio recordatorio) async {
    final db = await _dbHelper.database;
    await db.update(
      'recordatorios',
      recordatorio.toMap(),
      where: 'id_recordatorio = ?',
      whereArgs: [recordatorio.idRecordatorio],
    );
  }

  @override
  Future<void> eliminar(int idRecordatorio) async {
    final db = await _dbHelper.database;
    await db.update(
      'recordatorios',
      {'activo': 0},
      where: 'id_recordatorio = ?',
      whereArgs: [idRecordatorio],
    );
  }

  // --------------------------------------------------
  // 📌 Obtener recordatorios pendientes por vehículo
  // --------------------------------------------------
  @override
  Future<List<Recordatorio>> obtenerPendientesPorVehiculo(
    int vehiculoId,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'recordatorios',
      where: 'id_vehiculo = ? AND notificado = 0',
      whereArgs: [vehiculoId],
      orderBy: '''
        CASE 
          WHEN odometro_objetivo IS NOT NULL THEN odometro_objetivo
          ELSE fecha_programada
        END
      ''',
    );

    return result.map((map) => Recordatorio.fromMap(map)).toList();
  }

  // --------------------------------------------------
  // 📌 Marcar recordatorio como notificado
  // --------------------------------------------------
  @override
  Future<void> marcarNotificado({
    required int idRecordatorio,
    DateTime? fechaNotificacion,
  }) async {
    final db = await _dbHelper.database;

    await db.update(
      'recordatorios',
      {
        'notificado': 1,
        'fecha_notificacion': (fechaNotificacion ?? DateTime.now())
            .toIso8601String(),
      },
      where: 'id_recordatorio = ?',
      whereArgs: [idRecordatorio],
    );
  }
}
