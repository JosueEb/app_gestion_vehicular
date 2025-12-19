import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/recarga_viewmodel.dart';
import '../../viewmodels/historico_viewmodel.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import 'recarga_form_page.dart';

class RecargaDetallePage extends StatefulWidget {
  final int idMovimiento;

  const RecargaDetallePage({super.key, required this.idMovimiento});

  @override
  State<RecargaDetallePage> createState() => _RecargaDetallePageState();
}

class _RecargaDetallePageState extends State<RecargaDetallePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecargaViewModel>().prepararEdicion(widget.idMovimiento);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecargaViewModel>();
    const orangeTheme = Color(0xFFFFA000);

    if (vm.isLoading || vm.recargaSeleccionada == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;

    final r = vm.recargaSeleccionada!;
    final stats = vehiculo == null
        ? null
        : context.read<HistoricoViewModel>().obtenerEstadisticasDesdeMap(
            r,
            vehiculo.tamanioTanque,
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: orangeTheme,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Recarga', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context, vm),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: _DetalleContenido(r: r, stats: stats),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecargaFormPage(idMovimiento: widget.idMovimiento),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, RecargaViewModel vm) async {
    final confirm = await _confirmarEliminar(context);
    if (confirm) {
      await vm.eliminarRecarga(widget.idMovimiento);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar recarga'),
            content: const Text(
              '¿Deseas eliminar este registro de forma permanente?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'ELIMINAR',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/* -------------------------------------------------------------------------- */
/*                               CONTENIDO UI                                 */
/* -------------------------------------------------------------------------- */

class _DetalleContenido extends StatelessWidget {
  final Map<String, dynamic> r;
  final Map<String, double>? stats;

  const _DetalleContenido({required this.r, required this.stats});

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA000);
    final total = (r['total'] as num?)?.toDouble() ?? 0.0;
    final fecha = DateTime.parse(r['fecha']);

    return Column(
      children: [
        // ---------------- HEADER ----------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: orangeColor.withOpacity(0.05)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Costo total',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                'MXN${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: orangeColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerIconInfo(Icons.speed, '${r['odometro']} km'),
                  if (stats != null && stats!['kmRecorridos'] != 0)
                    _headerIconInfo(
                      Icons.edit_road,
                      '${stats!['kmRecorridos']!.toInt()} km',
                    ),
                ],
              ),
            ],
          ),
        ),

        // ---------------- NAVEGACIÓN FECHA ----------------
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Consumer<RecargaViewModel>(
            builder: (_, vm, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: vm.puedeIrAnterior ? Colors.orange : Colors.grey,
                    onPressed: vm.puedeIrAnterior ? vm.irAnterior : null,
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM/yyyy - HH:mm').format(fecha)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: vm.puedeIrSiguiente ? Colors.orange : Colors.grey,
                    onPressed: vm.puedeIrSiguiente ? vm.irSiguiente : null,
                  ),
                ],
              );
            },
          ),
        ),

        const Divider(height: 1),

        // ---------------- COMBUSTIBLE ----------------
        _sectionTitle('Gasolina regular'),
        _infoGrid([
          _gridItem('Precio / L', 'MXN${r['precio_unitario']}'),
          _gridItem('Costo total', 'MXN${total.toStringAsFixed(2)}'),
          _gridItem('Volumen', '${r['cantidad']} L'),
        ]),

        const Divider(),

        // ---------------- EFICIENCIA ----------------
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _infoGrid([
                    _gridItem(
                      'Completar',
                      r['tanque_lleno'] == 1 ? 'Sí' : 'No',
                    ),
                  ]),
                  _infoGrid([
                    _gridItem(
                      'Eficiencia',
                      stats == null
                          ? '-'
                          : '${stats!['rendimiento']!.toStringAsFixed(2)} km/L',
                    ),
                    _gridItem(
                      'Costo / Km',
                      stats == null
                          ? '-'
                          : 'MXN${stats!['costoPorKm']!.toStringAsFixed(2)}',
                    ),
                  ]),
                ],
              ),
            ),
            Expanded(
              child: _tankWidget(stats?['porcentajeTanque']?.round() ?? 0),
            ),
          ],
        ),

        // const Divider(),
        // _listLabelValue(
        //   'Gasolinera',
        //   r['descripcion'] ?? '-',
        // ),
      ],
    );
  }

  /* ----------------------- COMPONENTES REUTILIZABLES ---------------------- */

  Widget _headerIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _infoGrid(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: children.map((e) => Expanded(child: e)).toList()),
    );
  }

  Widget _gridItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  // Widget _listLabelValue(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             color: Colors.grey,
  //             fontSize: 12,
  //           ),
  //         ),
  //         Text(
  //           value,
  //           style: const TextStyle(fontSize: 16),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _tankWidget(int percent) {
    final level = (percent.clamp(0, 100)) / 100;
    const orangeColor = Color(0xFFFFA000);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '% del tanque',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Icon(
              Icons.local_gas_station,
              size: 50,
              color: Colors.grey.shade300,
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: level,
                child: const Icon(
                  Icons.local_gas_station,
                  size: 50,
                  color: orangeColor,
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: orangeColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
