import 'package:flutter/material.dart';
import '../../../models/historico_item_ui.dart';

class HistoricoTimelineItem extends StatelessWidget {
  final MovimientoHistorico movimiento;
  final bool isFirst;
  final bool isLast;

  const HistoricoTimelineItem({
    super.key,
    required this.movimiento,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// COLUMNA TIMELINE
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              Container(
                width: 2,
                height: isFirst ? 12 : 24,
                color: Colors.grey.shade300,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _colorByTipo(),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: isLast ? 12 : 48,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        /// CARD
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(
                right: 16, bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _ContenidoMovimiento(
                movimiento: movimiento,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _colorByTipo() {
    switch (movimiento.tipo) {
      case 'combustible':
        return Colors.green;
      case 'servicio':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ContenidoMovimiento extends StatelessWidget {
  final MovimientoHistorico movimiento;

  const _ContenidoMovimiento({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TÍTULO + TOTAL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              movimiento.tipo.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '\$${movimiento.total.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 4),

        /// FECHA + KM
        Text(
          '${_fmtFecha(movimiento.fecha)} • ${movimiento.odometro.toStringAsFixed(0)} km',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),

        const SizedBox(height: 8),

        /// DETALLES
        ...movimiento.detalles.map(
          (d) => Text(
            '• ${d.descripcion ?? d.tipoDetalle}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _fmtFecha(DateTime f) =>
      '${f.day}/${f.month}/${f.year}';
}
