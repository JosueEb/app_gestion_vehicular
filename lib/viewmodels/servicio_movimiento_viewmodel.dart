import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import '../repositories/servicio_movimiento_repository.dart';
import '../repositories/servicio_movimiento_repository_impl.dart';
import '../services/app_preferences.dart';

class ServicioMovimientoViewModel extends ChangeNotifier {
  final ServicioMovimientoRepository _repository =
      ServicioMovimientoRepositoryImpl();

  bool isLoading = false;

  final List<MovimientoDetalle> _detalles = [];

  List<MovimientoDetalle> get detalles =>
      List.unmodifiable(_detalles);

  // =====================
  // DETALLES
  // =====================

  void agregarDetalle(MovimientoDetalle detalle) {
    _detalles.add(detalle);
    notifyListeners();
  }

  void eliminarDetalle(int index) {
    if (index < 0 || index >= _detalles.length) return;
    _detalles.removeAt(index);
    notifyListeners();
  }

  void limpiarDetalles() {
    _detalles.clear();
    notifyListeners();
  }

  double get total =>
      _detalles.fold(0, (sum, d) => sum + d.subtotal);

  // =====================
  // REGISTRO
  // =====================

  Future<void> registrarServicio({
    required int vehiculoId,
    required DateTime fecha,
    required double odometro,
    String? observaciones,
    required List<MovimientoDetalle> detalles,
  }) async {
    if (detalles.isEmpty) {
      throw Exception('Debe agregar al menos un detalle');
    }

    isLoading = true;
    notifyListeners();

    final idVehiculo = await AppPreferences.getVehiculoActivo();
    if (idVehiculo == null) {
      isLoading = false;
      notifyListeners();
      throw Exception('No hay vehículo activo');
    }

    final calculoTotal = detalles.fold<double>(0, (sum, d) => sum + d.subtotal);

    final movimiento = Movimiento(
      idVehiculo: idVehiculo,
      idUsuario: 1,
      tipoMovimiento: 'servicio',
      fecha: fecha,
      odometro: odometro,
      total: calculoTotal,
      observaciones: observaciones,
    );

    await _repository.registrarServicio(
      movimiento: movimiento,
      detalles: detalles,
    );

    limpiarDetalles();

    isLoading = false;
    notifyListeners();
  }
}
