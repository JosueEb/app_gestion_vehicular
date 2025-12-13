import 'package:flutter/material.dart';

class MasPage extends StatelessWidget {
  const MasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Más opciones',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
