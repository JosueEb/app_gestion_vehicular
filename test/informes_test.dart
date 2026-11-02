import 'dart:io';

import 'package:app_gestion_vehicular/data/database_helper.dart';
import 'package:app_gestion_vehicular/models/gasto_mensual.dart';
import 'package:app_gestion_vehicular/models/periodo_informe.dart';
import 'package:app_gestion_vehicular/repositories/recarga_repository_impl.dart';
import 'package:app_gestion_vehicular/repositories/recordatorio_repository_imp.dart';
import 'package:app_gestion_vehicular/repositories/reporte_recarga_repository_imp.dart';
import 'package:app_gestion_vehicular/repositories/reporte_repository_impl.dart';
import 'package:app_gestion_vehicular/ui/informes/widgets/graficas_reporte.dart';
import 'package:app_gestion_vehicular/viewmodels/historico_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<int> _movimiento(
  Database db, {
  required String tipo,
  required DateTime fecha,
  required double odometro,
  required List<(String, double, double, bool)> detalles,
  int vehiculo = 1,
}) async {
  final id = await db.insert('movimientos', {
    'id_vehiculo': vehiculo,
    'id_usuario': 1,
    'tipo_movimiento': tipo,
    'fecha': fecha.toIso8601String(),
    'odometro': odometro,
    'total': detalles.fold<double>(0, (s, d) => s + d.$2 * d.$3),
  });
  for (final (descripcion, cantidad, precio, lleno) in detalles) {
    await db.insert('movimiento_detalle', {
      'id_movimiento': id,
      'tipo_detalle': tipo,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precio_unitario': precio,
      'subtotal': cantidad * precio,
      'tanque_lleno': lleno ? 1 : 0,
    });
  }
  return id;
}

