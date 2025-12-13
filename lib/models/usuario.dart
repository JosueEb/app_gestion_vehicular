class Usuario {
  final int? idUsuario;
  final String nombre;
  final String email;
  final String passwordHash;
  final String? telefono;
  final DateTime? fechaRegistro;
  final bool activo;

  Usuario({
    this.idUsuario,
    required this.nombre,
    required this.email,
    required this.passwordHash,
    this.telefono,
    this.fechaRegistro,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'email': email,
      'password_hash': passwordHash,
      'telefono': telefono,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }
}
