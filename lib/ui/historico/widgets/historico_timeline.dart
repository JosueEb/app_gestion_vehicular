import 'package:flutter/material.dart';
import '../../../models/historico_item_ui.dart';
import 'timeline_item.dart';

class HistoricoTimeline extends StatelessWidget {
  final Map<String, List<MovimientoHistorico>> data;

  const HistoricoTimeline({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final meses = data.keys.toList();

    return ListView.builder(
      itemCount: meses.length,
      itemBuilder: (context, index) {
        final mes = meses[index];
        final movimientos = data[mes]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER MES (estilo Drivvo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                mes.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.grey),
              ),
            ),

            /// MOVIMIENTOS DEL MES
            ...List.generate(movimientos.length, (i) {
              return HistoricoTimelineItem(
                movimiento: movimientos[i],
                isFirst: i == 0,
                isLast: i == movimientos.length - 1,
              );
            }),
          ],
        );
      },
    );
  }
}
