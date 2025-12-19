import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';

abstract class ServicioMovimientoRepository {
  Future<void> registrarServicio({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });
}
