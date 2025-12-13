class MovimientoRuta {
  final int idMovimiento;
  final double kmRecorridos;
  final int? tiempoMinutos;
  final String? origen;
  final String? destino;

  MovimientoRuta({
    required this.idMovimiento,
    required this.kmRecorridos,
    this.tiempoMinutos,
    this.origen,
    this.destino,
  });

  Map<String, dynamic> toMap() => {
        'id_movimiento': idMovimiento,
        'km_recorridos': kmRecorridos,
        'tiempo_minutos': tiempoMinutos,
        'origen': origen,
        'destino': destino,
      };
}
