/*gasto_viewmodel.dart*/

import 'package:flutter/material.dart';
import '../models/tipo_gasto.dart';
import '../repositories/gasto_repository.dart';
import '../repositories/gasto_repository_imp.dart';

class GastoViewModel extends ChangeNotifier {
  final GastoRepository _repository = GastoRepositoryImpl();
  List<TipoGasto> gastos = [];
  TipoGasto? gastoSeleccionado;
  bool isLoading = false;

  Future<void> cargarGastos() async {
    isLoading = true;
    notifyListeners();

    gastos = await _repository.obtenerGastos();
    if (gastos.isNotEmpty && gastoSeleccionado == null) {
      gastoSeleccionado = gastos.first;
    }

    isLoading = false;
    notifyListeners();
  }

  void seleccionarGasto(TipoGasto gasto) {
    gastoSeleccionado = gasto;
    notifyListeners();
  }  

  void insertarGasto(TipoGasto gasto) async {
    isLoading = true;
    notifyListeners();
    await _repository.insertarTipoGasto(gasto);
    await cargarGastos();
    isLoading = false;
    notifyListeners();
  }
}