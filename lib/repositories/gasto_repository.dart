import '../models/tipo_gasto.dart';

abstract class GastoRepository {
  Future<List<TipoGasto>> obtenerGastos();
  Future<int> insertarTipoGasto(TipoGasto servicio);
}