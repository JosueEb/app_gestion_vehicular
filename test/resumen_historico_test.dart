import 'package:app_gestion_vehicular/models/historico_item_ui.dart';
import 'package:app_gestion_vehicular/models/movimiento_detalle.dart';
import 'package:app_gestion_vehicular/models/resumen_historico.dart';
import 'package:flutter_test/flutter_test.dart';

MovimientoHistorico _mov(
  String tipo,
  DateTime fecha,
  double odometro,
  double total, {
  double litros = 0,
  bool lleno = true,
}) => MovimientoHistorico(
  idMovimiento: odometro.toInt(),
  tipo: tipo,
  fecha: fecha,
  odometro: odometro,
  total: total,
  detalles: [
    if (tipo == 'combustible')
      MovimientoDetalle(
        tipoDetalle: tipo,
        cantidad: litros,
        precioUnitario: 20,
        subtotal: total,
        tanqueLleno: lleno,
      ),
  ],
);

void main() {
  final ahora = DateTime(2026, 3, 15);

  test('sin movimientos el resumen queda en cero', () {
    final r = calcularResumen([], ahora);

    expect(r.gastoMes, 0);
    expect(r.kmMes, 0);
    expect(r.odometroActual, isNull);
    expect(r.ultimoRendimiento, isNull);
  });

  test('el gasto solo cuenta el mes actual y los km parten del último registro previo', () {
    final r = calcularResumen([
      _mov('gasto', DateTime(2026, 2, 20), 1000, 500),
      _mov('gasto', DateTime(2026, 3, 1), 1200, 100),
      _mov('servicio', DateTime(2026, 3, 31, 23), 1500, 50),
      _mov('gasto', DateTime(2026, 4, 1), 1600, 999),
    ], ahora);

    expect(r.gastoMes, 150);
    expect(r.kmMes, 500);
    expect(r.odometroActual, 1600);
  });

  test('sin historial previo los km se miden dentro del mes', () {
    final r = calcularResumen([
      _mov('gasto', DateTime(2026, 3, 1), 1200, 100),
      _mov('gasto', DateTime(2026, 3, 9), 1450, 100),
    ], ahora);

    expect(r.kmMes, 250);
  });

  test('sin movimientos este mes no hay gasto ni km', () {
    final r = calcularResumen([
      _mov('gasto', DateTime(2026, 2, 20), 1000, 500),
    ], ahora);

    expect(r.gastoMes, 0);
    expect(r.kmMes, 0);
    expect(r.odometroActual, 1000);
  });

  test('el rendimiento es el del último tramo cerrado, sin importar el orden', () {
    final r = calcularResumen([
      _mov('combustible', DateTime(2026, 3, 10), 2000, 800, litros: 40),
      _mov('combustible', DateTime(2026, 1, 1), 1000, 800, litros: 40),
      _mov('combustible', DateTime(2026, 2, 1), 1500, 800, litros: 50),
    ], ahora);

    expect(r.ultimoRendimiento, 500 / 40);
  });
}
