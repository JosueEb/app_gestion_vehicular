import 'package:flutter/material.dart';

import '../models/combustible.dart';
import '../repositories/combustible_repository.dart';
import '../repositories/combustible_repository_imp.dart';
import '../services/app_preferences.dart';

class CombustibleViewModel extends ChangeNotifier {
  final CombustibleRepository _repository =
      CombustibleRepositoryImpl();

  List<Combustible> combustibles = [];
  Combustible? combustibleActivo;

  Future<void> cargarCombustibles() async {
    combustibles = await _repository.obtenerCombustibles();
    await _cargarCombustibleActivo();
    notifyListeners();
  }

  Future<void> seleccionarCombustible(Combustible combustible) async {
    combustibleActivo = combustible;
    await AppPreferences.setCombustibleActivo(
      combustible.idCombustible!,
    );
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
}
