import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../repositories/vehiculo_repository.dart';
import '../repositories/vehiculo_repository_impl.dart';
import '../services/app_preferences.dart';

class VehiculoViewModel extends ChangeNotifier {
  final VehiculoRepository _repository = VehiculoRepositoryImpl();

  List<Vehiculo> vehiculos = [];
  bool isLoading = false;
  Vehiculo? vehiculoActivo;
  int? _ultimoKilometraje;

  // Future<void> cargarVehiculos() async {
  //   isLoading = true;
  //   notifyListeners();

  //   vehiculos = await _repository.obtenerVehiculos();

  //   isLoading = false;
  //   notifyListeners();
  // }
  Future<void> cargarVehiculos() async {
    vehiculos = await _repository.obtenerVehiculos();

    final id = await AppPreferences.getVehiculoActivo();

    if (vehiculos.isEmpty) {
      vehiculoActivo = null;
    } else if (id == null) {
      vehiculoActivo = vehiculos.first;
      await AppPreferences.setVehiculoActivo(vehiculoActivo!.idVehiculo!);
    } else {
      vehiculoActivo = vehiculos.firstWhere(
        (v) => v.idVehiculo == id,
        orElse: () => vehiculos.first,
      );
    }

    notifyListeners();
  }

  Future<void> agregarVehiculo(Vehiculo vehiculo) async {
    final id = await _repository.insertarVehiculo(vehiculo);

    final vehiculoConId = Vehiculo(
      idVehiculo: id,
      marca: vehiculo.marca,
      modelo: vehiculo.modelo,
      anio: vehiculo.anio,
      placas: vehiculo.placas,
      vin: vehiculo.vin,
      color: vehiculo.color,
      odometroInicial: 0,
      activo: true,
      tamanioTanque: vehiculo.tamanioTanque,
    );

    vehiculoActivo = vehiculoConId;
    await AppPreferences.setVehiculoActivo(id);

    await cargarVehiculos();
  }

  Future<void> eliminarVehiculo(int idVehiculo) async {
    await _repository.eliminarVehiculo(idVehiculo);
    await cargarVehiculos();
  }

  Future<void> seleccionarVehiculo(Vehiculo vehiculo) async {
    vehiculoActivo = vehiculo;
    await AppPreferences.setVehiculoActivo(vehiculo.idVehiculo!);
    notifyListeners();
  }

  Future<void> obtenerVehiculoActivo() async {
    if (vehiculos.isEmpty) return;

    final id = await AppPreferences.getVehiculoActivo();
    if (id == null) return;

    vehiculoActivo = vehiculos.firstWhere(
      (v) => v.idVehiculo == id,
      orElse: () => vehiculos.first,
    );

    notifyListeners();
  }

  int? get ultimoKilometraje => _ultimoKilometraje;

  Future<void> cargarUltimoKilometraje() async {
    if (vehiculoActivo?.idVehiculo == null) {
      _ultimoKilometraje = null;
      notifyListeners();
      return;
    }

    _ultimoKilometraje = await _repository.obtenerUltimoKilometraje(
      vehiculoActivo!.idVehiculo!,
    );
    notifyListeners();
  }
}
