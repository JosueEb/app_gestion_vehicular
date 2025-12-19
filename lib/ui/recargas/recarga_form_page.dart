import 'package:flutter/material.dart';

class RecargaFormPage extends StatelessWidget {
  final int? idMovimiento;

  const RecargaFormPage({super.key, this.idMovimiento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          idMovimiento == null ? 'Nueva recarga' : 'Editar recarga',
        ),
      ),
      body: const Center(
        child: Text('Formulario de recarga (pendiente)'),
      ),
    );
  }
}
