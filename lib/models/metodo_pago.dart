class MetodoPago {
  final int? idMetodoPago;
  final String nombre;

  MetodoPago({this.idMetodoPago, required this.nombre});

  Map<String, dynamic> toMap() => {
        'id_metodo_pago': idMetodoPago,
        'nombre': nombre,
      };
}
