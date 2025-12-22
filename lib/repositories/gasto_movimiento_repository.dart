import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';

abstract class GastoMovimientoRepository {
  Future<void> resgistrarGasto({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });
  Future<Movimiento> obtenerMovimientoPorId(int idMovimiento);
  Future<List<MovimientoDetalle>> obtenerDetallesPorMovimiento(
    int idMovimiento,
  );

  Future<void> actualizarGasto({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });

  Future<void> eliminarGasto(int idMovimiento);

  Future<Map<String, double?>> obtenerRangoOdometroPorFecha({
    required int vehiculoId,
    required DateTime fecha,
  });
}
