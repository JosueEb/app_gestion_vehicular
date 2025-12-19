import 'package:flutter/material.dart';
import '../models/historico_item_ui.dart';
import '../repositories/historico_repository.dart';
import '../repositories/historico_repository_impl.dart';
import 'package:intl/intl.dart';

class HistoricoViewModel extends ChangeNotifier {
  final HistoricoRepository _repository = HistoricoRepositoryImpl();

  final List<MovimientoHistorico> _movimientos = [];
  List<MovimientoHistorico> get movimientos => _movimientos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _itemExpandidoId;
  int? get itemExpandidoId => _itemExpandidoId;

  /// 🔥 AGRUPADO POR MES (ESTILO DRIVVO)
  Map<String, List<MovimientoHistorico>> get agrupadoPorMes {
    final Map<String, List<MovimientoHistorico>> map = {};

    for (final m in _movimientos) {
      final key = DateFormat('MMMM yyyy', 'es').format(m.fecha).toUpperCase();

      map.putIfAbsent(key, () => []);
      map[key]!.add(m);
    }

    return map;
  }

  Future<void> cargarHistorico(int vehiculoId) async {
    _isLoading = true;
    notifyListeners();

    _movimientos
      ..clear()
      ..addAll(await _repository.obtenerHistorico(vehiculoId: vehiculoId));

    _isLoading = false;
    notifyListeners();
  }

  void toggleExpansion(int id) {
    if (_itemExpandidoId == id) {
      _itemExpandidoId = null; // Si ya está abierto, se cierra
    } else {
      _itemExpandidoId = id; // Abre el nuevo y cierra el anterior
    }
    notifyListeners();
  }

  /// Función para calcular estadísticas de combustible
  Map<String, double>? obtenerEstadisticasCombustible(
    MovimientoHistorico actual,
    int tamanioTanque, // 👈 NUEVO
  ) {
    if (actual.tipo.toLowerCase() != 'combustible') return null;
    if (tamanioTanque <= 0) return null;

    // 1. Encontrar el índice del movimiento actual
    final int index = _movimientos.indexOf(actual);

    // 2. Buscar el registro de combustible ANTERIOR
    MovimientoHistorico? anterior;
    for (int i = index + 1; i < _movimientos.length; i++) {
      if (_movimientos[i].tipo.toLowerCase() == 'combustible') {
        anterior = _movimientos[i];
        break;
      }
    }

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

    if (anterior != null && litrosCargados > 0) {
      kmRecorridos = actual.odometro - anterior.odometro;
      if (kmRecorridos > 0) {
        rendimiento = kmRecorridos / litrosCargados;
      }
    }

    // 5. Porcentaje del tanque (DESPUÉS de la recarga)
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

  Map<String, double>? obtenerEstadisticasDesdeMap(
    Map<String, dynamic> r,
    int tamanioTanque, // 👈 NUEVO
  ) {
    final odometro = (r['odometro'] as num?)?.toDouble();
    final litros = (r['cantidad'] as num?)?.toDouble();
    final total = (r['total'] as num?)?.toDouble();
    final tanqueLleno = (r['tanque_lleno'] ?? 0) == 1;

    if (odometro == null || litros == null || total == null) return null;
    if (litros <= 0 || tamanioTanque <= 0) return null;

    final odometroAnterior = (r['odometro_anterior'] as num?)?.toDouble();

    double kmRecorridos = 0;
    double rendimiento = 0;
    double costoPorKm = 0;

    if (odometroAnterior != null && odometroAnterior > 0) {
      kmRecorridos = odometro - odometroAnterior;

      if (kmRecorridos > 0) {
        rendimiento = kmRecorridos / litros;
        costoPorKm = total / kmRecorridos;
      }
    }

    // 🔥 Porcentaje del tanque después de la recarga
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
