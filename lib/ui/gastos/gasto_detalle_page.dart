import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'edit_gasto_page.dart';
import '../../viewmodels/gasto_movimiento_viewmodel.dart';

class GastoDetallePage extends StatefulWidget {
  final int idMovimiento;

  const GastoDetallePage({super.key, required this.idMovimiento});

  @override
  State<GastoDetallePage> createState() => _GastoDetallePageState();
}

class _GastoDetallePageState extends State<GastoDetallePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GastoMovimientoViewmodel>().cargarGastoPorId(
        widget.idMovimiento,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GastoMovimientoViewmodel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final movimiento = vm.movimiento;
    final detalles = vm.detallesMovimiento; // Lista completa de detalles

    if (movimiento == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el gasto')),
      );
    }

    final fechaFmt = DateFormat('dd/MMM/yyyy - HH:mm').format(movimiento.fecha);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722),
        title: const Text('Gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              // 1. Mostrar diálogo de confirmación
              final bool? confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar gasto?'),
                  content: const Text(
                    'Esta acción borrará el registro y todos sus detalles de forma permanente. ¿Deseas continuar?',
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
              );

              // 2. Si el usuario confirmó, ejecutar la eliminación
              if (confirmar == true) {
                try {
                  await context.read<GastoMovimientoViewmodel>().eliminarGasto(
                    widget.idMovimiento,
                  );

                  if (mounted) {
                    // 3. Regresar a la pantalla anterior (Historial)
                    Navigator.pop(context);

                    // 4. Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto eliminado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditGastoPage(idMovimiento: movimiento.idMovimiento ?? 0),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Agregado para evitar desbordamiento si hay muchos items
        child: Column(
          children: [
            _section(
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fechaFmt,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _divider(),

            // CABECERA DE LA TABLA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tipo de gasto',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  Text(
                    'Valor',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            // LISTADO DINÁMICO DE DETALLES
            ...detalles
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.descripcion ?? '-',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          'MXN${d.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            _divider(),

            // SECCIÓN DE TOTALES
            _twoColumns(
              leftLabel: 'Odómetro',
              leftValue: '${movimiento.odometro.toInt()} km',
              rightLabel: 'Costo total',
              rightValue: 'MXN${movimiento.total.toStringAsFixed(2)}',
            ),

            _divider(),
            _simpleText(movimiento.observaciones ?? 'Sin notas'),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI helpers
  // ─────────────────────────────────────────────

  Widget _section({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: child,
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _twoColumns({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: _labelValue(leftLabel, leftValue)),
          // Línea vertical separadora opcional como en la imagen de servicio
          Container(height: 40, width: 1, color: Colors.grey[300]),
          Expanded(child: _labelValue(rightLabel, rightValue, alignEnd: true)),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _simpleText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
