import 'package:app_gestion_vehicular/ui/servicios/edit_servicio_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/servicio_movimiento_viewmodel.dart';

class ServicioDetallePage extends StatefulWidget {
  final int idMovimiento;

  const ServicioDetallePage({super.key, required this.idMovimiento});

  @override
  State<ServicioDetallePage> createState() => _ServicioDetallePageState();
}

class _ServicioDetallePageState extends State<ServicioDetallePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicioMovimientoViewModel>().cargarGastoPorId(
        widget.idMovimiento,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServicioMovimientoViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final movimiento = vm.movimiento;
    final detalles = vm.detallesMovimiento;

    if (movimiento == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el servicio')),
      );
    }

    final fechaFmt = DateFormat('dd/MMM/yyyy - HH:mm').format(movimiento.fecha);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D6E63), // Color café de la imagen
        title: const Text('Servicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarEliminacion(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navegación a edición
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditServicioPage(
                    idMovimiento: movimiento.idMovimiento ?? 0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Fecha con icono
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

            // Cabecera de la tabla de servicios
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tipo de servicio',
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

            // Listado de servicios dinámico
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
                ,

            _divider(),

            // Sección de Odómetro y Costo Total (Dos columnas con separador)
            _twoColumns(
              leftLabel: 'Odómetro',
              leftValue: '${movimiento.odometro.toInt()} km',
              rightLabel: 'Costo total',
              rightValue: 'MXN${movimiento.total.toStringAsFixed(2)}',
            ),

            _divider(),
            _simpleText(movimiento.observaciones ?? 'sin observaciones'),
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
          // Separador vertical como en image_272fe5.png
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

  // Lógica de eliminación corregida para evitar warnings de BuildContext
  Future<void> _confirmarEliminacion(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar servicio?'),
        content: const Text(
          'Esta acción borrará el registro de forma permanente.',
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

    if (confirmar == true) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final vm = context.read<ServicioMovimientoViewModel>();

      try {
        await vm.eliminarServicio(widget.idMovimiento);
        if (!mounted) return;

        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Servicio eliminado'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
