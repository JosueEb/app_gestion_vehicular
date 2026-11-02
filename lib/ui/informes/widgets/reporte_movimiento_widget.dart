import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/periodo_informe.dart';
import '../../../services/movimientos_events.dart';
import '../../../viewmodels/reporte_movimiento_viewmodel.dart';
import '../../../viewmodels/vehiculo_viewmodel.dart';
import '../../shared/empty_state.dart';
import 'componentes_reporte.dart';
import 'graficas_reporte.dart';

/// Pestañas GASTO y SERVICIO
class ReporteMovimientoWidget extends StatefulWidget {
  final String tipoMovimiento;
  final String etiquetaPlural;
  final Color colorAcento;
  final Color colorSerie;
  final PeriodoInforme periodo;

  const ReporteMovimientoWidget({
    super.key,
    required this.tipoMovimiento,
    required this.etiquetaPlural,
    required this.colorAcento,
    required this.colorSerie,
    required this.periodo,
  });

  @override
  State<ReporteMovimientoWidget> createState() =>
      _ReporteMovimientoWidgetState();
}

class _ReporteMovimientoWidgetState extends State<ReporteMovimientoWidget> {
  late final ReporteMovimientoViewModel _vm = ReporteMovimientoViewModel(
    widget.tipoMovimiento,
  );

  @override
  void initState() {
    super.initState();
    MovimientosEvents.cambios.addListener(_cargar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void didUpdateWidget(ReporteMovimientoWidget anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.periodo != widget.periodo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
    }
  }

  @override
  void dispose() {
    MovimientosEvents.cambios.removeListener(_cargar);
    _vm.dispose();
    super.dispose();
  }

  void _cargar() {
    if (!mounted) return;

    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    if (vehiculo == null) return;

    _vm.cargarReporte(
      vehiculoId: vehiculo.idVehiculo!,
      desde: widget.periodo.desde(),
      hasta: widget.periodo.hasta(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_vm.error != null) {
          return Center(child: Text(_vm.error!));
        }

        final reporte = _vm.reporte;
        if (reporte == null) {
          return EmptyState(
            message:
                'Sin ${widget.etiquetaPlural.toLowerCase()} en este periodo',
          );
        }

        final fecha = DateFormat('dd/MMM/yyyy', 'es');
        final principal = reporte.conceptos.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSummary(
                texto:
                    '${reporte.totalEntradas} entradas '
                    '(${fecha.format(reporte.fechaInicio)} - '
                    '${fecha.format(reporte.fechaFin)})',
              ),

              SeccionHeader(titulo: 'Costo', color: widget.colorAcento),
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
                l1: 'Promedio por entrada',
                v1: formatoMoneda.format(reporte.costoPromedio),
                l2: 'Mayor concepto',
                v2: principal.tipo,
              ),

              const SizedBox(height: 20),

              SeccionHeader(titulo: 'Por concepto', color: widget.colorAcento),
              DesgloseBarras(
                datos: reporte.conceptos,
                color: (_) => widget.colorSerie,
                nombre: (d) => d.tipo,
              ),

              const SizedBox(height: 20),

              SeccionHeader(titulo: 'Costo por mes', color: widget.colorAcento),
              GraficoMensual(gastos: reporte.mensual),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
