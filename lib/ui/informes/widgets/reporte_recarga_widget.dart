import 'package:app_gestion_vehicular/viewmodels/reporte_recarga_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/vehiculo_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'componentes_reporte.dart';

class ReporteRecargaWidget extends StatefulWidget {
  const ReporteRecargaWidget({super.key});

  @override
  State<ReporteRecargaWidget> createState() => _ReporteRecargaWidgetState();
}

class _ReporteRecargaWidgetState extends State<ReporteRecargaWidget> {
  int? _ultimoVehiculoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vehiculoVM = context.read<VehiculoViewModel>();
    final reporteVM = context.read<ReporteRecargaViewModel>();

    final vehiculo = vehiculoVM.vehiculoActivo;
    if (vehiculo == null) return;

    // 🚫 Evitar recargas innecesarias
    if (_ultimoVehiculoId == vehiculo.idVehiculo) return;

    _ultimoVehiculoId = vehiculo.idVehiculo;

    // ✅ DIFERIDO AL FINAL DEL FRAME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      reporteVM.cargarReporte(
        vehiculoId: vehiculo.idVehiculo!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color recargaColor = Colors.orange;

    final reporteVM = context.watch<ReporteRecargaViewModel>();

    if (reporteVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reporteVM.error != null) {
      return Center(child: Text(reporteVM.error!));
    }

    final reporte = reporteVM.reporte;
    if (reporte == null) {
      return const Center(child: Text('Sin datos de recarga'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSummary(texto: reporteVM.resumenEntradas),

          const SeccionHeader(titulo: 'Costo', color: recargaColor),
          TripleStatsRow(
            labels: const ['Total', 'Por día', 'Por km'],
            values: [
              'MXN ${reporte.costoTotal.toStringAsFixed(2)}',
              'MXN ${reporte.costoPorDia.toStringAsFixed(2)}',
              'MXN ${reporte.costoPorKm.toStringAsFixed(2)}',
            ],
          ),

          const SizedBox(height: 20),

          const SeccionHeader(titulo: 'Combustible', color: recargaColor),
          DoubleStatsRow(
            l1: 'Volumen total',
            v1: '${reporte.litrosTotales.toStringAsFixed(2)} L',
            l2: 'Promedio general',
            v2: '${reporte.rendimientoPromedio.toStringAsFixed(2)} km/L',
          ),

          const SizedBox(height: 20),

          const SeccionHeader(
            titulo: 'Eficiencia del combustible',
            color: Colors.grey,
          ),
          TripleStatsRow(
            labels: const ['ÚLTIMO', 'MÁS GRANDE', 'INFERIOR'],
            values: [
              '${reporte.eficienciaUltima.toStringAsFixed(2)} km/L',
              '${reporte.eficienciaMaxima.toStringAsFixed(2)} km/L',
              '${reporte.eficienciaMinima.toStringAsFixed(2)} km/L',
            ],
            isMini: true,
          ),

          const SizedBox(height: 20),
          const SeccionHeader(titulo: 'Gráficos'),
          const SelectorGrafico(),
        ],
      ),
    );
  }
}

