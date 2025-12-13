class MovimientoDetalle {
  final int? idDetalle;
  final int idMovimiento;
  final String tipoDetalle;
  final int? idReferencia;
  final String? descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  MovimientoDetalle({
    this.idDetalle,
    required this.idMovimiento,
    required this.tipoDetalle,
    this.idReferencia,
    this.descripcion,
    this.cantidad = 1,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'id_detalle': idDetalle,
        'id_movimiento': idMovimiento,
        'tipo_detalle': tipoDetalle,
        'id_referencia': idReferencia,
        'descripcion': descripcion,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
        'subtotal': subtotal,
      };
}
