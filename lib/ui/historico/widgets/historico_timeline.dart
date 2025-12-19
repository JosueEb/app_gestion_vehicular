import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/historico_viewmodel.dart';
import 'timeline_item.dart';

// historico_timeline.dart

class HistoricoTimeline extends StatelessWidget {
  const HistoricoTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoricoViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final agrupado = vm.agrupadoPorMes;
    final entries = agrupado.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final mes = entry.key;
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ───── HEADER DEL MES ─────
            TimelineMonthHeader(
              mes: mes,
              isFirst: index == 0,
            ),

            /// ───── LISTA DE ITEMS ─────
            ...List.generate(
              items.length,
              (i) {
                // Verificamos si es el último absoluto de toda la lista
                final bool isLastAbsolute = 
                    (index == entries.length - 1) && (i == items.length - 1);
                
                return TimelineItem(
                  movimiento: items[i],
                  isLast: isLastAbsolute,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// En historico_timeline.dart

class TimelineMonthHeader extends StatelessWidget {
  final String mes;
  final bool isFirst; // Añadimos esto para saber si es el inicio absoluto

  const TimelineMonthHeader({
    super.key,
    required this.mes,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Si es el primer mes, dejamos un espacio vacío, si no, continuamos la línea
                Container(
                  width: 12,
                  height: 15,
                  color: isFirst ? Colors.transparent : Colors.grey.shade700,
                  child: isFirst
                      ? null
                      : Center(
                          child: Container(width: 2, color: Colors.white54),
                        ),
                ),
                Expanded(
                  child: Container(
                    width: 12,
                    color: Colors.grey.shade700,
                    child: Center(
                      child: Container(width: 2, color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                mes.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
