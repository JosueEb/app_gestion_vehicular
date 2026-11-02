import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/gasto_mensual.dart';
import '../../../models/gasto_por_tipo.dart';
import '../../../models/periodo_informe.dart';
import '../../../services/movimientos_events.dart';
import '../../../viewmodels/reporte_general_viewmodel.dart';
import '../../../viewmodels/vehiculo_viewmodel.dart';
import '../../shared/empty_state.dart';
import 'componentes_reporte.dart';
import 'graficas_reporte.dart';

class ReporteGeneralWidget extends StatefulWidget {
  final PeriodoInforme periodo;

  const ReporteGeneralWidget({super.key, required this.periodo});

  @override
  State<ReporteGeneralWidget> createState() => _ReporteGeneralWidgetState();
}

class _ReporteGeneralWidgetState extends State<ReporteGeneralWidget> {
  @override
  void initState() {
    super.initState();
    MovimientosEvents.cambios.addListener(_cargar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void didUpdateWidget(ReporteGeneralWidget anterior) {
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

    context.read<ReporteGeneralViewModel>().cargarReporte(
      vehiculoId: vehiculo.idVehiculo!,
      desde: widget.periodo.desde(),
      hasta: widget.periodo.hasta(),
    );
  }

  String _formatFecha(DateTime? fecha, DateFormat formatter) {
    if (fecha == null) return '--';
    return formatter.format(fecha);
  }

  String _nombreCategoria(GastoPorTipo d) => switch (d.tipo) {
    'combustible' => 'Recargas',
    'gasto' => 'Gastos',
    'servicio' => 'Servicios',
    _ => d.tipo,
  };

  Color _colorCategoria(GastoPorTipo d) => switch (d.tipo) {
    'combustible' => colorRecarga,
    'gasto' => colorGasto,
    _ => colorServicio,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteGeneralViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
          );
        }

        final data = vm.data;
        if (data == null || data.totalEntradas == 0) {
          return const EmptyState(message: 'Sin movimientos en este periodo');
        }

        final dateFormat = DateFormat('dd/MMM/yyyy', 'es');
        final meses = completarMeses(vm.gastosMensuales);
        double totalMes(GastoMensual g) => g.recarga + g.gasto + g.servicio;
        final mesMayor = meses.reduce(
          (a, b) => totalMes(b) > totalMes(a) ? b : a,
        );
        final promedioMensual =
            meses.fold<double>(0, (s, g) => s + totalMes(g)) / meses.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 📌 RESUMEN
              InfoSummary(
                texto:
                    '${data.totalEntradas} entradas '
                    '(${_formatFecha(data.fechaInicio, dateFormat)} - '
                    '${_formatFecha(data.fechaFin, dateFormat)})',
              ),

              const SeccionHeader(titulo: 'Costo'),
              TripleStatsRow(
                labels: const ['Total', 'Por día', 'Por km'],
                values: [
                  formatoMoneda.format(data.costoTotal),
                  formatoMoneda.format(data.costoPorDia),
                  formatoMoneda.format(data.costoPorKm),
                ],
              ),
              const SizedBox(height: 12),
              DoubleStatsRow(
                l1: 'Promedio mensual',
                v1: formatoMoneda.format(promedioMensual),
                l2:
                    'Mes más caro (${DateFormat('MMM yy', 'es').format(DateTime(mesMayor.anio, mesMayor.mes))})',
                v2: formatoMoneda.format(totalMes(mesMayor)),
              ),

              const SizedBox(height: 20),

              const SeccionHeader(titulo: 'Distancia'),
              DoubleStatsRow(
                l1: 'Total',
                v1: '${data.kmTotales.toStringAsFixed(0)} km',
                l2: 'Promedio diario',
                v2: '${data.kmPromedioDiario.toStringAsFixed(0)} km',
              ),

              const SizedBox(height: 20),

              const SeccionHeader(titulo: '¿En qué se va el dinero?'),
              DesgloseBarras(
                datos: vm.gastosPorTipo,
                color: _colorCategoria,
                nombre: _nombreCategoria,
              ),

              const SizedBox(height: 20),

              const SeccionHeader(titulo: 'Costo por mes'),
              GraficoMensual(gastos: vm.gastosMensuales),

              const SizedBox(height: 20),

              const SeccionHeader(titulo: 'Odómetro'),
              GraficoLinea(
                puntos: [
                  for (final p in vm.puntosOdometro) (p.fecha, p.odometro),
                ],
                color: const Color(0xFF0097A7),
                formato: (v) => '${NumberFormat('#,##0').format(v)} km',
                descripcion: 'Gráfica del odómetro en el tiempo',
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
