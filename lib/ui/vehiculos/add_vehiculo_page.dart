import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vehiculo.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../home/home_page.dart';

class AddVehiculoPage extends StatefulWidget {
  final bool isFirst;

  const AddVehiculoPage({super.key, this.isFirst = false});

  @override
  State<AddVehiculoPage> createState() => _AddVehiculoPageState();
}

class _AddVehiculoPageState extends State<AddVehiculoPage> {
  final _formKey = GlobalKey<FormState>();

  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _anio = TextEditingController();
  final _placas = TextEditingController();
  final _vin = TextEditingController();
  final _color = TextEditingController();
  final _odometroInicial = TextEditingController();
  final _tamanioTanque = TextEditingController();


  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<VehiculoViewModel>();

    await vm.agregarVehiculo(
      Vehiculo(
        marca: _marca.text,
        modelo: _modelo.text,
        anio: int.parse(_anio.text),
        placas: _placas.text,
        vin: _vin.text,
        color: _color.text,
        odometroInicial: double.parse(_odometroInicial.text),
        tamanioTanque: int.parse(_tamanioTanque.text),
      ),
    );

    if (!mounted) return;

    if (widget.isFirst) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _anio.dispose();
    _placas.dispose();
    _vin.dispose();
    _color.dispose();
    _odometroInicial.dispose();
    _tamanioTanque.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFirst
          ? null
          : AppBar(
              title: const Text('Agregar vehículo'),
              backgroundColor: const Color.fromARGB(255, 196, 236, 255),
              surfaceTintColor: Colors.transparent,
            ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Registra tu vehículo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _marca,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _modelo,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _anio,
                  decoration: const InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _placas,
                  decoration: const InputDecoration(labelText: 'Placas'),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _vin,
                  decoration: const InputDecoration(labelText: 'VIN'),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _color,
                  decoration: const InputDecoration(labelText: 'Color'),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _odometroInicial,
                  decoration: const InputDecoration(
                    labelText: 'Odómetro actual',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _tamanioTanque,
                  decoration: const InputDecoration(
                    labelText: 'Tamaño del tanque',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar vehículo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
