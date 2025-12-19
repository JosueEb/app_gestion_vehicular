import 'package:app_gestion_vehicular/viewmodels/combustible_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../shared/app_colors.dart';
import '../../viewmodels/recarga_viewmodel.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../models/combustible.dart';

class AddRecargaPage extends StatefulWidget {
  const AddRecargaPage({super.key});

  @override
  State<AddRecargaPage> createState() => _AddRecargaPageState();
}

class _AddRecargaPageState extends State<AddRecargaPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final _odometroCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _litrosCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _tanqueLleno = false;
  bool _precioInicialAsignado = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarUltimoKilometraje();
      context.read<CombustibleViewModel>().cargarCombustibles();
      context.read<CombustibleViewModel>().obtenerUltimoCostoLitro();
    });
  }

  @override
  void dispose() {
    _odometroCtrl.dispose();
    _precioCtrl.dispose();
    _litrosCtrl.dispose();
    _totalCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fecha = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _hora.hour,
          _hora.minute,
        );
      });
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora,
    );

    if (picked != null) {
      setState(() {
        _hora = picked;
        _fecha = DateTime(
          _fecha.year,
          _fecha.month,
          _fecha.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _recalcularTotal() {
    final litros = double.tryParse(_litrosCtrl.text) ?? 0;
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    _totalCtrl.text = (litros * precio).toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final recargaVM = context.read<RecargaViewModel>();
    final vehiculoVM = context.read<VehiculoViewModel>();
    final combustibleVM = context.read<CombustibleViewModel>();

    final vehiculoActivo = vehiculoVM.vehiculoActivo;
    final combustible = combustibleVM.combustibleActivo;

    if (vehiculoActivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay vehículo activo')),
      );
      return;
    }

    if (combustible == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un combustible')),
      );
      return;
    }

    await recargaVM.registrarRecarga(
      vehiculoId: vehiculoActivo.idVehiculo!,
      fecha: _fecha,
      litros: double.parse(_litrosCtrl.text),
      precioUnitario: double.parse(_precioCtrl.text),
      odometro: double.parse(_odometroCtrl.text),
      idCombustible: combustible.idCombustible!,
      observaciones: _obsCtrl.text,
      tanqueLleno: _tanqueLleno,
    );

    await vehiculoVM.cargarUltimoKilometraje();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final recargaVM = context.watch<RecargaViewModel>();
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final combustibleVM = context.watch<CombustibleViewModel>();

    final ultimoPrecio = combustibleVM.ultimoCostoLitro;
    final ultimoKm = vehiculoVM.ultimoKilometraje;

    // Precargar último precio SOLO una vez
    if (!_precioInicialAsignado && ultimoPrecio != null) {
      _precioCtrl.text = ultimoPrecio.toStringAsFixed(2);
      _precioInicialAsignado = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalcularTotal();
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.headerNotificationBarRecarga,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headerBackgroundRecarga,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('Registrar recarga'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// FECHA Y HORA
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: 'Fecha',
                        value: '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        icon: Icons.calendar_today,
                        onTap: _pickFecha,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerField(
                        label: 'Hora',
                        value: _hora.format(context),
                        icon: Icons.access_time,
                        onTap: _pickHora,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ODÓMETRO
                TextFormField(
                  controller: _odometroCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Odómetro',
                    suffixText: 'km',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    final actual = double.tryParse(v);
                    if (actual == null) return 'Valor inválido';
                    if (ultimoKm != null && actual < ultimoKm) {
                      return 'No puede ser menor a $ultimoKm km';
                    }
                    return null;
                  },
                ),

                if (ultimoKm != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Último registrado: $ultimoKm km',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 12),

                /// COMBUSTIBLE
                Consumer<CombustibleViewModel>(
                  builder: (_, vm, __) {
                    return DropdownButtonFormField<Combustible>(
                      value: vm.combustibleActivo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de combustible',
                        border: OutlineInputBorder(),
                      ),
                      items: vm.combustibles
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (c) {
                        if (c != null) {
                          vm.seleccionarCombustible(c);
                          _precioInicialAsignado = false;
                          vm.obtenerUltimoCostoLitro();
                        }
                      },
                      validator: (v) =>
                          v == null ? 'Seleccione un combustible' : null,
                    );
                  },
                ),

                const SizedBox(height: 12),

                /// PRECIO
                TextFormField(
                  controller: _precioCtrl,
                  decoration: InputDecoration(
                    labelText: 'Precio por litro',
                    prefixText: '\$ ',
                    helperText: ultimoPrecio != null
                        ? 'Último precio registrado'
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcularTotal(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),

                const SizedBox(height: 12),

                /// LITROS
                TextFormField(
                  controller: _litrosCtrl,
                  decoration: const InputDecoration(labelText: 'Litros'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcularTotal(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),

                /// TOTAL
                TextFormField(
                  controller: _totalCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    prefixText: '\$ ',
                  ),
                ),

                const SizedBox(height: 12),

                /// TANQUE LLENO
                SwitchListTile(
                  title: const Text('Tanque lleno'),
                  activeColor: AppColors.headerBackgroundRecarga,
                  value: _tanqueLleno,
                  onChanged: (v) => setState(() => _tanqueLleno = v),
                ),

                /// OBSERVACIONES
                TextFormField(
                  controller: _obsCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                /// GUARDAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        recargaVM.isLoading ? null : _guardar,
                    child: recargaVM.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Guardar recarga'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}
