import 'package:app_gestion_vehicular/ui/servicios/detalle_servicio_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/historico_item_ui.dart';
import '../../../viewmodels/historico_viewmodel.dart'; // Asegúrate de importar tu VM
import '../../../viewmodels/recarga_viewmodel.dart';
import '../../../viewmodels/gasto_movimiento_viewmodel.dart';
import '../../../viewmodels/servicio_movimiento_viewmodel.dart';
import 'package:intl/intl.dart';
import '../../gastos/edit_gasto_page.dart';
import '../../gastos/gasto_detalle_page.dart';
import '../../recargas/recarga_detalle_page.dart';
import '../../recargas/recarga_form_page.dart';
import '../../../viewmodels/vehiculo_viewmodel.dart';
import '../../servicios/edit_servicio_page.dart';
import '../../shared/app_colors.dart';
import '../../shared/movimiento_estilo.dart';

class TimelineItem extends StatelessWidget {
  final MovimientoHistorico movimiento;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.movimiento,
    this.isLast = false,
  });

  /// "Peaje +2" o, sin conceptos, el nombre del tipo
  String get _titulo {
    final detalles = movimiento.detalles;
    final primero = detalles.isNotEmpty ? detalles.first.descripcion : null;
    if (primero == null || primero.isEmpty) {
      return nombreTipoMovimiento(movimiento.tipo);
    }
    return detalles.length > 1 ? '$primero +${detalles.length - 1}' : primero;
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM', 'es').format(movimiento.fecha);
    final km = NumberFormat('#,##0').format(movimiento.odometro);
    final color = colorTipoMovimiento(movimiento.tipo);

    final vm = context.read<HistoricoViewModel>();
    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    final stats = vm.obtenerEstadisticasCombustible(
      movimiento,
      vehiculo?.tamanioTanque ?? 0,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _verDetalleMovimiento(context, movimiento),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ───── ICONO Y LÍNEA DEL TIMELINE ─────
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconoTipoMovimiento(movimiento.tipo),
                      color: color,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: isLast
                        ? const SizedBox.shrink()
                        : Container(width: 2, color: AppColors.divider),
                  ),
                ],
              ),
            ),

            /// ───── CONTENIDO DEL ITEM ─────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _titulo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatoMoneda.format(movimiento.total),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${nombreTipoMovimiento(movimiento.tipo)} · $fecha · $km km',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (stats != null)
                      Text(
                        [
                          '${stats['litros']!.toStringAsFixed(1)} L',
                          if (stats['rendimiento']! > 0)
                            '${stats['rendimiento']!.toStringAsFixed(1)} km/L',
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            /// ───── ACCIONES ─────
            PopupMenuButton<String>(
              tooltip: 'Más acciones',
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onSelected: (accion) {
                if (accion == 'editar') {
                  _editarMovimiento(context, movimiento);
                } else {
                  _manejarEliminacion(context, movimiento);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalleMovimiento(
    BuildContext context,
    MovimientoHistorico movimiento,
  ) {
    switch (movimiento.tipo) {
      case 'combustible':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RecargaDetallePage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      case 'servicio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ServicioDetallePage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      case 'gasto':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GastoDetallePage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de movimiento no soportado')),
        );
    }
  }

  void _editarMovimiento(BuildContext context, MovimientoHistorico movimiento) {
    switch (movimiento.tipo) {
      case 'combustible':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RecargaFormPage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      case 'servicio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EditServicioPage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      case 'gasto':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EditGastoPage(idMovimiento: movimiento.idMovimiento),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de movimiento no soportado')),
        );
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context, String tipo) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Eliminar $tipo'),
            content: Text(
              '¿Estás seguro de que deseas eliminar este registro? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ELIMINAR'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _manejarEliminacion(
    BuildContext context,
    MovimientoHistorico movimiento,
  ) async {
    final confirm = await _confirmarEliminar(
      context,
      nombreTipoMovimiento(movimiento.tipo).toLowerCase(),
    );
    if (!confirm) return;

    try {
      switch (movimiento.tipo.toLowerCase()) {
        case 'combustible':
          await context.read<RecargaViewModel>().eliminarRecarga(
            movimiento.idMovimiento,
          );
          break;
        case 'servicio':
          await context.read<ServicioMovimientoViewModel>().eliminarServicio(
            movimiento.idMovimiento,
          );
          break;
        case 'gasto':
          await context.read<GastoMovimientoViewmodel>().eliminarGasto(
            movimiento.idMovimiento,
          );
          break;
        default:
          throw 'Tipo no soportado para eliminar';
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${nombreTipoMovimiento(movimiento.tipo)} eliminado correctamente',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }
}
