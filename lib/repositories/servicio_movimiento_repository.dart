import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';

abstract class ServicioMovimientoRepository {
  Future<void> registrarServicio({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });
  Future<Movimiento> obtenerMovimientoPorId(int idMovimiento);
  Future<List<MovimientoDetalle>> obtenerDetallesPorMovimiento(
    int idMovimiento,
  );

  Future<void> actualizarServicio({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });

  Future<void> eliminarServicio(int idMovimiento);

  Future<Map<String, double?>> obtenerRangoOdometroPorFecha({
    required int vehiculoId,
    required DateTime fecha,
  });
}
