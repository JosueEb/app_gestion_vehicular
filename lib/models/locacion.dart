class Locacion {
  final int? idLocacion;
  final String pais;
  final String estado;
  final String ciudad;
  final String direccion;
  final double? latitud;
  final double? longitud;

  Locacion({
    this.idLocacion,
    required this.pais,
    required this.estado,
    required this.ciudad,
    required this.direccion,
    this.latitud,
    this.longitud,
  });

  Map<String, dynamic> toMap() => {
        'id_locacion': idLocacion,
        'pais': pais,
        'estado': estado,
        'ciudad': ciudad,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
      };
}
