import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/vehiculo_viewmodel.dart';
import 'home/home_page.dart';
import 'vehiculos/add_vehiculo_page.dart';

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  bool _isLoading = true;
  bool _tieneVehiculos = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final vm = context.read<VehiculoViewModel>();
    await vm.cargarVehiculos();

    setState(() {
      _tieneVehiculos = vm.vehiculos.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _tieneVehiculos
        ? const HomePage()
        : const AddVehiculoPage(isFirst: true);
  }
}
