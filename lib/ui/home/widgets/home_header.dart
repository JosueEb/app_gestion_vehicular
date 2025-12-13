import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: const ExcludeSemantics(
        child: Text(
          'Gestión Vehicular',
          style: TextStyle(
            fontSize: 22,
            color: Colors.green,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
