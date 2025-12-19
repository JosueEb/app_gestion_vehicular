import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import '../repositories/recarga_repository.dart';
import '../repositories/recarga_repository_impl.dart';
import '../services/app_preferences.dart';

class RecargaViewModel extends ChangeNotifier {
  final RecargaRepository _repository = RecargaRepositoryImpl();

  Map<String, dynamic>? recargaSeleccionada;
  bool isLoading = false;

  /// 🔹 Lista de recargas del vehículo (ordenadas por fecha DESC)
  final List<Map<String, dynamic>> _recargas = [];

  /// 🔹 Índice actual dentro de la lista
  int _indiceActual = -1;

  /* -------------------------------------------------------------------------- */
  /*                               NAVEGACIÓN                                   */
  /* -------------------------------------------------------------------------- */

  bool get puedeIrAnterior =>
      _indiceActual > 0 && _indiceActual < _recargas.length;

  bool get puedeIrSiguiente =>
      _indiceActual >= 0 && _indiceActual < _recargas.length - 1;

  void irAnterior() {
    if (!puedeIrAnterior) return;

    _indiceActual--;
    recargaSeleccionada = _recargas[_indiceActual];
    notifyListeners();
  }

  void irSiguiente() {
    if (!puedeIrSiguiente) return;

    _indiceActual++;
    recargaSeleccionada = _recargas[_indiceActual];
    notifyListeners();
  }

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

  Future<void> actualizarRecarga({
    required int idMovimiento,
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

    try {
      final movimiento = Movimiento(
        idMovimiento: idMovimiento,
        idVehiculo: vehiculoId,
        idUsuario: 1, // Hardcoded o de sesión
        tipoMovimiento: 'combustible',
        fecha: fecha,
        odometro: odometro,
        total: litros * precioUnitario,
        observaciones: observaciones,
      );

      final detalle = MovimientoDetalle(
        idMovimiento: idMovimiento,
        tipoDetalle: 'combustible',
        idReferencia: idCombustible,
        cantidad: litros,
        precioUnitario: precioUnitario,
        subtotal: litros * precioUnitario,
        tanqueLleno: tanqueLleno,
      );

      await _repository.actualizarRecarga(
        movimiento: movimiento,
        detalle: detalle,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarRecarga(int idMovimiento) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.eliminarRecarga(idMovimiento);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carga los datos de una recarga para editarlos
  Future<void> prepararEdicion(int idMovimiento) async {
    isLoading = true;
    notifyListeners();

    recargaSeleccionada = await _repository.obtenerRecargaPorId(idMovimiento);

    isLoading = false;
    notifyListeners();
  }

  /// Limpia la selección después de guardar o cancelar
  void limpiarEdicion() {
    recargaSeleccionada = null;
    notifyListeners();
  }
}
