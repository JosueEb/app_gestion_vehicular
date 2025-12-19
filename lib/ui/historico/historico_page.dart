import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../viewmodels/historico_viewmodel.dart';
import '../vehiculos/listado_vehiculo_page.dart';
import 'widgets/historico_timeline.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;

      if (vehiculo != null) {
        context.read<HistoricoViewModel>().cargarHistorico(
          vehiculo.idVehiculo!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final historicoVM = context.watch<HistoricoViewModel>();
    final vehiculo = vehiculoVM.vehiculoActivo;

    if (vehiculoVM.vehiculos.isEmpty) {
      return const Center(child: Text('No hay vehículos registrados'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        /// SELECTOR DE VEHÍCULO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListadoVehiculoPage()),
              );

              if (!mounted) return;

              final nuevoVehiculo = context
                  .read<VehiculoViewModel>()
                  .vehiculoActivo;

              if (nuevoVehiculo != null) {
                context.read<HistoricoViewModel>().cargarHistorico(
                  nuevoVehiculo.idVehiculo!,
                );
              }
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
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// HISTÓRICO
        Expanded(
          child: Builder(
            builder: (_) {
              if (historicoVM.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (historicoVM.movimientos.isEmpty) {
                return const Center(child: Text('Sin registros'));
              }

              return HistoricoTimeline(data: historicoVM.agrupadoPorMes);
            },
          ),
        ),
      ],
    );
  }
}
