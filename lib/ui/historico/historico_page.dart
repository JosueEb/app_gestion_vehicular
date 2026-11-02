import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/vehiculo.dart';
import '../../services/movimientos_events.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../viewmodels/historico_viewmodel.dart';
import '../informes/widgets/componentes_reporte.dart';
import '../shared/app_colors.dart';
import '../shared/movimiento_estilo.dart';
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
    MovimientosEvents.cambios.addListener(_recargar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recargar());
  }

  @override
  void dispose() {
    MovimientosEvents.cambios.removeListener(_recargar);
    super.dispose();
  }

  Future<void> _recargar() async {
    if (!mounted) return;

    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    if (vehiculo != null) {
      await context.read<HistoricoViewModel>().cargarHistorico(
        vehiculo.idVehiculo!,
      );
    }
  }

  Future<void> _cambiarVehiculo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ListadoVehiculoPage()),
    );
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final vehiculo = vehiculoVM.vehiculoActivo;

    if (vehiculoVM.vehiculos.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay vehículos registrados')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HistoricoTimeline(
        onRefresh: _recargar,
        encabezado: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TarjetaVehiculo(vehiculo: vehiculo, onTap: _cambiarVehiculo),
            const SizedBox(height: 12),
            const _FiltroTipos(),
          ],
        ),
      ),
    );
  }
}

class _TarjetaVehiculo extends StatelessWidget {
  final Vehiculo? vehiculo;
  final VoidCallback onTap;

  const _TarjetaVehiculo({required this.vehiculo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final resumen = context.watch<HistoricoViewModel>().resumen;
    final rendimiento = resumen.ultimoRendimiento;
    final odometro = resumen.odometroActual;

    final datos = [
      if (vehiculo != null) '${vehiculo!.anio}',
      if (vehiculo != null && vehiculo!.placas.isNotEmpty) vehiculo!.placas,
      if (odometro != null) '${NumberFormat('#,##0').format(odometro)} km',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          /// SELECTOR DE VEHÍCULO
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.headerBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehiculo != null
                              ? '${vehiculo!.marca} ${vehiculo!.modelo}'
                              : 'Selecciona un vehículo',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (datos.isNotEmpty)
                          Text(
                            datos.join(' · '),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more,
                    color: AppColors.textSecondary,
                    semanticLabel: 'Cambiar vehículo',
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          /// RESUMEN DEL MES
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TripleStatsRow(
              labels: const ['Gastado este mes', 'Km este mes', 'Rendimiento'],
              values: [
                formatoMoneda.format(resumen.gastoMes),
                '${NumberFormat('#,##0').format(resumen.kmMes)} km',
                rendimiento != null
                    ? '${rendimiento.toStringAsFixed(1)} km/L'
                    : '--',
              ],
              isMini: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroTipos extends StatelessWidget {
  const _FiltroTipos();

  static const _opciones = [
    (null, 'Todos'),
    ('combustible', 'Recargas'),
    ('gasto', 'Gastos'),
    ('servicio', 'Servicios'),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoricoViewModel>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (tipo, etiqueta) in _opciones)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(etiqueta),
                selected: vm.filtroTipo == tipo,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => vm.cambiarFiltro(tipo),
              ),
            ),
        ],
      ),
    );
  }
}
