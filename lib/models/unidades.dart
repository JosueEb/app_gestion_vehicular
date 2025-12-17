class Unidades {
  final int? idUnidad;
  final String nombre;

  Unidades({this.idUnidad, required this.nombre});

  Map<String, dynamic> toMap() => {
    'id_unidad': idUnidad,
    'nombre': nombre,
  };

  //From Map
  factory Unidades.fromMap(Map<String, dynamic> map) {
    return Unidades(
      idUnidad: map['id_unidad']?.toInt(),
      nombre: map['nombre'] ?? '',
    );
  }
}
