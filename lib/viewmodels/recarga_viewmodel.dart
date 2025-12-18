import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import '../repositories/recarga_repository.dart';
import '../repositories/recarga_repository_impl.dart';
import '../services/app_preferences.dart';

class RecargaViewModel extends ChangeNotifier {
  final RecargaRepository _repository = RecargaRepositoryImpl();

  bool isLoading = false;

  Future<void> registrarRecarga({
    required int vehiculoId,
    required DateTime fecha,
    required double litros,
    required double precioUnitario,
    required double odometro,
    required int idCombustible,
    required String observaciones,
    required bool tanqueLleno,
  }) async {
    isLoading = true;
    notifyListeners();

    final idVehiculo = await AppPreferences.getVehiculoActivo();
    if (idVehiculo == null) throw Exception('No hay vehículo activo');

    final movimiento = Movimiento(
      idVehiculo: idVehiculo,
      idUsuario: 1,
      tipoMovimiento: 'combustible',
      fecha: fecha,
      odometro: odometro,
      total: litros * precioUnitario,
      observaciones: observaciones,
    );

    final detalle = MovimientoDetalle(
      tipoDetalle: 'combustible',
      idReferencia: idCombustible,
      cantidad: litros,
      precioUnitario: precioUnitario,
      subtotal: litros * precioUnitario,
      tanqueLleno: tanqueLleno,
    );

    await _repository.registrarRecarga(
      movimiento: movimiento,
      detalleSinId: detalle,
    );

    isLoading = false;
    notifyListeners();
  }
}
