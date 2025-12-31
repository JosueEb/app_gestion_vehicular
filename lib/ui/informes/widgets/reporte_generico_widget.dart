import 'package:flutter/material.dart';
import 'componentes_reporte.dart';

class ReporteGenericoWidget extends StatelessWidget {
  final String titulo;
  final Color colorAcento;

  const ReporteGenericoWidget({
    super.key,
    required this.titulo,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen informativo (Rango de fechas y cantidad de entradas)
          const InfoSummary(texto: 'X entradas (Rango de fechas)'),
          
          // Sección de Costos con el color de acento dinámico (Naranja o Café)
          SeccionHeader(titulo: 'Costo', color: colorAcento),
          
          const TripleStatsRow(
            labels: ['Total', 'Por día', 'Por km'],
            values: ['MXN0.00', 'MXN0.00', 'MXN0.00'],
          ),
          
          const SizedBox(height: 24),
          
          // Sección de Gráficos
          const SeccionHeader(titulo: 'Gráficos'),
          const SelectorGrafico(),
          
          const SizedBox(height: 100), // Espacio extra para scroll
        ],
      ),
    );
  }
}