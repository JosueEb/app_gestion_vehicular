class Recordatorio {
  final int? idRecordatorio;
  final int idVehiculo;
  final String tipoRecordatorio;
  final DateTime? fechaProgramada;
  final double? odometroObjetivo;
  final bool notificado;

  Recordatorio({
    this.idRecordatorio,
    required this.idVehiculo,
    required this.tipoRecordatorio,
    this.fechaProgramada,
    this.odometroObjetivo,
    this.notificado = false,
  });

  Map<String, dynamic> toMap() => {
        'id_recordatorio': idRecordatorio,
        'id_vehiculo': idVehiculo,
        'tipo_recordatorio': tipoRecordatorio,
        'fecha_programada': fechaProgramada?.toIso8601String(),
        'odometro_objetivo': odometroObjetivo,
        'notificado': notificado ? 1 : 0,
      };
}
