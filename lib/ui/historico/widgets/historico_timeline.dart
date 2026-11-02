import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/historico_viewmodel.dart';
import '../../shared/app_colors.dart';
import '../../shared/movimiento_estilo.dart';
import 'timeline_item.dart';

// historico_timeline.dart

class HistoricoTimeline extends StatelessWidget {
  final Widget encabezado;
  final Future<void> Function() onRefresh;

  const HistoricoTimeline({
    super.key,
    required this.encabezado,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoricoViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = vm.agrupadoPorMes.entries.toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // Margen inferior: el último registro no queda pegado a la barra
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: entries.isEmpty ? 2 : entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return encabezado;
          if (entries.isEmpty) {
            return _SinRegistros(hayFiltro: vm.filtroTipo != null);
          }

          final entry = entries[index - 1];
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ───── HEADER DEL MES ─────
              TimelineMonthHeader(
                mes: entry.key,
                total: items.fold(0.0, (s, m) => s + m.total),
              ),

              /// ───── LISTA DE ITEMS ─────
              for (var i = 0; i < items.length; i++)
                TimelineItem(
                  movimiento: items[i],
                  isLast: i == items.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}

class TimelineMonthHeader extends StatelessWidget {
  final String mes;
  final double total;

  const TimelineMonthHeader({
    super.key,
    required this.mes,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
      color: AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(mes, style: estilo)),
          Text(formatoMoneda.format(total), style: estilo),
        ],
      ),
    );
  }
}

class _SinRegistros extends StatelessWidget {
  final bool hayFiltro;

  const _SinRegistros({required this.hayFiltro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            hayFiltro ? Icons.filter_list_off : Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            hayFiltro ? 'Nada de este tipo todavía' : 'Aún no hay registros',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (!hayFiltro) ...[
            const SizedBox(height: 4),
            const Text(
              'Toca el botón + para agregar tu primera recarga, gasto o servicio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
