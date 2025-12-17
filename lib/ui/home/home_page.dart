import 'package:flutter/material.dart';

import '../historico/historico_page.dart';
import '../informes/informes_page.dart';
import '../recordatorios/recordatorios_page.dart';
import '../mas/mas_page.dart';
import 'widgets/bottom_menu.dart';
import 'widgets/home_header.dart';

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
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _AddItem(icon: Icons.build, label: 'Servicio'),
            _AddItem(icon: Icons.local_gas_station, label: 'Combustible'),
            _AddItem(icon: Icons.attach_money, label: 'Gasto'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
          HomeHeader(
            title: _titles[_currentIndex],
            ),
          Expanded(child: _pages[_currentIndex]),
          BottomMenu(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 2) return;
              setState(() => _currentIndex = index);
            },
            onAdd: _openAddMenu,
          ),
        ],
      ),
    ),
    );
  }
}

class _AddItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AddItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label));
  }
}
