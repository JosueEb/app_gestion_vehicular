class TipoIngreso {
  final int? idTipoIngreso;
  final String nombre;

  TipoIngreso({this.idTipoIngreso, required this.nombre});

  Map<String, dynamic> toMap() => {
        'id_tipo_ingreso': idTipoIngreso,
        'nombre': nombre,
      };
}
