class TipoServicio {
  final int? idTipoServicio;
  final String nombre;

  TipoServicio({this.idTipoServicio, required this.nombre});

  Map<String, dynamic> toMap() => {
        'id_tipo_servicio': idTipoServicio,
        'nombre': nombre,
      };

  //FromMap
  factory TipoServicio.fromMap(Map<String, dynamic> map) => TipoServicio(
        idTipoServicio: map['id_tipo_servicio'] as int?,
        nombre: map['nombre'] as String,
      );
}
