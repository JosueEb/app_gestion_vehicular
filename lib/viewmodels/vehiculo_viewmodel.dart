import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../repositories/vehiculo_repository.dart';
import '../repositories/vehiculo_repository_impl.dart';

class VehiculoViewModel extends ChangeNotifier {
  final VehiculoRepository _repository = VehiculoRepositoryImpl();

  List<Vehiculo> vehiculos = [];
  bool isLoading = false;

  Future<void> cargarVehiculos() async {
    isLoading = true;
    notifyListeners();

    vehiculos = await _repository.obtenerVehiculos();

    isLoading = false;
    notifyListeners();
  }

  Future<void> agregarVehiculo(Vehiculo vehiculo) async {
    await _repository.insertarVehiculo(vehiculo);
    await cargarVehiculos();
  }

  Future<void> eliminarVehiculo(int idVehiculo) async {
    await _repository.eliminarVehiculo(idVehiculo);
    await cargarVehiculos();
  }
}
