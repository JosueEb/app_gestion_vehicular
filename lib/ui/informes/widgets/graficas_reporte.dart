import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/gasto_mensual.dart';
import '../../../models/gasto_por_tipo.dart';
import '../../shared/app_colors.dart';
import '../../shared/movimiento_estilo.dart';

export '../../shared/movimiento_estilo.dart';

const _altoGrafica = 220.0;
const _maxMeses = 12;

/// Rellena con ceros los meses sin movimientos, para que el eje de tiempo
/// no oculte los huecos. Con [ultimos] conserva solo esa cantidad de meses.
List<GastoMensual> completarMeses(List<GastoMensual> gastos, {int? ultimos}) {
  if (gastos.isEmpty) return [];

  final porMes = {for (final g in gastos) (g.anio * 12 + g.mes - 1): g};
  final ultimo = porMes.keys.reduce(max);
  final primerRegistro = porMes.keys.reduce(min);
  final primero = ultimos == null
      ? primerRegistro
      : max(primerRegistro, ultimo - ultimos + 1);

  return [
    for (var m = primero; m <= ultimo; m++)
      porMes[m] ?? GastoMensual(anio: m ~/ 12, mes: m % 12 + 1),
  ];
}

/// Intervalo "redondo" (1, 2 o 5 × 10ⁿ) para unas cuatro líneas de guía.
double intervaloEje(double maximo) {
  if (maximo <= 0) return 1;

  final bruto = maximo / 4;
  final escala = pow(10, (log(bruto) / ln10).floor()).toDouble();
  final normalizado = bruto / escala;
  final paso = normalizado <= 1
      ? 1
      : normalizado <= 2
      ? 2
      : normalizado <= 5
      ? 5
      : 10;
  return paso * escala;
}

String _valorCorto(double valor) {
  if (valor >= 1000) {
    final miles = valor / 1000;
    return '${miles.toStringAsFixed(miles % 1 == 0 ? 0 : 1)}k';
  }
  return valor.toStringAsFixed(valor % 1 == 0 ? 0 : 1);
}

double _total(GastoMensual g) => g.recarga + g.gasto + g.servicio;

/// Barras apiladas por mes. Una barra de un solo tipo no necesita leyenda.
class GraficoMensual extends StatelessWidget {
  final List<GastoMensual> gastos;

  const GraficoMensual({super.key, required this.gastos});

