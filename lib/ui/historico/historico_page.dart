import 'package:flutter/material.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Histórico',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
