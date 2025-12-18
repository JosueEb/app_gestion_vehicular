/*listado_vehiculo_page.dart*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../../models/vehiculo.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../vehiculos/add_vehiculo_page.dart';

class ListadoVehiculoPage extends StatelessWidget {
  const ListadoVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehiculoViewModel>();
    final vehiculoActivo = vm.vehiculoActivo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        backgroundColor: const Color.fromARGB(255, 196, 236, 255),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddVehiculoPage()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      body: vm.vehiculos.isEmpty
          ? const Center(child: Text('No hay vehículos registrados'))
          : ListView.separated(
              itemCount: vm.vehiculos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final vehiculo = vm.vehiculos[index];
                final isActivo =
                    vehiculoActivo?.idVehiculo == vehiculo.idVehiculo;

                return ListTile(
                  title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
                  subtitle: Text('Placas: ${vehiculo.placas}'),
                  trailing: isActivo
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await vm.seleccionarVehiculo(vehiculo);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
    );
  }
}
