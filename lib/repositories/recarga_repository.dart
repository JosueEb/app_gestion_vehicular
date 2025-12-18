import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';

abstract class RecargaRepository {
  Future<void> registrarRecarga({
    required Movimiento movimiento,
    required MovimientoDetalle detalleSinId,
  });

  Future<List<Movimiento>> obtenerRecargasPorVehiculo(int idVehiculo);
}
