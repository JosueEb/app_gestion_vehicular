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

  /// 🔥 AGRUPADO POR MES (ESTILO DRIVVO)
  Map<String, List<MovimientoHistorico>> get agrupadoPorMes {
    final Map<String, List<MovimientoHistorico>> map = {};

    for (final m in _movimientos) {
      final key = DateFormat('MMMM yyyy', 'es')
          .format(m.fecha)
          .toUpperCase();

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
      ..addAll(
        await _repository.obtenerHistorico(
          vehiculoId: vehiculoId,
        ),
      );

    _isLoading = false;
    notifyListeners();
  }
}
