class TipoServicio {
  final int? idTipoServicio;
  final String nombre;

  TipoServicio({this.idTipoServicio, required this.nombre});

  Map<String, dynamic> toMap() => {
        'id_tipo_servicio': idTipoServicio,
        'nombre': nombre,
      };
}
