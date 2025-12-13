class Vehiculo {
  final int? idVehiculo;
  final String marca;
  final String modelo;
  final int anio;
  final String placas;
  final String? vin;
  final String? color;
  final double odometroInicial;
  final bool activo;

  Vehiculo({
    this.idVehiculo,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placas,
    this.vin,
    this.color,
    this.odometroInicial = 0,
    this.activo = true,
  });

  Map<String, dynamic> toMap() => {
        'id_vehiculo': idVehiculo,
        'marca': marca,
        'modelo': modelo,
        'anio': anio,
        'placas': placas,
        'vin': vin,
        'color': color,
        'odometro_inicial': odometroInicial,
        'activo': activo ? 1 : 0,
      };

  factory Vehiculo.fromMap(Map<String, dynamic> map) => Vehiculo(
        idVehiculo: map['id_vehiculo'],
        marca: map['marca'],
        modelo: map['modelo'],
        anio: map['anio'],
        placas: map['placas'],
        vin: map['vin'],
        color: map['color'],
        odometroInicial: map['odometro_inicial']?.toDouble() ?? 0,
        activo: (map['activo'] ?? 1) == 1,
      );
}
