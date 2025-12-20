class TipoGasto {
  final int? idTipoGasto;
  final String nombre;

  TipoGasto({this.idTipoGasto, required this.nombre});

  Map<String, dynamic> toMap() => {
        'id_tipo_gasto': idTipoGasto,
        'nombre': nombre,
      };
  //from map
  factory TipoGasto.fromMap(Map<String, dynamic> map) => TipoGasto(
        idTipoGasto: map['id_tipo_gasto'],
        nombre: map['nombre'],
      );
}
