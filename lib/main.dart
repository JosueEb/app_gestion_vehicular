import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'viewmodels/vehiculo_viewmodel.dart';
import 'viewmodels/recarga_viewmodel.dart';
import 'viewmodels/combustible_viewmodel.dart';
import 'viewmodels/servicio_viewmodel.dart';
import 'viewmodels/servicio_movimiento_viewmodel.dart';
import 'viewmodels/historico_viewmodel.dart';

import 'ui/app_start_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecargaViewModel()),
        ChangeNotifierProvider(create: (_) => CombustibleViewModel()),
        ChangeNotifierProvider(create: (_) => ServicioViewModel()),
        ChangeNotifierProvider(create: (_) => ServicioMovimientoViewModel()),
        ChangeNotifierProvider(create: (_) => HistoricoViewModel()),
        /// Vehículo activo
        ChangeNotifierProvider(
          create: (_) {
            final vm = VehiculoViewModel();
            vm.obtenerVehiculoActivo();
            return vm;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppStartPage(),
    );
  }
}
