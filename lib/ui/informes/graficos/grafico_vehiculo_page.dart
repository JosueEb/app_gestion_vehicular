import 'package:app_gestion_vehicular/models/gasto_mensual.dart';
import 'package:app_gestion_vehicular/models/gasto_por_tipo.dart';
import 'package:app_gestion_vehicular/models/punto_odometro.dart';
import 'package:app_gestion_vehicular/viewmodels/reporte_general_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoVehiculoPage extends StatefulWidget {
  final String tipoGrafico;
  final int vehiculoId;

  const GraficoVehiculoPage({
    super.key,
    required this.tipoGrafico,
    required this.vehiculoId,
  });

  @override
  State<GraficoVehiculoPage> createState() => _GraficoVehiculoPageState();
}

class _GraficoVehiculoPageState extends State<GraficoVehiculoPage> {
  @override
  void initState() {
    super.initState();

    /// Cargar datos una sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ReporteGeneralViewModel>();

      switch (widget.tipoGrafico) {
        case 'Gráfico de odometro':
          vm.cargarOdometro(widget.vehiculoId);
          break;

        case 'Gráfico de gastos mensuales':
          vm.cargarGastosMensuales(vehiculoId: widget.vehiculoId);
          break;

        case 'Gráfico comparativo de gastos':
          vm.cargarGastosPorTipo(vehiculoId: widget.vehiculoId);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteGeneralViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico del vehículo'),
        backgroundColor: const Color(0xFF0097A7),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: vm.cargandoGrafico
          ? const Center(child: CircularProgressIndicator())
          : _contenido(vm),
    );
  }

  Widget _contenido(ReporteGeneralViewModel vm) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          widget.tipoGrafico,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _construirGrafico(vm),
          ),
        ),
        const SizedBox(height: 20),
        _construirLeyenda(widget.tipoGrafico),
        const SizedBox(height: 20),
      ],
    );
  }

  // ================= GRÁFICOS =================

  Widget _construirGrafico(ReporteGeneralViewModel vm) {
    switch (widget.tipoGrafico) {
      case 'Gráfico de odometro':
        return _lineChartOdometro(vm.puntosOdometro);

      case 'Gráfico de gastos mensuales':
        return _barChartGastos(vm.gastosMensuales);

      case 'Gráfico comparativo de gastos':
        return _pieChartComparativo(vm.gastosPorTipo);

      default:
        return const Center(child: Text('Tipo de gráfico no reconocido'));
    }
  }

  // ---------- LINE CHART (ODÓMETRO) ----------
  Widget _lineChartOdometro(List<PuntoOdometro> puntos) {
    if (puntos.isEmpty) return const Center(child: Text('Sin datos'));

    final spots = puntos.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.odometro);
    }).toList();

    // Busca el valor más pequeño y más grande en tu lista
    final double minY = puntos
        .map((e) => e.odometro)
        .reduce((a, b) => a < b ? a : b);
    final double maxY = puntos
        .map((e) => e.odometro)
        .reduce((a, b) => a > b ? a : b);

    // Luego en LineChartData:
    LineChartData(
      minY: minY * 0.98, // Le da un 2% de espacio abajo
      maxY: maxY * 1.02, // Le da un 2% de espacio arriba
      // ...
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        ),
        // --- CONFIGURACIÓN DE EJES ---
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ), // Ocultar derecha
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ), // Ocultar arriba
          // Eje Izquierdo (Kilometraje)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // Define cada cuánto quieres un número en el eje Y
              // Si tu odómetro va de 30,000 a 40,000, un intervalo de 2,000 es sano.
              interval: 2000,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Opcional: Si el número es muy grande (10000), puedes mostrarlo como '10k'
                if (value >= 1000) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: TextStyle(fontSize: 10),
                  );
                }
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),

          // Eje Inferior (Fechas)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // SI TIENES MUCHOS DATOS, AUMENTA ESTE NÚMERO
              // Ejemplo: interval: 5 (muestra la fecha cada 5 puntos)
              interval: (puntos.length / 5).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                // Solo mostramos si el índice existe en nuestra lista
                if (index >= 0 && index < puntos.length) {
                  return Text(
                    "${puntos[index].fecha.day}/${puntos[index].fecha.month}/${puntos[index].fecha.year}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        // ----------------------------
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved:
                false, // En tu imagen la línea parece ser tramos directos entre puntos
            color: Colors.cyan,
            barWidth: 2,
            dotData: FlDotData(
              show: true, // Tu imagen tiene círculos en cada punto
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.cyan,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BAR CHART (GASTOS MENSUALES) ----------
  Widget _barChartGastos(List<GastoMensual> gastos) {
    if (gastos.isEmpty) {
      return const Center(child: Text('Sin gastos registrados'));
    }

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < gastos.length; i++) {
      final g = gastos[i];

      double acumulado = 0;

      final stacks = <BarChartRodStackItem>[];

      if (g.recarga > 0) {
        stacks.add(
          BarChartRodStackItem(
            acumulado,
            acumulado + g.recarga,
            const Color(0xFFFFC04D), // Recarga
          ),
        );
        acumulado += g.recarga;
      }

      if (g.gasto > 0) {
        stacks.add(
          BarChartRodStackItem(
            acumulado,
            acumulado + g.gasto,
            const Color(0xFFFF8C6B), // Gasto
          ),
        );
        acumulado += g.gasto;
      }

      if (g.servicio > 0) {
        stacks.add(
          BarChartRodStackItem(
            acumulado,
            acumulado + g.servicio,
            const Color(0xFF9C8A80), // Servicio
          ),
        );
        acumulado += g.servicio;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: acumulado,
              rodStackItems: stacks,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),

        /// EJES
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= gastos.length) {
                  return const SizedBox.shrink();
                }

                final g = gastos[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${g.mes.toString().padLeft(2, '0')}/${g.anio}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  // ---------- PIE CHART (COMPARATIVO) ----------
  Widget _pieChartComparativo(List<GastoPorTipo> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('Sin datos para comparar'));
    }

    // Lista de colores para distinguir las secciones
    final List<Color> colores = [
      Colors.teal,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blue,
      Colors.purple,
    ];

    return PieChart(
      PieChartData(
        centerSpaceRadius: 50, // Radio del centro (efecto dona)
        sectionsSpace: 2, // Separación mínima entre rebanadas
        borderData: FlBorderData(show: false),
        sections: datos.asMap().entries.map((entry) {
          int idx = entry.key;
          var e = entry.value;

          return PieChartSectionData(
            value: e.total,
            color: colores[idx % colores.length], // Asigna color cíclico
            title: '${e.total.toStringAsFixed(0)}',
            radius: 60,
            showTitle: true,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            // Puedes añadir una insignia o etiqueta con e.tipo si lo deseas
          );
        }).toList(),
      ),
    );
  }

  // ================= LEYENDA =================

  Widget _construirLeyenda(String tipo) {
    switch (tipo) {
      case 'Gráfico comparativo de gastos':
        return const Text(
          'Distribución de gastos por tipo',
          style: TextStyle(color: Colors.grey),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
