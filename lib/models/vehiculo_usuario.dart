class VehiculoUsuario {
  final int? idVehiculoUsuario;
  final int idVehiculo;
  final int idUsuario;
  final String rol; // PROPIETARIO | CONDUCTOR

  VehiculoUsuario({
    this.idVehiculoUsuario,
    required this.idVehiculo,
    required this.idUsuario,
    required this.rol,
  });

  Map<String, dynamic> toMap() => {
        'id_vehiculo_usuario': idVehiculoUsuario,
        'id_vehiculo': idVehiculo,
        'id_usuario': idUsuario,
        'rol': rol,
      };
}
