import 'package:app_gestion_vehicular/ui/informes/graficos/grafico_vehiculo_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/reporte_general_viewmodel.dart';
import '../../../viewmodels/vehiculo_viewmodel.dart';
import 'componentes_reporte.dart';

class ReporteGeneralWidget extends StatefulWidget {
  const ReporteGeneralWidget({super.key});

  @override
  State<ReporteGeneralWidget> createState() => _ReporteGeneralWidgetState();
}

class _ReporteGeneralWidgetState extends State<ReporteGeneralWidget> {
  bool _cargado = false;
  String? graficoSeleccionado = 'Seleccionar';
  int? vehiculoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_cargado) return;

    _cargado = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehiculoVm = context.read<VehiculoViewModel>();
      final reporteVm = context.read<ReporteGeneralViewModel>();

      final vehiculo = vehiculoVm.vehiculoActivo;
      if (vehiculo != null) {
        reporteVm.cargarReporte(vehiculoId: vehiculo.idVehiculo!);
        vehiculoId = vehiculo.idVehiculo;
      }
    });
  }

  String _formatFecha(DateTime? fecha, DateFormat formatter) {
    if (fecha == null) return '--';
    return formatter.format(fecha);
  }

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

        if (vm.data == null) {
          return const Center(child: Text('No hay datos para mostrar'));
        }

        final data = vm.data!;
        final currency = NumberFormat.currency(locale: 'es_MX', symbol: 'MXN');
        final dateFormat = DateFormat('dd/MMM/yyyy', 'es');

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
                  currency.format(data.costoTotal),
                  currency.format(data.costoPorDia),
                  currency.format(data.costoPorKm),
                ],
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

              const SeccionHeader(titulo: 'Gráficos'),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ), // Ajustado para el dropdown
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  // Quitamos la línea por defecto del dropdown
                  child: DropdownButton<String>(
                    value: graficoSeleccionado,
                    isExpanded: true, // Para que ocupe todo el ancho
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items:
                        <String>[
                          'Seleccionar',
                          'Gráfico comparativo de gastos',
                          'Gráfico de gastos mensuales',
                          'Gráfico de odometro',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                const Icon(Icons.bar_chart, color: Colors.grey),
                                const SizedBox(width: 10),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Navigator.push se encarga de cambiar la pantalla
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraficoVehiculoPage(
                              tipoGrafico: newValue,
                              vehiculoId: vehiculoId!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
