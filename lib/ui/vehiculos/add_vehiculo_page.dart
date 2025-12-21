import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Controladores
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _anio = TextEditingController();
  final _placas = TextEditingController();
  final _vin = TextEditingController();
  final _color = TextEditingController();
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
        odometroInicial: 0.0, // 👈 Insertado en cero automáticamente
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
    _tamanioTanque.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colores consistentes con tu app
    const primaryColor = Color(0xFF0288D1); 

    return Scaffold(
      appBar: widget.isFirst
          ? null
          : AppBar(
              title: const Text('Nuevo Vehículo'),
              centerTitle: true,
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isFirst) ...[
                  const Icon(Icons.directions_car_filled, size: 80, color: primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Registra tu primer vehículo para comenzar',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                
                // Sección: Información Básica
                _buildSectionTitle('Información Básica'),
                _buildField(
                  controller: _marca,
                  label: 'Marca',
                  icon: Icons.factory,
                  hint: 'Ej: Toyota',
                ),
                _buildField(
                  controller: _modelo,
                  label: 'Modelo',
                  icon: Icons.model_training,
                  hint: 'Ej: Corolla',
                ),
                _buildField(
                  controller: _anio,
                  label: 'Año',
                  icon: Icons.calendar_today,
                  hint: '2024',
                  isNumber: true,
                ),

                const SizedBox(height: 24),
                
                // Sección: Identificación
                _buildSectionTitle('Identificación'),
                _buildField(
                  controller: _placas,
                  label: 'Placas (opcional)',
                  icon: Icons.featured_play_list,
                  hint: 'ABC-123',
                ),
                _buildField(
                  controller: _vin,
                  label: 'VIN (Número de serie) (opcional)',
                  icon: Icons.fingerprint,
                  hint: '17 dígitos',
                ),

                const SizedBox(height: 24),
                
                // Sección: Detalles Técnicos
                _buildSectionTitle('Detalles Técnicos'),
                _buildField(
                  controller: _color,
                  label: 'Color (opcional)',
                  icon: Icons.palette,
                  hint: 'Blanco',
                ),
                _buildField(
                  controller: _tamanioTanque,
                  label: 'Capacidad del Tanque (L)',
                  icon: Icons.local_gas_station,
                  hint: '40',
                  isNumber: true,
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Finalizar Registro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
      ),
    );
  }
}