import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_gestion_vehicular/data/database_helper.dart';
import 'package:app_gestion_vehicular/models/vehiculo.dart';
import 'package:app_gestion_vehicular/ui/informes/informes_page.dart';
import 'package:app_gestion_vehicular/viewmodels/reporte_general_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/reporte_recarga_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/vehiculo_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _pestanas = ['GENERAL', 'RECARGA', 'GASTO', 'SERVICIO'];

Future<void> _sembrar(Database db, int vehiculo) async {
  final hoy = DateTime.now();
  final conceptosGasto = ['Peaje', 'Seguro de cobertura amplia', 'Multa'];
  final conceptosServicio = ['Cambio de aceite', 'Alineación y balanceo'];

  Future<void> mov(
    String tipo,
    DateTime fecha,
    double km,
    String concepto,
    double cantidad,
    double precio,
  ) async {
    final id = await db.insert('movimientos', {
      'id_vehiculo': vehiculo,
      'id_usuario': 1,
      'tipo_movimiento': tipo,
      'fecha': fecha.toIso8601String(),
      'odometro': km,
      'total': cantidad * precio,
    });
    await db.insert('movimiento_detalle', {
      'id_movimiento': id,
      'tipo_detalle': tipo,
      'descripcion': concepto,
      'cantidad': cantidad,
      'precio_unitario': precio,
      'subtotal': cantidad * precio,
      'tanque_lleno': 1,
    });
  }

  var km = 30000.0;
  for (var m = 10; m >= 0; m--) {
    if (m == 6) continue; // Un mes sin movimientos debe verse como hueco
    final base = DateTime(hoy.year, hoy.month - m, 1);
    await mov(
      'combustible',
      base,
      km += 480 + m * 17,
      'Gasolina Regular',
      38 + m % 4,
      23.5 + (10 - m) * 0.12,
    );
    if (m % 2 == 0) {
      await mov(
        'gasto',
        base.add(const Duration(hours: 5)),
        km += 20,
        conceptosGasto[m % 3],
        1,
        450.0 + m * 90,
      );
    }
    if (m % 3 == 0) {
      await mov(
        'servicio',
        base.add(const Duration(hours: 9)),
        km += 10,
        conceptosServicio[m % 2],
        1,
        1200.0 + m * 60,
      );
    }
  }
}

void main() {
  late VehiculoViewModel vehiculos;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('es');

    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('informes_page').path,
    );
    final db = await DatabaseHelper.instance.database;
    final conDatos = await db.insert('vehiculos', {'marca': 'A', 'modelo': 'B'});
    await db.insert('vehiculos', {'marca': 'Sin', 'modelo': 'Datos'});
    await _sembrar(db, conDatos);

    vehiculos = VehiculoViewModel();
  });

  Widget app() => MultiProvider(
    providers: [
      ChangeNotifierProvider<VehiculoViewModel>.value(value: vehiculos),
      ChangeNotifierProvider(create: (_) => ReporteGeneralViewModel()),
      ChangeNotifierProvider(create: (_) => ReporteRecargaViewModel()),
    ],
    child: const MaterialApp(home: InformesPage()),
  );

  // Las consultas usan SQLite real, que no avanza con el reloj falso del test
  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> seleccionar(int id) async {
    await vehiculos.seleccionarVehiculo(
      Vehiculo(
        idVehiculo: id,
        marca: 'V',
        modelo: 'M',
        anio: 2020,
        placas: '',
        vin: '',
        color: '',
        odometroInicial: 0,
        tamanioTanque: 40,
      ),
    );
  }

  // Ancho de iPhone: cualquier desbordamiento hace fallar el test
  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('todas las pestañas muestran datos reales sin desbordarse', (
    tester,
  ) async {
    telefono(tester);
    await tester.runAsync(() => seleccionar(1));

    await tester.pumpWidget(app());
    await asentar(tester);

    expect(find.text('¿En qué se va el dinero?'), findsOneWidget);
    expect(find.text('Recargas'), findsWidgets);

    await tester.tap(find.text('RECARGA'));
    await asentar(tester);
    expect(find.text('Precio por litro'), findsOneWidget);

    await tester.tap(find.text('GASTO'));
    await asentar(tester);
    expect(find.text('Por concepto'), findsOneWidget);
    expect(find.text('MXN0.00'), findsNothing);

    await tester.tap(find.text('SERVICIO'));
    await asentar(tester);
    expect(find.text('Cambio de aceite'), findsOneWidget);
    expect(find.text('Sin servicios en este periodo'), findsNothing);
  });

  testWidgets('cambiar el periodo recarga sin errores en todas las pestañas', (
    tester,
  ) async {
    telefono(tester);
    await tester.runAsync(() => seleccionar(1));

    await tester.pumpWidget(app());
    await asentar(tester);

    for (final periodo in ['Este mes', '3 meses', 'Todo']) {
      await tester.tap(find.text(periodo));
      await asentar(tester);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('un vehículo sin datos muestra mensajes, no errores', (
    tester,
  ) async {
    telefono(tester);
    await tester.runAsync(() => seleccionar(2));

    await tester.pumpWidget(app());
    await asentar(tester);
    expect(find.text('Sin movimientos en este periodo'), findsOneWidget);

    await tester.tap(find.text('RECARGA'));
    await asentar(tester);
    expect(find.text('Sin recargas en este periodo'), findsOneWidget);

    await tester.tap(find.text('GASTO'));
    await asentar(tester);
    expect(find.text('Sin gastos en este periodo'), findsOneWidget);
  });

  // Solo con CAPTURAS=<carpeta>: guarda cada pestaña como PNG para revisarla a ojo
  final capturas = Platform.environment['CAPTURAS'];
  testWidgets('capturas', skip: capturas == null, (tester) async {
    await tester.runAsync(() async {
      final fuente = await File(
        '/System/Library/Fonts/Supplemental/Arial.ttf',
      ).readAsBytes();
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(fuente)));
      await loader.load();
    });

    telefono(tester);
    await tester.runAsync(() => seleccionar(1));
    await tester.pumpWidget(
      RepaintBoundary(key: const Key('raiz'), child: app()),
    );
    await asentar(tester);

    for (final pestana in _pestanas) {
      await tester.tap(find.text(pestana));
      await asentar(tester);

      final limite =
          tester.renderObject(find.byKey(const Key('raiz')))
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final imagen = await limite.toImage(pixelRatio: 2);
        final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$capturas/$pestana.png',
        ).writeAsBytes(png!.buffer.asUint8List());
      });
    }
  });
}
