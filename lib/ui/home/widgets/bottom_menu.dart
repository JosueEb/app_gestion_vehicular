import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const BottomMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          // Color del óvalo de selección
          indicatorColor: const Color(0xFFE0F7FA), 
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF006064),
              );
            }
            return const TextStyle(fontSize: 12, color: Colors.grey);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF006064));
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              onAdd(); // Botón central de acción
            } else {
              onTap(index);
            }
          },
          backgroundColor: Colors.white,
          height: 80,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Histórico',
            ),
            const NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Informes',
            ),
            // Botón central estilizado
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00ACC1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
              label: '',
            ),
            const NavigationDestination(
              icon: Icon(Icons.alarm),
              label: 'Recordatorio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.more_horiz),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}