import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/historico_item_ui.dart';
import '../../../viewmodels/historico_viewmodel.dart'; // Asegúrate de importar tu VM
import '../../../viewmodels/recarga_viewmodel.dart' show RecargaViewModel;
import 'package:intl/intl.dart';
import '../../recargas/recarga_detalle_page.dart';
import '../../recargas/recarga_form_page.dart';
import '../../../viewmodels/vehiculo_viewmodel.dart';

class TimelineItem extends StatelessWidget {
  final MovimientoHistorico movimiento;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.movimiento,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es');

    // Escuchamos el ID expandido desde el ViewModel para el efecto acordeón
    final expandedId = context.select<HistoricoViewModel, int?>(
      (vm) => vm.itemExpandidoId,
    );
    final bool isExpanded = expandedId == movimiento.idMovimiento;

    // Obtenemos los cálculos de combustible si aplica
    final vm = context.read<HistoricoViewModel>();
    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    final tamanioTanque = vehiculo?.tamanioTanque.toDouble();
    final stats = vm.obtenerEstadisticasCombustible(
      movimiento,
      tamanioTanque?.toInt() ?? 0,
    );

    return InkWell(
      onTap: () {
        // Notificamos al ViewModel para cerrar otros y abrir este
        vm.toggleExpansion(movimiento.idMovimiento);
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ───── COLUMNA DEL TIMELINE (CARRETERA) ─────
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 10,
                    color: Colors.grey.shade700,
                    child: Center(
                      child: Container(width: 2, color: Colors.white54),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _colorPorTipo(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(_iconoPorTipo(), color: Colors.white, size: 20),
                  ),
                  Expanded(
                    child: Container(
                      width: 12,
                      color: isLast ? Colors.transparent : Colors.grey.shade700,
                      child: isLast
                          ? null
                          : Center(
                              child: Container(width: 2, color: Colors.white54),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            /// ───── CONTENIDO DEL ITEM ─────
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movimiento.tipo,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (movimiento.tipo.toLowerCase() ==
                                    'combustible')
                                  const Text(
                                    "Gasolinera",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.speed,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${movimiento.odometro.toStringAsFixed(0)} km',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                dateFormat
                                    .format(movimiento.fecha)
                                    .toLowerCase(),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                NumberFormat.currency(
                                  locale: 'es',
                                  symbol: "MXN",
                                ).format(movimiento.total),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ───── SECCIÓN EXPANDIBLE (CÁLCULOS Y ACCIONES) ─────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // MOSTRAR DATOS CALCULADOS
                                  if (stats != null) ...[
                                    _buildDetailExtra(
                                      Icons.local_gas_station,
                                      "Gasolina: ${stats['litros']?.toStringAsFixed(2)} L",
                                    ),
                                    if (stats['kmRecorridos']! > 0) ...[
                                      _buildDetailExtra(
                                        Icons.trending_up,
                                        "${stats['rendimiento']?.toStringAsFixed(2)} km/L",
                                      ),
                                      _buildDetailExtra(
                                        Icons.map,
                                        "Distancia recorrida: ${stats['kmRecorridos']?.toStringAsFixed(0)} km",
                                      ),
                                    ],
                                  ],

                                  // FILA DE ACCIONES
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  RecargaDetallePage(
                                                    idMovimiento:
                                                        movimiento.idMovimiento,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RecargaFormPage(
                                                idMovimiento:
                                                    movimiento.idMovimiento,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final confirm =
                                              await _confirmarEliminar(context);
                                          if (confirm) {
                                            await context
                                                .read<RecargaViewModel>()
                                                .eliminarRecarga(
                                                  movimiento.idMovimiento,
                                                );
                                          }
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity, height: 0),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailExtra(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  IconData _iconoPorTipo() {
    switch (movimiento.tipo.toLowerCase()) {
      case 'combustible':
        return Icons.local_gas_station;
      case 'servicio':
        return Icons.oil_barrel;
      case 'gasto':
        return Icons.credit_card;
      case 'ingreso':
        return Icons.credit_card;
      case 'lista de verificación':
        return Icons.checklist;
      default:
        return Icons.directions_car;
    }
  }

  Color _colorPorTipo() {
    switch (movimiento.tipo.toLowerCase()) {
      case 'combustible':
        return Colors.orange;
      case 'servicio':
        return const Color(0xFF795548);
      case 'gasto':
        return const Color(0xFFFF5722);
      case 'ruta':
        return const Color(0xFF607D8B);
      case 'ingreso':
        return Colors.lightGreen;
      case 'lista de verificación':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar recarga'),
            content: const Text(
              'Esta acción no se puede deshacer. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
