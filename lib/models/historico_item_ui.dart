import 'movimiento_detalle.dart';

class MovimientoHistorico {
  final int idMovimiento;
  final String tipo;
  final DateTime fecha;
  final double odometro;
  final double total;
  final List<MovimientoDetalle> detalles;

  MovimientoHistorico({
    required this.idMovimiento,
    required this.tipo,
    required this.fecha,
    required this.odometro,
    required this.total,
    required this.detalles,
  });

  factory MovimientoHistorico.fromMovimiento(Map<String, dynamic> map) {
    return MovimientoHistorico(
      idMovimiento: map['id_movimiento'],
      tipo: map['tipo_movimiento'],
      fecha: DateTime.parse(map['fecha']),
      odometro: map['odometro'],
      total: map['total'],
      detalles: [],
    );
  }
}
