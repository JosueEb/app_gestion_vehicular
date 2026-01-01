class GastoMensual {
  final int anio;
  final int mes;
  double recarga;
  double gasto;
  double servicio;

  GastoMensual({
    required this.anio,
    required this.mes,
    this.recarga = 0,
    this.gasto = 0,
    this.servicio = 0,
  });
}
