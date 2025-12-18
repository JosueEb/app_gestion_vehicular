import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../vehiculos/listado_vehiculo_page.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  // @override
  // void initState() {
  //   super.initState();

  //   // ⚠️ Importante: post-frame
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<VehiculoViewModel>().cargarVehiculos();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehiculoViewModel>();
    final vehiculo = vm.vehiculoActivo;

    if (vm.vehiculos.isEmpty) {
      return const Center(child: Text('No hay vehículos registrados'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListadoVehiculoPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      vehiculo != null
                          ? '${vehiculo.marca} ${vehiculo.modelo}'
                          : 'Selecciona un vehículo',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// resto del histórico
        const Expanded(child: Center(child: Text('Aquí va el histórico'))),
      ],
    );
  }
}
