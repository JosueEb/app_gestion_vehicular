import 'package:app_gestion_vehicular/viewmodels/reporte_recarga_viewmodel.dart';
import 'package:app_gestion_vehicular/viewmodels/vehiculo_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/periodo_informe.dart';
import '../../../services/movimientos_events.dart';
import '../../shared/empty_state.dart';
import 'componentes_reporte.dart';
import 'graficas_reporte.dart';

class ReporteRecargaWidget extends StatefulWidget {
  final PeriodoInforme periodo;

  const ReporteRecargaWidget({super.key, required this.periodo});

  @override
  State<ReporteRecargaWidget> createState() => _ReporteRecargaWidgetState();
}

class _ReporteRecargaWidgetState extends State<ReporteRecargaWidget> {
  @override
  void initState() {
    super.initState();
    MovimientosEvents.cambios.addListener(_cargar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void didUpdateWidget(ReporteRecargaWidget anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.periodo != widget.periodo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
    }
  }

  @override
  void dispose() {
    MovimientosEvents.cambios.removeListener(_cargar);
    super.dispose();
  }

  void _cargar() {
    if (!mounted) return;

    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    if (vehiculo == null) return;

    context.read<ReporteRecargaViewModel>().cargarReporte(
      vehiculoId: vehiculo.idVehiculo!,
      desde: widget.periodo.desde(),
      hasta: widget.periodo.hasta(),
    );
  }

  String _kmL(double valor) =>
      valor > 0 ? '${valor.toStringAsFixed(2)} km/L' : '--';

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
      return const EmptyState(message: 'Sin recargas en este periodo');
    }

    final rendimientos = [
      for (final p in reporte.puntos)
        if (p.rendimiento != null) (p.fecha, p.rendimiento!),
    ];

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
              formatoMoneda.format(reporte.costoTotal),
              formatoMoneda.format(reporte.costoPorDia),
              formatoMoneda.format(reporte.costoPorKm),
            ],
          ),
          const SizedBox(height: 12),
          DoubleStatsRow(
            l1: 'Por recarga',
            v1: formatoMoneda.format(reporte.costoPromedio),
            l2: 'Precio promedio',
            v2: '${formatoMoneda.format(reporte.precioPromedioLitro)}/L',
          ),

          const SizedBox(height: 20),

          const SeccionHeader(titulo: 'Combustible', color: recargaColor),
          DoubleStatsRow(
            l1: 'Volumen total',
            v1: '${reporte.litrosTotales.toStringAsFixed(2)} L',
            l2: 'Promedio general',
            v2: _kmL(reporte.rendimientoPromedio),
          ),

          const SizedBox(height: 20),

          const SeccionHeader(titulo: 'Rendimiento', color: recargaColor),
          TripleStatsRow(
            labels: const ['Último', 'Mejor', 'Peor'],
            values: [
              _kmL(reporte.eficienciaUltima),
              _kmL(reporte.eficienciaMaxima),
              _kmL(reporte.eficienciaMinima),
            ],
            isMini: true,
          ),
          const SizedBox(height: 16),
          if (rendimientos.length < 2)
            const SinDatosGrafica(
              mensaje:
                  'Registra más recargas con tanque lleno para ver cómo cambia el rendimiento',
            )
          else
            GraficoLinea(
              puntos: rendimientos,
              color: colorRecarga,
              formato: _kmL,
              descripcion: 'Gráfica de rendimiento por recarga',
            ),

          const SizedBox(height: 20),

          const SeccionHeader(titulo: 'Precio por litro', color: recargaColor),
          GraficoLinea(
            puntos: [
              for (final p in reporte.puntos) (p.fecha, p.precioLitro),
            ],
            color: colorRecarga,
            formato: (v) => '${formatoMoneda.format(v)}/L',
            descripcion: 'Gráfica del precio por litro en cada recarga',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
