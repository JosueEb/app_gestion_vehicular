class Recordatorio {
  final int? idRecordatorio;
  final int idVehiculo;
  final String tipoRecordatorio;
  final int? idReferencia;
  final String frecuencia;

  final bool porKm;
  final double? kmObjetivo;
  final double? kmIntervalo;

  final bool porFecha;
  final DateTime? fechaObjetivo;
  final int? fechaIntervalo;

  final String? notas;
  final bool activo;
  final bool notificado;
  final DateTime? fechaNotificacion;
  final DateTime createdAt;

  Recordatorio({
    this.idRecordatorio,
    required this.idVehiculo,
    required this.tipoRecordatorio,
    this.idReferencia,
    required this.frecuencia,
    this.porKm = false,
    this.kmObjetivo,
    this.kmIntervalo,
    this.porFecha = false,
    this.fechaObjetivo,
    this.fechaIntervalo,
    this.notas,
    this.activo = true,
    this.notificado = false,
    this.fechaNotificacion,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id_recordatorio': idRecordatorio,
        'id_vehiculo': idVehiculo,
        'tipo_recordatorio': tipoRecordatorio,
        'id_referencia': idReferencia,
        'frecuencia': frecuencia,
        'por_km': porKm ? 1 : 0,
        'km_objetivo': kmObjetivo,
        'km_intervalo': kmIntervalo,
        'por_fecha': porFecha ? 1 : 0,
        'fecha_objetivo': fechaObjetivo?.toIso8601String(),
        'fecha_intervalo': fechaIntervalo,
        'notas': notas,
        'activo': activo ? 1 : 0,
        'notificado': notificado ? 1 : 0,
        'fecha_notificacion': fechaNotificacion?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      idRecordatorio: map['id_recordatorio'],
      idVehiculo: map['id_vehiculo'],
      tipoRecordatorio: map['tipo_recordatorio'],
      idReferencia: map['id_referencia'],
      frecuencia: map['frecuencia'],
      porKm: map['por_km'] == 1,
      kmObjetivo: map['km_objetivo']?.toDouble(),
      kmIntervalo: map['km_intervalo']?.toDouble(),
      porFecha: map['por_fecha'] == 1,
      fechaObjetivo: map['fecha_objetivo'] != null
          ? DateTime.parse(map['fecha_objetivo'])
          : null,
      fechaIntervalo: map['fecha_intervalo'],
      notas: map['notas'],
      activo: map['activo'] == 1,
      notificado: map['notificado'] == 1,
      fechaNotificacion: map['fecha_notificacion'] != null
          ? DateTime.parse(map['fecha_notificacion'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
