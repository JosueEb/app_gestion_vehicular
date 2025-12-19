import 'package:flutter/material.dart';
/*combustible_viewmodel.dart*/
import '../models/combustible.dart';
import '../repositories/combustible_repository.dart';
import '../repositories/combustible_repository_imp.dart';
import '../services/app_preferences.dart';

class CombustibleViewModel extends ChangeNotifier {
  final CombustibleRepository _repository = CombustibleRepositoryImpl();

  List<Combustible> combustibles = [];
  Combustible? combustibleActivo;
  double? _ultimoCostoLitro;

  Future<void> cargarCombustibles() async {
    combustibles = await _repository.obtenerCombustibles();
    await _cargarCombustibleActivo();
    await obtenerUltimoCostoLitro();
    notifyListeners();
  }

  Future<void> seleccionarCombustible(Combustible combustible) async {
    combustibleActivo = combustible;
    await AppPreferences.setCombustibleActivo(combustible.idCombustible!);
    notifyListeners();
  }

  Future<void> _cargarCombustibleActivo() async {
    final id = await AppPreferences.getCombustibleActivo();

    if (combustibles.isEmpty) return;

    combustibleActivo = combustibles.firstWhere(
      (c) => c.idCombustible == id,
      orElse: () => combustibles.first,
    );
  }

  double? get ultimoCostoLitro => _ultimoCostoLitro;
  Future<void> obtenerUltimoCostoLitro() async {
    final id = combustibleActivo?.idCombustible;

    if (id == null) {
      _ultimoCostoLitro = null;
      notifyListeners();
      return;
    }
    _ultimoCostoLitro = await _repository.obtenerUltimoCostoLitro(id);
    notifyListeners();
  }
}
