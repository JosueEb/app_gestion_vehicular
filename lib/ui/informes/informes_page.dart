import 'package:flutter/material.dart';
import 'widgets/reporte_general_widget.dart';
import 'widgets/reporte_recarga_widget.dart';
import 'widgets/reporte_generico_widget.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Refresca para aplicar el nuevo color al indicador y letras
      }
    });
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
              isScrollable: true,
              // Propiedades para centrar las pestañas
              tabAlignment: TabAlignment.center, 
              
              // Colores dinámicos
              indicatorColor: activeColor,
              labelColor: activeColor,
              
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ReporteGeneralWidget(),
                ReporteRecargaWidget(),
                ReporteGenericoWidget(titulo: 'Gasto', colorAcento: Colors.deepOrange),
                ReporteGenericoWidget(titulo: 'Servicio', colorAcento: Color(0xFF795548)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}