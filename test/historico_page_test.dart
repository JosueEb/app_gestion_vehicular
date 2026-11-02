import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_gestion_vehicular/data/database_helper.dart';
import 'package:app_gestion_vehicular/models/movimiento_detalle.dart';
import 'package:app_gestion_vehicular/ui/historico/historico_page.dart';
import 'package:app_gestion_vehicular/viewmodels/gasto_movimiento_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/historico_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/recarga_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/servicio_movimiento_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/vehiculo_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final vehiculos = VehiculoViewModel();
  final recargas = RecargaViewModel();
  final gastos = GastoMovimientoViewmodel();
  final servicios = ServicioMovimientoViewModel();
  final hoy = DateTime.now();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('historico_page').path,
    );
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('es');

    final db = await DatabaseHelper.instance.database;
    await db.insert('vehiculos', {
      'marca': 'KIA',
      'modelo': 'RIO',
      'anio': 2021,
      'placas': 'ABC-123',
      'tamanio_tanque': 45,
    });
    await vehiculos.cargarVehiculos();
  });

  Widget app() => MultiProvider(
    providers: [
      ChangeNotifierProvider<VehiculoViewModel>.value(value: vehiculos),
      ChangeNotifierProvider(create: (_) => HistoricoViewModel()),
      ChangeNotifierProvider<RecargaViewModel>.value(value: recargas),
      ChangeNotifierProvider<GastoMovimientoViewmodel>.value(value: gastos),
      ChangeNotifierProvider<ServicioMovimientoViewModel>.value(value: servicios),
    ],
    child: const MaterialApp(home: Scaffold(body: HistoricoPage())),
  );

  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> registrarRecarga(DateTime fecha, double km, double litros) =>
      recargas.registrarRecarga(
        vehiculoId: 1,
        fecha: fecha,
        litros: litros,
        precioUnitario: 24,
        odometro: km,
        idCombustible: 1,
        observaciones: '',
        tanqueLleno: true,
        descripcion: 'Gasolina Regular',
      );

  Future<void> registrarGasto(DateTime fecha, double km, List<String> conceptos) =>
      gastos.resgistrarGasto(
        vehiculoId: 1,
        fecha: fecha,
        odometro: km,
        detalles: [
          for (final c in conceptos)
            MovimientoDetalle(
              tipoDetalle: 'gasto',
              descripcion: c,
              cantidad: 1,
              precioUnitario: 350,
              subtotal: 350,
            ),
        ],
      );

  testWidgets('sin registros orienta al usuario', (tester) async {
    telefono(tester);
    await tester.pumpWidget(app());
    await asentar(tester);

    expect(find.text('Aún no hay registros'), findsOneWidget);
    expect(find.text('KIA RIO'), findsOneWidget);
  });

  testWidgets('lo registrado aparece en el inicio sin volver a abrirlo', (
    tester,
  ) async {
    telefono(tester);
    await tester.pumpWidget(app());
    await asentar(tester);

    await tester.runAsync(
      () => registrarRecarga(hoy.subtract(const Duration(days: 40)), 30000, 40),
    );
    await asentar(tester);
    expect(find.text('Gasolina Regular'), findsOneWidget);

    await tester.runAsync(
      () => registrarGasto(hoy.subtract(const Duration(hours: 1)), 30400, [
        'Peaje',
        'Multa',
      ]),
    );
    await asentar(tester);
    expect(find.text('Peaje +1'), findsOneWidget);
  });

  testWidgets('filtra por tipo y elimina desde el menú', (tester) async {
    telefono(tester);
    await tester.pumpWidget(app());
    await asentar(tester);

    await tester.tap(find.text('Gastos'));
    await asentar(tester);
    expect(find.text('Peaje +1'), findsOneWidget);
    expect(find.text('Gasolina Regular'), findsNothing);

    // La fila de filtros se desplaza: en la fuente de prueba este chip queda fuera
    await tester.ensureVisible(find.text('Servicios'));
    await tester.pump();
    await tester.tap(find.text('Servicios'));
    await asentar(tester);
    expect(find.text('Nada de este tipo todavía'), findsOneWidget);

    await tester.ensureVisible(find.text('Todos'));
    await tester.pump();
    await tester.tap(find.text('Todos'));
    await asentar(tester);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ELIMINAR'));
    await asentar(tester);

    expect(find.text('Peaje +1'), findsNothing);
    expect(find.text('Gasolina Regular'), findsOneWidget);
  });

  // Solo con CAPTURAS=<carpeta>: guarda el inicio como PNG para revisarlo a ojo
  final capturas = Platform.environment['CAPTURAS'];
  testWidgets('captura', skip: capturas == null, (tester) async {
    await tester.runAsync(() async {
      final fuente = await File(
        '/System/Library/Fonts/Supplemental/Arial.ttf',
      ).readAsBytes();
      await (FontLoader('Roboto')
            ..addFont(Future.value(ByteData.sublistView(fuente))))
          .load();

      await registrarRecarga(hoy.subtract(const Duration(days: 20)), 30500, 42);
      await registrarRecarga(hoy.subtract(const Duration(hours: 3)), 31020, 38);
      await registrarGasto(hoy.subtract(const Duration(days: 62)), 29600, [
        'Seguro de cobertura amplia',
      ]);
    });

    telefono(tester);
    await tester.pumpWidget(RepaintBoundary(key: const Key('raiz'), child: app()));
    await asentar(tester);

    final limite =
        tester.renderObject(find.byKey(const Key('raiz')))
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final imagen = await limite.toImage(pixelRatio: 2);
      final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
      await File('$capturas/INICIO.png').writeAsBytes(png!.buffer.asUint8List());
    });
  });
}
