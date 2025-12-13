import 'package:flutter/material.dart';

class RecordatoriosPage extends StatelessWidget {
  const RecordatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Recordatorios',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
