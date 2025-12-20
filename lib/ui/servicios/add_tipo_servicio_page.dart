import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/servicio_viewmodel.dart';

class AddTipoServicioPage extends StatefulWidget {
  const AddTipoServicioPage({super.key});

  @override
  State<AddTipoServicioPage> createState() => _AddTipoServicioPageState();
}

class _AddTipoServicioPageState extends State<AddTipoServicioPage> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text('Nuevo servicio'),
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
              labelText: 'Nombre del servicio',
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Campo obligatorio' : null,
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ServicioViewModel>().crearServicio(_ctrl.text.trim());

    if (mounted) Navigator.pop(context, true);
  }
}
