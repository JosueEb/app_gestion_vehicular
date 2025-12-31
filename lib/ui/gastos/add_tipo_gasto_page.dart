import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gasto_viewmodel.dart';

class AddTipoGastoPage extends StatefulWidget {
  const AddTipoGastoPage({super.key});

  @override
  State<AddTipoGastoPage> createState() => _AddTipoGastoPageState();
}

class _AddTipoGastoPageState extends State<AddTipoGastoPage> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722), // naranja gasto
        title: const Text('Nuevo gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre del gasto',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    await context
        .read<GastoViewModel>()
        .crearGasto(_ctrl.text.trim());

    if (mounted) Navigator.pop(context, true);
  }
}
