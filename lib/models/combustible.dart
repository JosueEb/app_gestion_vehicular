class Combustible {
  final int? idCombustible;
  final String nombre;

  Combustible({this.idCombustible, required this.nombre});

  Map<String, dynamic> toMap() => {
    'id_combustible': idCombustible,
    'nombre': nombre,
  };
}
