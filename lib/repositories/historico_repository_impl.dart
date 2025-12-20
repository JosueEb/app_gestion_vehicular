import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../../models/movimiento_detalle.dart';
import '../models/historico_item_ui.dart';
import 'historico_repository.dart';

class HistoricoRepositoryImpl implements HistoricoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<MovimientoHistorico>> obtenerHistorico({
    required int vehiculoId,
  }) async {
    final Database db = await _dbHelper.database;

    final rows = await db.rawQuery(
      '''
        SELECT
            m.id_movimiento,
            m.tipo_movimiento,
            m.fecha,
            m.odometro,
            m.total,
            md.id_detalle,
            md.tipo_detalle,
            md.id_referencia,
            md.descripcion,
            md.cantidad,
            md.precio_unitario,
            md.subtotal,
            md.tanque_lleno,
            ( SELECT m2.odometro
              FROM movimientos m2
              WHERE m2.id_vehiculo = m.id_vehiculo
                AND m2.tipo_movimiento = 'combustible'
                AND m2.fecha > m.fecha
              ORDER BY m2.fecha ASC
              LIMIT 1
            ) AS odometro_siguiente
        FROM movimientos m
        LEFT JOIN movimiento_detalle md 
          ON md.id_movimiento = m.id_movimiento
        WHERE m.id_vehiculo = ?
        ORDER BY m.fecha DESC;
    ''', [vehiculoId]);

    final Map<int, MovimientoHistorico> map = {};

    for (final row in rows) {
      final idMov = row['id_movimiento'] as int;

      /// Crear movimiento si no existe
      map.putIfAbsent(
        idMov,
        () => MovimientoHistorico.fromMovimiento(row),
      );

      /// Agregar detalle si existe
      if (row['id_detalle'] != null) {
        map[idMov]!.detalles.add(
          MovimientoDetalle.fromMap(row),
        );
      }
    }

    return map.values.toList();
  }
}
