import 'package:flutter/material.dart';
import 'componentes_reporte.dart';

class ReporteRecargaWidget extends StatelessWidget {
  const ReporteRecargaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const Color recargaColor = Colors.orange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoSummary(texto: '30 entradas (11/jun/2025 - 22/dic/2025)'),
          const SeccionHeader(titulo: 'Costo', color: recargaColor),
          const TripleStatsRow(
            labels: ['Total', 'Por día', 'Por km'],
            values: ['MXN15,666.37', 'MXN80.34', 'MXN1.87'],
          ),
          const SizedBox(height: 20),
          const SeccionHeader(titulo: 'Combustible', color: recargaColor),
          const DoubleStatsRow(
            l1: 'Volumen total', v1: '670.98 L',
            l2: 'Promedio general', v2: '12.89 km/L',
          ),
          const SizedBox(height: 20),
          const SeccionHeader(titulo: 'Eficiencia del combustible', color: Colors.grey),
          const TripleStatsRow(
            labels: ['ÚLTIMO', 'MÁS GRANDE', 'INFERIOR'],
            values: ['13.16 km/L', '14.22 km/L', '11.67 km/L'],
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