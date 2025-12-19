import 'package:flutter/material.dart';

import '/ui/servicios/add_servicio_page.dart';
import '../historico/historico_page.dart';
import '../informes/informes_page.dart';
import '../recordatorios/recordatorios_page.dart';
import '../mas/mas_page.dart';
import 'widgets/bottom_menu.dart';
import '../shared/app_colors.dart';
import '../recargas/add_recarga_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Histórico',
    'Informes',
    '',
    'Recordatorios',
    'Más Opciones',
  ];

  final List<Widget> _pages = const [
    HistoricoPage(),
    InformesPage(),
    SizedBox(), // botón +
    RecordatoriosPage(),
    MasPage(),
  ];

  void _openAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AddItem(
                icon: Icons.build,
                label: 'Servicio',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddServicioPage()),
                  );
                },
              ),
              _AddItem(
                icon: Icons.attach_money,
                label: 'Gasto',
                onTap: () {
                  Navigator.pop(context);
                  // // TODO: navegar a agregar gasto
                },
              ),
              _AddItem(
                icon: Icons.local_gas_station,
                label: 'Recarga',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddRecargaPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) return;
          setState(() => _currentIndex = index);
        },
        onAdd: _openAddMenu,
      ),
    );
  }
}

class _AddItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
