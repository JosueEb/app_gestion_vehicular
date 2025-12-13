import 'package:flutter/material.dart';

class InformesPage extends StatelessWidget {
  const InformesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Informes',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
