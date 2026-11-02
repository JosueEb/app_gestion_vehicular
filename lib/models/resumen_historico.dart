import 'dart:math';

import 'historico_item_ui.dart';
import 'tramo_rendimiento.dart';

class ResumenHistorico {
  final double gastoMes;
  final double kmMes;
  final double? odometroActual;
  final double? ultimoRendimiento;

  const ResumenHistorico({
    required this.gastoMes,
    required this.kmMes,
    this.odometroActual,
    this.ultimoRendimiento,
  });
}

/// [movimientos] puede venir en cualquier orden.
ResumenHistorico calcularResumen(
  List<MovimientoHistorico> movimientos,
  DateTime ahora,
) {
  if (movimientos.isEmpty) return const ResumenHistorico(gastoMes: 0, kmMes: 0);

  final inicioMes = DateTime(ahora.year, ahora.month);
  final finMes = DateTime(ahora.year, ahora.month + 1);
  final delMes = movimientos.where(
    (m) => !m.fecha.isBefore(inicioMes) && m.fecha.isBefore(finMes),
  );
  final previos = movimientos.where((m) => m.fecha.isBefore(inicioMes));

  var kmMes = 0.0;
  if (delMes.isNotEmpty) {
    final odometros = delMes.map((m) => m.odometro);
    // Se parte del último registro previo para contar lo recorrido hasta el primero del mes
    final base = previos.isNotEmpty
        ? previos.map((m) => m.odometro).reduce(max)
        : odometros.reduce(min);
    kmMes = max(0, odometros.reduce(max) - base);
  }

  return ResumenHistorico(
    gastoMes: delMes.fold(0, (s, m) => s + m.total),
    kmMes: kmMes,
    odometroActual: movimientos.map((m) => m.odometro).reduce(max),
    ultimoRendimiento: _ultimoRendimiento(movimientos),
  );
}

double? _ultimoRendimiento(List<MovimientoHistorico> movimientos) {
  final recargas =
      movimientos
          .where((m) => m.tipo == 'combustible' && m.detalles.isNotEmpty)
          .toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

  final tanques = recargas
      .map(
        (m) => RecargaTanque(
          odometro: m.odometro,
          litros: m.detalles.first.cantidad,
          costo: m.total,
          tanqueLleno: m.detalles.first.tanqueLleno,
        ),
      )
      .toList();

  for (var i = tanques.length - 1; i >= 0; i--) {
    final tramo = calcularTramo(tanques[i], tanques.skip(i + 1));
    if (tramo != null) return tramo.rendimiento;
  }
  return null;
}