void main() {
  final repo = ReporteRepositoryImpl();
  final repoRecarga = ReporteRecargaRepositoryImpl();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('informes').path,
    );

    final db = await DatabaseHelper.instance.database;
    for (final id in [1, 2]) {
      await db.insert('vehiculos', {'id_vehiculo': id, 'marca': 'V$id'});
    }

    await _movimiento(
      db,
      tipo: 'combustible',
      fecha: DateTime(2026, 1, 10),
      odometro: 1000,
      detalles: [('Regular', 40, 25, true)],
    );
    await _movimiento(
      db,
      tipo: 'gasto',
      fecha: DateTime(2026, 1, 20),
      odometro: 1200,
      // Dos conceptos en un solo movimiento: su total no debe contarse dos veces
      detalles: [('Peaje', 1, 100, false), ('Multa', 1, 300, false)],
    );
    await _movimiento(
      db,
      tipo: 'combustible',
      fecha: DateTime(2026, 3, 10),
      odometro: 1500,
      detalles: [('Regular', 50, 26, true)],
    );
    await _movimiento(
      db,
      tipo: 'gasto',
      fecha: DateTime(2026, 3, 15),
      odometro: 1600,
      detalles: [('Peaje', 1, 50, false)],
    );
    await _movimiento(
      db,
      tipo: 'servicio',
      fecha: DateTime(2025, 6, 1),
      odometro: 500,
      detalles: [('Lavado', 1, 999, false)],
      vehiculo: 2,
    );
  });

  test('un gasto con varios conceptos no duplica su total', () async {
    final porTipo = await repo.obtenerGastosPorTipo(vehiculoId: 1);
    final totales = {for (final t in porTipo) t.tipo: t.total};

    expect(totales, {'combustible': 2300.0, 'gasto': 450.0});
  });

  test('el informe de gastos desglosa por concepto y usa km de todo el vehículo', () async {
    final r = await repo.obtenerReporteMovimiento(
      vehiculoId: 1,
      tipoMovimiento: 'gasto',
    );

    expect(r!.totalEntradas, 2);
    expect(r.costoTotal, 450);
    expect(r.costoPorKm, 450 / 600);
    expect(r.conceptos.map((c) => (c.tipo, c.total)), [
      ('Multa', 300.0),
      ('Peaje', 150.0),
    ]);
    expect(r.mensual.map((m) => m.gasto), [400.0, 50.0]);
    expect(r.mensual.every((m) => m.recarga == 0), isTrue);
  });

  test('sin entradas el informe por tipo es null', () async {
    final r = await repo.obtenerReporteMovimiento(
      vehiculoId: 1,
      tipoMovimiento: 'servicio',
    );

    expect(r, isNull);
  });

  test('el filtro de fechas aplica a todos los informes', () async {
    final desde = DateTime(2026, 3);
    final hasta = DateTime(2026, 3, 31, 23, 59);

    final general = await repo.obtenerReporteGeneral(
      vehiculoId: 1,
      desde: desde,
      hasta: hasta,
    );
    final odometro = await repo.obtenerOdometro(
      vehiculoId: 1,
      desde: desde,
      hasta: hasta,
    );
    final recarga = await repoRecarga.obtenerReporteRecarga(
      vehiculoId: 1,
      desde: desde,
      hasta: hasta,
    );

    expect(general.totalEntradas, 2);
    expect(odometro.map((p) => p.odometro), [1500.0, 1600.0]);
    expect(recarga!.totalEntradas, 1);
    expect(recarga.costoTotal, 1300);
    expect(recarga.litrosTotales, 50);
  });

  test('el informe de recargas ordena sus puntos y calcula rendimiento', () async {
    final r = await repoRecarga.obtenerReporteRecarga(vehiculoId: 1);

    expect(r!.puntos.map((p) => p.precioLitro), [25.0, 26.0]);
    // 500 km entre tanques llenos, repuestos con los 50 L de la recarga siguiente
    expect(r.puntos.first.rendimiento, 500 / 50);
    expect(r.rendimientoPromedio, 500 / 50);
    expect(r.puntos.last.rendimiento, isNull);
    expect(r.precioPromedioLitro, 2300 / 90);
  });

  test('un tramo del periodo se cierra con una recarga posterior', () async {
    final r = await repoRecarga.obtenerReporteRecarga(
      vehiculoId: 1,
      desde: DateTime(2026, 1),
      hasta: DateTime(2026, 1, 31),
    );

    expect(r!.totalEntradas, 1);
    expect(r.puntos.single.rendimiento, 500 / 50);
    expect(r.eficienciaUltima, 500 / 50);
  });

  test('Histórico y detalle de recarga muestran el mismo rendimiento', () async {
    final vm = HistoricoViewModel();
    await vm.cargarHistorico(1);
    final recargas = vm.movimientos.where((m) => m.tipo == 'combustible');
    final primera = recargas.last;
    final ultima = recargas.first;

    final enLista = vm.obtenerEstadisticasCombustible(primera, 50)!;
    final mapa = await RecargaRepositoryImpl().obtenerRecargaPorId(
      primera.idMovimiento,
    );
    final enDetalle = vm.obtenerEstadisticasDesdeMap(mapa!, 50)!;

    expect(enLista['rendimiento'], 500 / 50);
    expect(enLista['kmRecorridos'], 500);
    expect(enDetalle['rendimiento'], 500 / 50);
    expect(enDetalle['kmRecorridos'], 500);
    expect(enDetalle['costoPorKm'], 1300 / 500);

    // La recarga más reciente aún no tiene un tramo cerrado
    expect(vm.obtenerEstadisticasCombustible(ultima, 50)!['rendimiento'], 0);
  });

  test('un periodo sin recargas devuelve null en vez de fallar', () async {
    final r = await repoRecarga.obtenerReporteRecarga(
      vehiculoId: 1,
      desde: DateTime(2020),
      hasta: DateTime(2020, 2),
    );

    expect(r, isNull);
  });

  test('la consulta de recordatorios pendientes es válida', () async {
    final pendientes = await RecordatorioRepositoryImpl()
        .obtenerPendientesPorVehiculo(1);

    expect(pendientes, isEmpty);
  });

  test('completarMeses rellena huecos y cruza de año', () {
    final meses = completarMeses([
      GastoMensual(anio: 2025, mes: 11, gasto: 10),
      GastoMensual(anio: 2026, mes: 2, gasto: 20),
    ]);

    expect(meses.map((m) => (m.anio, m.mes, m.gasto)), [
      (2025, 11, 10.0),
      (2025, 12, 0.0),
      (2026, 1, 0.0),
      (2026, 2, 20.0),
    ]);
  });

  test('completarMeses puede conservar solo los últimos meses', () {
    final gastos = [
      GastoMensual(anio: 2024, mes: 1, gasto: 1),
      GastoMensual(anio: 2026, mes: 3, gasto: 2),
    ];
    final meses = completarMeses(gastos, ultimos: 12);

    expect(completarMeses(gastos).length, 27);
    expect(meses.length, 12);
    expect((meses.first.anio, meses.first.mes), (2025, 4));
    expect((meses.last.anio, meses.last.mes), (2026, 3));
  });

  test('intervaloEje da pasos redondos', () {
    expect(intervaloEje(0), 1);
    expect(intervaloEje(3200), 1000);
    expect(intervaloEje(45), 20);
    expect(intervaloEje(90), 50);
  });

  test('los periodos arrancan el primer día del mes y cruzan de año', () {
    final hoy = DateTime(2026, 2, 15, 10);

    expect(PeriodoInforme.mes.desde(hoy), DateTime(2026, 2));
    expect(PeriodoInforme.tresMeses.desde(hoy), DateTime(2025, 12));
    expect(PeriodoInforme.anio.desde(hoy), DateTime(2025, 3));
    expect(PeriodoInforme.todo.desde(hoy), isNull);
    expect(PeriodoInforme.todo.hasta(hoy), isNull);
  });
}
