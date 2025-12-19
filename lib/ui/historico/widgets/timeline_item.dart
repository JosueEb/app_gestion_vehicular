import 'package:flutter/material.dart';
import '../../../models/historico_item_ui.dart';
import 'package:intl/intl.dart';

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

    return IntrinsicHeight(
      // Para que la línea vertical se ajuste al contenido
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// ───── COLUMNA DEL TIMELINE (CARRETERA) ─────
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // 1. LÍNEA SUPERIOR (Para conectar con el mes o item anterior)
                Container(
                  width: 12,
                  height:
                      10, // Ajusta este alto según el padding del texto del mes
                  color: Colors.grey.shade700,
                  child: Center(
                    child: Container(width: 2, color: Colors.white54),
                  ),
                ),

                // 2. ICONO
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _colorPorTipo(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(_iconoPorTipo(), color: Colors.white, size: 20),
                ),

                // 3. LÍNEA INFERIOR
                Expanded(
                  child: Container(
                    width: 12,
                    // Solo ocultamos la línea si es el ÚLTIMO item de TODA la lista
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
            child: Column(
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
                            if (movimiento.tipo.toLowerCase() == 'combustible')
                              Text(
                                "Gasolinera",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.speed, size: 14, color: Colors.grey),
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
                            dateFormat.format(movimiento.fecha).toLowerCase(),
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
                const Divider(height: 1), // Línea divisoria sutil
              ],
            ),
          ),
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
        return Color(0xFF795548);
      case 'ruta':
        return Color(0xFFE57373);
      case 'gasto':
        return Color(0xFF607D8B);
      case 'ingreso':
        return Colors.lightGreen;
      case 'lista de verificación':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}
