import '../models/combustible.dart';

abstract class CombustibleRepository {
  Future<List<Combustible>> obtenerCombustibles();
  Future<int> insertarCombustible(Combustible combustible);
  Future<Combustible?> obtenerCombustiblePorId(int id);
  Future<double?> obtenerUltimoCostoLitro(int idCombustible);
}
