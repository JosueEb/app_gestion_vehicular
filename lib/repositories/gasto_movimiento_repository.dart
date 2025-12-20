import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';

abstract class GastoMovimientoRepository {
  Future<void> resgistrarGasto({
    required Movimiento movimiento,
    required List<MovimientoDetalle> detalles,
  });
}
