import 'package:flutter/material.dart';
import '../models/tipo_servicio.dart';
import '../repositories/servicio_repository.dart';
import '../repositories/servicio_repository_impl.dart';

class ServicioViewModel extends ChangeNotifier {
  final ServicioRepository _repository = ServicioRepositoryImpl();

  List<TipoServicio> servicios = [];
  TipoServicio? servicioSeleccionado;
  bool isLoading = false;

  Future<void> cargarServicios() async {
    isLoading = true;
    notifyListeners();

    servicios = await _repository.obtenerServicios();

    if (servicios.isNotEmpty && servicioSeleccionado == null) {
      servicioSeleccionado = servicios.first;
    }

    isLoading = false;
    notifyListeners();
  }

  void seleccionarServicio(TipoServicio servicio) {
    servicioSeleccionado = servicio;
    notifyListeners();
  }

  void insertarServicio(TipoServicio servicio) async {
    isLoading = true;
    notifyListeners();
    await _repository.insertarServicio(servicio);
    await cargarServicios();
    isLoading = false;
    notifyListeners();
  }
}
