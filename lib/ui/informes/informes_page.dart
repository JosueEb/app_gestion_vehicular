import 'package:flutter/material.dart';

import '../../models/periodo_informe.dart';
import 'widgets/graficas_reporte.dart';
import 'widgets/reporte_general_widget.dart';
import 'widgets/reporte_movimiento_widget.dart';
import 'widgets/reporte_recarga_widget.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PeriodoInforme _periodo = PeriodoInforme.anio;

  // Definimos los colores para cada sección
  final List<Color> _seccionColors = [
    const Color(0xFF0097A7), // GENERAL (Teal)
    Colors.orange,           // RECARGA (Amarillo/Naranja)
    Colors.deepOrange,       // GASTO (Naranja)
    const Color(0xFF795548), // SERVICIO (Café)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Escuchamos el cambio de pestaña para actualizar el color de la UI
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ['GENERAL', 'RECARGA', 'GASTO', 'SERVICIO'];
    final Color activeColor = _seccionColors[_tabController.index];

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              // Colores dinámicos
              indicatorColor: activeColor,
              labelColor: activeColor,

              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<PeriodoInforme>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  selectedBackgroundColor: activeColor.withValues(alpha: 0.15),
                ),
                segments: [
                  for (final p in PeriodoInforme.values)
                    ButtonSegment(value: p, label: Text(p.etiqueta)),
                ],
                selected: {_periodo},
                onSelectionChanged: (s) => setState(() => _periodo = s.first),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ReporteGeneralWidget(periodo: _periodo),
                ReporteRecargaWidget(periodo: _periodo),
                ReporteMovimientoWidget(
                  tipoMovimiento: 'gasto',
                  etiquetaPlural: 'Gastos',
                  colorAcento: Colors.deepOrange,
                  colorSerie: colorGasto,
                  periodo: _periodo,
                ),
                ReporteMovimientoWidget(
                  tipoMovimiento: 'servicio',
                  etiquetaPlural: 'Servicios',
                  colorAcento: const Color(0xFF795548),
                  colorSerie: colorServicio,
                  periodo: _periodo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
