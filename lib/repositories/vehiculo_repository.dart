import '../models/vehiculo.dart';

abstract class VehiculoRepository {
  Future<List<Vehiculo>> obtenerVehiculos();
  Future<int> insertarVehiculo(Vehiculo vehiculo);
  Future<int> actualizarVehiculo(Vehiculo vehiculo);
  Future<int> eliminarVehiculo(int idVehiculo);
}
