import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/movimiento_detalle.dart';
import '../repositories/servicio_movimiento_repository.dart';
import '../repositories/servicio_movimiento_repository_impl.dart';
import '../services/app_preferences.dart';
import '../services/movimientos_events.dart';
import '../services/recordatorio_km_service.dart';

class ServicioMovimientoViewModel extends ChangeNotifier {
  final ServicioMovimientoRepository _repository =
      ServicioMovimientoRepositoryImpl();

  bool isLoading = false;

  final List<MovimientoDetalle> _detalles = [];

  List<MovimientoDetalle> get detalles => List.unmodifiable(_detalles);

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

  double get total => _detalles.fold(0, (sum, d) => sum + d.subtotal);

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
    await RecordatorioKmService.evaluar(
      vehiculoId: idVehiculo,
      odometroActual: odometro,
    );
    MovimientosEvents.notificar();

    limpiarDetalles();

    isLoading = false;
    notifyListeners();
  }

  Movimiento? _movimiento;
  List<MovimientoDetalle> _detallesMovimiento = [];

  Movimiento? get movimiento => _movimiento;
  List<MovimientoDetalle> get detallesMovimiento =>
      List.unmodifiable(_detallesMovimiento);

  Future<void> cargarServicioPorId(int idMovimiento) async {
    isLoading = true;
    notifyListeners();

    try {
      _movimiento = await _repository.obtenerMovimientoPorId(idMovimiento);
      _detallesMovimiento = await _repository.obtenerDetallesPorMovimiento(
        idMovimiento,
      );
    } catch (e) {
      _movimiento = null;
      _detallesMovimiento = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Propiedades para la edición
  Movimiento? _movimientoSeleccionado;
  List<MovimientoDetalle> _detallesSeleccionados = [];

  // Getters para la edición
  Movimiento? get movimientoSeleccionado => _movimientoSeleccionado;
  List<MovimientoDetalle> get detallesSeleccionados =>
      List.unmodifiable(_detallesSeleccionados);

  // =====================
  // EDICIÓN
  // =====================

  /// Carga los datos necesarios para iniciar la edición
  Future<void> prepararEdicion(int idMovimiento) async {
    isLoading = true;
    notifyListeners();

    try {
      _movimientoSeleccionado = await _repository.obtenerMovimientoPorId(
        idMovimiento,
      );
      _detallesSeleccionados = await _repository.obtenerDetallesPorMovimiento(
        idMovimiento,
      );
    } catch (e) {
      _movimientoSeleccionado = null;
      _detallesSeleccionados = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarServicio({
    required int idMovimiento,
    required DateTime fecha,
    required double odometro,
    String? observaciones,
    required List<MovimientoDetalle> detalles,
  }) async {
    if (detalles.isEmpty) throw Exception('Debe agregar al menos un detalle');

    isLoading = true;
    notifyListeners();

    try {
      final idVehiculo = await AppPreferences.getVehiculoActivo();
      if (idVehiculo == null) throw Exception('No hay vehículo activo');

      final calculoTotal = detalles.fold<double>(
        0,
        (sum, d) => sum + d.subtotal,
      );

      final movimiento = Movimiento(
        idMovimiento:
            idMovimiento, // Pasamos el ID para que el repo sepa qué editar
        idVehiculo: idVehiculo,
        idUsuario: 1,
        tipoMovimiento: 'servicio',
        fecha: fecha,
        odometro: odometro,
        total: calculoTotal,
        observaciones: observaciones,
      );

      await _repository.actualizarServicio(
        movimiento: movimiento,
        detalles: detalles,
      );
      await RecordatorioKmService.evaluar(
        vehiculoId: idVehiculo,
        odometroActual: odometro,
      );
      MovimientosEvents.notificar();

      limpiarDetalles();
      _movimientoSeleccionado = null;
      _detallesSeleccionados = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarServicio(int idMovimiento) async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Llamada al repositorio para ejecutar la transacción de borrado
      await _repository.eliminarServicio(idMovimiento);
      MovimientosEvents.notificar();

      // 2. Limpiamos el movimiento cargado actualmente en memoria si es el mismo
      if (_movimiento?.idMovimiento == idMovimiento) {
        _movimiento = null;
        _detallesMovimiento = [];
      }

      // Opcional: Aquí podrías llamar a un método para refrescar
      // la lista del historial si fuera necesario.
    } catch (e) {
      debugPrint("Error al eliminar el servicio: $e");
      rethrow; // Re-lanzamos el error para que la UI pueda mostrar un SnackBar si lo deseas
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double? odometroMinPermitido;
  double? odometroMaxPermitido;

  Future<void> calcularRangoOdometro({
    required int vehiculoId,
    required DateTime fecha,
  }) async {
    final rango = await _repository.obtenerRangoOdometroPorFecha(
      vehiculoId: vehiculoId,
      fecha: fecha,
    );

    odometroMinPermitido = rango['anterior'];
    odometroMaxPermitido = rango['siguiente'];

    notifyListeners();
  }
}