  @override
  Widget build(BuildContext context) {
    final meses = completarMeses(gastos, ultimos: _maxMeses);
    if (meses.isEmpty) return const SinDatosGrafica();

    final recortado = completarMeses(gastos).length > _maxMeses;

    final series = [
      if (meses.any((g) => g.recarga > 0)) ('Recargas', colorRecarga),
      if (meses.any((g) => g.gasto > 0)) ('Gastos', colorGasto),
      if (meses.any((g) => g.servicio > 0)) ('Servicios', colorServicio),
    ];
    final maximo = meses.map(_total).reduce(max);
    final intervalo = intervaloEje(maximo);
    final fechaMes = DateFormat('MMM', 'es');
    final cadaCuanto = meses.length > 8 ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recortado) ...[
          const Text(
            'Últimos 12 meses',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
        ],
        if (series.length > 1) ...[
          LeyendaGrafica(series: series),
          const SizedBox(height: 12),
        ],
        Semantics(
          label:
              'Gráfica de costo por mes. Mes más caro: '
              '${formatoMoneda.format(maximo)}.',
          child: SizedBox(
            height: _altoGrafica,
            child: BarChart(
              BarChartData(
                maxY: (maximo / intervalo).ceil() * intervalo,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: _cuadricula(intervalo),
                barGroups: [
                  for (var i = 0; i < meses.length; i++)
                    _barra(i, meses[i], meses.length),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.textPrimary,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (_, i, __, ___) =>
                        _tooltipMes(meses[i]),
                  ),
                ),
                titlesData: _ejes(
                  intervalo: intervalo,
                  intervaloInferior: 1,
                  etiquetaInferior: (valor) {
                    final i = valor.toInt();
                    if (i < 0 || i >= meses.length) return '';
                    // Se cuenta desde el final para que el mes actual siempre tenga etiqueta
                    if ((meses.length - 1 - i) % cadaCuanto != 0) return '';
                    final g = meses[i];
                    return '${fechaMes.format(DateTime(g.anio, g.mes))}\n'
                        "'${(g.anio % 100).toString().padLeft(2, '0')}";
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _barra(int x, GastoMensual g, int cantidad) {
    var acumulado = 0.0;
    final segmentos = <BarChartRodStackItem>[];

    for (final (valor, color) in [
      (g.recarga, colorRecarga),
      (g.gasto, colorGasto),
      (g.servicio, colorServicio),
    ]) {
      if (valor <= 0) continue;
      segmentos.add(
        BarChartRodStackItem(
          acumulado,
          acumulado + valor,
          color,
          const BorderSide(color: Colors.white, width: 1),
        ),
      );
      acumulado += valor;
    }

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: acumulado,
          rodStackItems: segmentos,
          color: Colors.transparent,
          width: cantidad > 6 ? 14 : 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  BarTooltipItem _tooltipMes(GastoMensual g) {
    const estilo = TextStyle(color: Colors.white, fontSize: 12);
    final titulo = DateFormat('MMMM yyyy', 'es').format(DateTime(g.anio, g.mes));
    final lineas = [
      if (g.recarga > 0) 'Recargas: ${formatoMoneda.format(g.recarga)}',
      if (g.gasto > 0) 'Gastos: ${formatoMoneda.format(g.gasto)}',
      if (g.servicio > 0) 'Servicios: ${formatoMoneda.format(g.servicio)}',
    ];

    return BarTooltipItem(
      '$titulo\n',
      estilo.copyWith(fontWeight: FontWeight.bold),
      children: [
        TextSpan(
          text: lineas.isEmpty
              ? 'Sin movimientos'
              : '${lineas.join('\n')}\nTotal: ${formatoMoneda.format(_total(g))}',
          style: estilo,
        ),
      ],
    );
  }
}

/// Línea de una sola serie sobre una escala real de tiempo.
class GraficoLinea extends StatelessWidget {
  final List<(DateTime, double)> puntos;
  final Color color;
  final String Function(double) formato;
  final String descripcion;

  const GraficoLinea({
    super.key,
    required this.puntos,
    required this.color,
    required this.formato,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) return const SinDatosGrafica();

    final inicio = puntos.first.$1;
    double dia(DateTime f) => f.difference(inicio).inHours / 24;

    final valores = puntos.map((p) => p.$2).toList();
    final minimo = valores.reduce(min);
    final maximo = valores.reduce(max);
    final intervalo = intervaloEje(max(maximo - minimo, maximo.abs() * 0.04));
    final diasTotales = dia(puntos.last.$1);
    final fechaEje = DateFormat('d MMM', 'es');
    final fechaTooltip = DateFormat('d MMM yyyy', 'es');

    return Semantics(
      label:
          '$descripcion. De ${formato(valores.first)} a ${formato(valores.last)}.',
      child: SizedBox(
        height: _altoGrafica,
        child: LineChart(
          LineChartData(
            // El eje no parte de cero: lo que interesa aquí es la variación
            minY: (minimo / intervalo).floor() * intervalo,
            maxY: (maximo / intervalo).ceil() * intervalo +
                (minimo == maximo ? intervalo : 0),
            minX: diasTotales > 0 ? 0 : -1,
            maxX: diasTotales > 0 ? diasTotales : 1,
            borderData: FlBorderData(show: false),
            gridData: _cuadricula(intervalo),
            lineBarsData: [
              LineChartBarData(
                spots: [for (final p in puntos) FlSpot(dia(p.$1), p.$2)],
                color: color,
                barWidth: 2,
                dotData: FlDotData(
                  show: puntos.length <= 24,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.textPrimary,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (tocados) => [
                  for (final t in tocados)
                    LineTooltipItem(
                      '${fechaTooltip.format(puntos[t.spotIndex].$1)}\n'
                      '${formato(t.y)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                ],
              ),
            ),
            titlesData: _ejes(
              intervalo: intervalo,
              intervaloInferior: diasTotales > 0 ? diasTotales / 3 : 1,
              etiquetaInferior: (valor) => valor < 0 || valor > diasTotales
                  ? ''
                  : fechaEje.format(
                      inicio.add(Duration(hours: (valor * 24).round())),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reparto de un total con barras horizontales: admite nombres largos
/// y muestra monto y porcentaje sin tener que tocar nada.
class DesgloseBarras extends StatelessWidget {
  final List<GastoPorTipo> datos;
  final Color Function(GastoPorTipo) color;
  final String Function(GastoPorTipo) nombre;

  const DesgloseBarras({
    super.key,
    required this.datos,
    required this.color,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const SinDatosGrafica();

    final total = datos.fold<double>(0, (s, d) => s + d.total);

    return Column(
      children: [
        for (final d in datos)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        nombre(d),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${formatoMoneda.format(d.total)} · '
                      '${total > 0 ? (d.total / total * 100).round() : 0}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? d.total / total : 0,
                    minHeight: 8,
                    color: color(d),
                    backgroundColor: AppColors.divider,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class LeyendaGrafica extends StatelessWidget {
  final List<(String, Color)> series;

  const LeyendaGrafica({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final (nombre, color) in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class SinDatosGrafica extends StatelessWidget {
  final String mensaje;

  const SinDatosGrafica({
    super.key,
    this.mensaje = 'Sin datos en este periodo',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}

FlGridData _cuadricula(double intervalo) => FlGridData(
  drawVerticalLine: false,
  horizontalInterval: intervalo,
  getDrawingHorizontalLine: (_) =>
      const FlLine(color: AppColors.divider, strokeWidth: 1),
);

FlTitlesData _ejes({
  required double intervalo,
  required double intervaloInferior,
  required String Function(double) etiquetaInferior,
}) {
  const estilo = TextStyle(fontSize: 10, color: AppColors.textSecondary);
  const oculto = AxisTitles(sideTitles: SideTitles(showTitles: false));

  return FlTitlesData(
    topTitles: oculto,
    rightTitles: oculto,
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: intervalo,
        getTitlesWidget: (valor, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(_valorCorto(valor), style: estilo),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34,
        interval: intervaloInferior,
        getTitlesWidget: (valor, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          child: Text(
            etiquetaInferior(valor),
            style: estilo,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
