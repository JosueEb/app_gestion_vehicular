import 'package:app_gestion_vehicular/models/tramo_rendimiento.dart';
import 'package:flutter_test/flutter_test.dart';

RecargaTanque _r(double odometro, double litros, {bool lleno = true}) =>
    RecargaTanque(
      odometro: odometro,
      litros: litros,
      costo: litros * 20,
      tanqueLleno: lleno,
    );

void main() {
  test('usa los litros de la recarga que vuelve a llenar, no los de la actual', () {
    final tramo = calcularTramo(_r(1000, 40), [_r(1500, 50)]);

    expect(tramo!.km, 500);
    expect(tramo.rendimiento, 10);
    expect(tramo.costoPorKm, 1000 / 500);
  });

  test('suma las recargas parciales hasta volver a llenar', () {
    final tramo = calcularTramo(_r(1000, 40), [
      _r(1200, 15, lleno: false),
      _r(1500, 25),
      _r(2000, 99),
    ]);

    expect(tramo!.km, 500);
    expect(tramo.litros, 40);
    expect(tramo.rendimiento, 12.5);
  });

  test('una recarga parcial no tiene rendimiento propio', () {
    expect(calcularTramo(_r(1000, 15, lleno: false), [_r(1500, 50)]), isNull);
  });

  test('sin una recarga posterior que llene no hay rendimiento', () {
    expect(calcularTramo(_r(1000, 40), []), isNull);
    expect(calcularTramo(_r(1000, 40), [_r(1200, 15, lleno: false)]), isNull);
  });

  test('un odómetro que no avanza no produce rendimiento', () {
    expect(calcularTramo(_r(1000, 40), [_r(1000, 50)]), isNull);
  });
}
