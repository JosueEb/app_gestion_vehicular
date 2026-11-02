import 'package:flutter/material.dart';
import '../models/historico_item_ui.dart';
import '../models/resumen_historico.dart';
import '../models/tramo_rendimiento.dart';
import '../repositories/historico_repository.dart';
import '../repositories/historico_repository_impl.dart';
import 'package:intl/intl.dart';

class HistoricoViewModel extends ChangeNotifier {
  final HistoricoRepository _repository = HistoricoRepositoryImpl();

  final List<MovimientoHistorico> _movimientos = [];
  List<MovimientoHistorico> get movimientos => _movimientos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _vehiculoCargado;

  /// null muestra todos los tipos
  String? _filtroTipo;
  String? get filtroTipo => _filtroTipo;

  ResumenHistorico get resumen => calcularResumen(_movimientos, DateTime.now());

  void cambiarFiltro(String? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  /// 🔥 AGRUPADO POR MES (ESTILO DRIVVO)
  Map<String, List<MovimientoHistorico>> get agrupadoPorMes {
    final Map<String, List<MovimientoHistorico>> map = {};

    for (final m in _movimientos) {
      if (_filtroTipo != null && m.tipo != _filtroTipo) continue;

      final key = DateFormat('MMMM yyyy', 'es').format(m.fecha).toUpperCase();

      map.putIfAbsent(key, () => []);
      map[key]!.add(m);
    }

    return map;
  }

  Future<void> cargarHistorico(int vehiculoId) async {
    // Al refrescar el mismo vehículo la lista se conserva para no perder el scroll
    _isLoading = _vehiculoCargado != vehiculoId;
    notifyListeners();

    try {
      final movimientos = await _repository.obtenerHistorico(
        vehiculoId: vehiculoId,
      );
      _movimientos
        ..clear()
        ..addAll(movimientos);
      _vehiculoCargado = vehiculoId;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, double>? obtenerEstadisticasCombustible(
    MovimientoHistorico actual,
    int tamanioTanque,
  ) {
    if (actual.tipo.toLowerCase() != 'combustible') return null;
    if (tamanioTanque <= 0) return null;

    // 1. Índice del movimiento actual
    final int index = _movimientos.indexOf(actual);

    if (index == -1) return null;

    // 2. Recargas SIGUIENTES (cronológicamente)
    final siguientes = [
      for (int i = index - 1; i >= 0; i--)
        if (_movimientos[i].tipo.toLowerCase() == 'combustible') _movimientos[i],
    ];

    // 3. Litros cargados en la recarga actual
    double litrosCargados = 0;
    bool tanqueLleno = false;

    if (actual.detalles.isNotEmpty) {
      litrosCargados = actual.detalles.first.cantidad;
      tanqueLleno = actual.detalles.first.tanqueLleno;
    }

    // 4. KM recorridos y rendimiento
    double kmRecorridos = 0;
    double rendimiento = 0;

    final tramo = calcularTramo(_tanque(actual), siguientes.map(_tanque));

    if (tramo != null) {
      kmRecorridos = tramo.km;
      rendimiento = tramo.rendimiento;
    } else if (siguientes.isNotEmpty && litrosCargados > 0) {
      kmRecorridos = siguientes.first.odometro - actual.odometro;
    }

    // 5. Porcentaje del tanque (después de la recarga)
    double porcentajeTanque;
    if (tanqueLleno) {
      porcentajeTanque = 100;
    } else {
      porcentajeTanque = (litrosCargados / tamanioTanque) * 100;
    }

    porcentajeTanque = porcentajeTanque.clamp(0, 100);

    return {
      'litros': litrosCargados,
      'kmRecorridos': kmRecorridos,
      'rendimiento': rendimiento,
      'porcentajeTanque': porcentajeTanque,
    };
  }

  RecargaTanque _tanque(MovimientoHistorico m) => RecargaTanque(
    odometro: m.odometro,
    litros: m.detalles.isNotEmpty ? m.detalles.first.cantidad : 0,
    costo: m.total,
    tanqueLleno: m.detalles.isNotEmpty && m.detalles.first.tanqueLleno,
  );

  Map<String, double>? obtenerEstadisticasDesdeMap(
    Map<String, dynamic> r,
    int tamanioTanque,
  ) {
    final odometroActual = (r['odometro'] as num?)?.toDouble();
    final odometroSiguiente = (r['odometro_siguiente'] as num?)?.toDouble();

    final litros = (r['cantidad'] as num?)?.toDouble();
    final total = (r['total'] as num?)?.toDouble();
    final tanqueLleno = (r['tanque_lleno'] ?? 0) == 1;

    if (odometroActual == null || litros == null || total == null) return null;
    if (litros <= 0 || tamanioTanque <= 0) return null;

    double kmRecorridos = 0;
    double rendimiento = 0;
    double costoPorKm = 0;

    final siguientes = (r['recargas_siguientes'] as List<Map<String, dynamic>>?) ?? [];
    final tramo = calcularTramo(
      RecargaTanque(
        odometro: odometroActual,
        litros: litros,
        costo: total,
        tanqueLleno: tanqueLleno,
      ),
      siguientes.map(RecargaTanque.fromMap),
    );

    if (tramo != null) {
      kmRecorridos = tramo.km;
      rendimiento = tramo.rendimiento;
      costoPorKm = tramo.costoPorKm;
    } else if (odometroSiguiente != null && odometroSiguiente > odometroActual) {
      kmRecorridos = odometroSiguiente - odometroActual;
    }

    // 🔥 Porcentaje del tanque
    double porcentajeTanque;
    if (tanqueLleno) {
      porcentajeTanque = 100;
    } else {
      porcentajeTanque = (litros / tamanioTanque) * 100;
    }

    porcentajeTanque = porcentajeTanque.clamp(0, 100);

    return {
      'litros': litros,
      'kmRecorridos': kmRecorridos,
      'rendimiento': rendimiento,
      'costoPorKm': costoPorKm,
      'porcentajeTanque': porcentajeTanque,
    };
  }
}
