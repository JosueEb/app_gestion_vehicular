import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/vehiculo_viewmodel.dart';
import 'ui/app_start_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_){
          final vm = VehiculoViewModel();
          vm.obtenerVehiculoActivo();
          return vm;
        }),
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
      home: AppStartPage(),
    );
  }
}
