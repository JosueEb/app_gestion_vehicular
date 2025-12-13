class Movimiento {
  final int? idMovimiento;
  final int idVehiculo;
  final int idUsuario;
  final String tipoMovimiento;
  final DateTime fecha;
  final double odometro;
  final double total;
  final int? idMetodoPago;
  final String? observaciones;

  Movimiento({
    this.idMovimiento,
    required this.idVehiculo,
    required this.idUsuario,
    required this.tipoMovimiento,
    required this.fecha,
    required this.odometro,
    required this.total,
    this.idMetodoPago,
    this.observaciones,
  });

  Map<String, dynamic> toMap() => {
        'id_movimiento': idMovimiento,
        'id_vehiculo': idVehiculo,
        'id_usuario': idUsuario,
        'tipo_movimiento': tipoMovimiento,
        'fecha': fecha.toIso8601String(),
        'odometro': odometro,
        'total': total,
        'id_metodo_pago': idMetodoPago,
        'observaciones': observaciones,
      };
}
