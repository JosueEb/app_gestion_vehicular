/*combustible.dart*/
class Combustible {
  final int? idCombustible;
  final String nombre;

  Combustible({this.idCombustible, required this.nombre});

  Map<String, dynamic> toMap() => {
    'id_combustible': idCombustible,
    'nombre': nombre,
  };
  //FromMap
  factory Combustible.fromMap(Map<String, dynamic> map) => Combustible(
    idCombustible: map['id_combustible'],
    nombre: map['nombre'],
  );
}
