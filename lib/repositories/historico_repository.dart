import '../models/historico_item_ui.dart';

abstract class HistoricoRepository {
  Future<List<MovimientoHistorico>> obtenerHistorico({required int vehiculoId,});
}

