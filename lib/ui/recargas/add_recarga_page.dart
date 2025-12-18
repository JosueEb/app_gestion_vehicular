import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../shared/app_colors.dart';
import '../../viewmodels/recarga_viewmodel.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';

class AddRecargaPage extends StatefulWidget {
  const AddRecargaPage({super.key});

  @override
  State<AddRecargaPage> createState() => _AddRecargaPageState();
}

class _AddRecargaPageState extends State<AddRecargaPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarUltimoKilometraje();
    });
  }

  final _formKey = GlobalKey<FormState>();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final _odometroCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _litrosCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _tanqueLleno = false;

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
    final picked = await showTimePicker(context: context, initialTime: _hora);

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

    final total = litros * precio;
    _totalCtrl.text = total.toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final recargaVM = context.read<RecargaViewModel>();
    final vehiculoVM = context.read<VehiculoViewModel>();

    final vehiculoActivo = vehiculoVM.vehiculoActivo;

    if (vehiculoActivo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay vehículo activo')));
      return;
    }

    await recargaVM.registrarRecarga(
      vehiculoId: vehiculoActivo.idVehiculo!,
      fecha: _fecha,
      litros: double.parse(_litrosCtrl.text),
      precioUnitario: double.parse(_precioCtrl.text),
      odometro: double.parse(_odometroCtrl.text),
      idCombustible: 1,
      observaciones: _obsCtrl.text,
      tanqueLleno: _tanqueLleno,
    );

    // 🔁 refrescar kilometraje
    await vehiculoVM.cargarUltimoKilometraje();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecargaViewModel>();
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final ultimoKm = vehiculoVM.ultimoKilometraje;
    // final vehiculoActivo = vehiculoVM.vehiculoActivo;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.headerNotificationBarRecarga,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _odometroCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Odómetro',
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo requerido';
                        }

                        final actual = double.tryParse(v);
                        if (actual == null) {
                          return 'Valor inválido';
                        }

                        if (ultimoKm != null && actual < ultimoKm) {
                          return 'No puede ser menor a $ultimoKm km';
                        }

                        return null;
                      },
                    ),

                    if (ultimoKm != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Último registrado: $ultimoKm km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),

                /// PRECIO POR LITRO
                TextFormField(
                  controller: _precioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio por litro',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcularTotal(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),

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
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    prefixText: '\$ ',
                  ),
                  readOnly: true,
                ),

                const SizedBox(height: 12),

                /// TANQUE LLENO
                SwitchListTile(
                  title: const Text('Tanque lleno'),
                  //color
                  activeColor: AppColors.headerBackgroundRecarga,
                  value: _tanqueLleno,
                  onChanged: (v) => setState(() => _tanqueLleno = v),
                ),

                /// OBSERVACIONES
                TextFormField(
                  controller: _obsCtrl,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                /// GUARDAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _guardar,
                    child: vm.isLoading
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
