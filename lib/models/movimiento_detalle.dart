class MovimientoDetalle {
  final int? idDetalle;
  final int? idMovimiento; // ⬅️ ahora opcional
  final String tipoDetalle;
  final int? idReferencia;
  final String? descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final bool tanqueLleno;


  MovimientoDetalle({
    this.idDetalle,
    this.idMovimiento,
    required this.tipoDetalle,
    this.idReferencia,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.tanqueLleno = false,
  });

  Map<String, dynamic> toMap() => {
    if (idDetalle != null) 'id_detalle': idDetalle,
    if (idMovimiento != null) 'id_movimiento': idMovimiento,
    'tipo_detalle': tipoDetalle,
    'id_referencia': idReferencia,
    'descripcion': descripcion,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'subtotal': subtotal,
    'tanque_lleno': tanqueLleno ? 1 : 0,
  };
  //fromMap
  factory MovimientoDetalle.fromMap(Map<String, dynamic> map) =>
      MovimientoDetalle(
        idDetalle: map['id_detalle'],
        idMovimiento: map['id_movimiento'],
        tipoDetalle: map['tipo_detalle'],
        idReferencia: map['id_referencia'],
        descripcion: map['descripcion'],
        cantidad: map['cantidad'],
        precioUnitario: map['precio_unitario'],
        subtotal: map['subtotal'],
        tanqueLleno: map['tanque_lleno'] == 0 ? false : true,
      );
}
