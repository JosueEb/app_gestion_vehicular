import 'package:app_gestion_vehicular/viewmodels/combustible_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  bool _tanqueLleno = true;
  bool _precioInicialAsignado = false;

  /// 🔒 Flag anti-loop para los listeners
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();

    _precioCtrl.addListener(_onPrecioChanged);
    _litrosCtrl.addListener(_onLitrosChanged);
    _totalCtrl.addListener(_onTotalChanged);

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

  // ───────────────── LISTENERS ─────────────────

  void _onPrecioChanged() {
    if (_actualizando) return;
    _actualizando = true;
    _recalcularTotal();
    _actualizando = false;
  }

  void _onLitrosChanged() {
    if (_actualizando) return;
    _actualizando = true;
    _recalcularTotal();
    _actualizando = false;
  }

  void _onTotalChanged() {
    if (_actualizando) return;
    _actualizando = true;
    _recalcularLitros();
    _actualizando = false;
  }

  // ───────────────── CÁLCULOS ─────────────────

  void _recalcularTotal() {
    final litros = double.tryParse(_litrosCtrl.text);
    final precio = double.tryParse(_precioCtrl.text);

    if (litros != null && precio != null && litros > 0 && precio > 0) {
      _totalCtrl.text = (litros * precio).toStringAsFixed(2);
    }
  }

  void _recalcularLitros() {
    final total = double.tryParse(_totalCtrl.text);
    final precio = double.tryParse(_precioCtrl.text);

    if (total != null && precio != null && precio > 0) {
      _litrosCtrl.text = (total / precio).toStringAsFixed(2);
    }
  }

  // ───────────────── FECHA / HORA ─────────────────

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

  // ───────────────── GUARDAR ─────────────────

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final recargaVM = context.read<RecargaViewModel>();
    final vehiculoVM = context.read<VehiculoViewModel>();
    final combustibleVM = context.read<CombustibleViewModel>();

    final vehiculo = vehiculoVM.vehiculoActivo;
    final combustible = combustibleVM.combustibleActivo;

    if (vehiculo == null || combustible == null) return;

    await recargaVM.registrarRecarga(
      vehiculoId: vehiculo.idVehiculo!,
      fecha: _fecha,
      litros: double.parse(_litrosCtrl.text),
      precioUnitario: double.parse(_precioCtrl.text),
      odometro: double.parse(_odometroCtrl.text),
      idCombustible: combustible.idCombustible!,
      observaciones: _obsCtrl.text,
      tanqueLleno: _tanqueLleno,
      descripcion: combustibleVM.combustibleActivo!.nombre,
    );

    await vehiculoVM.cargarUltimoKilometraje();
    if (mounted) Navigator.pop(context);
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final combustibleVM = context.watch<CombustibleViewModel>();
    final recargaVM = context.watch<RecargaViewModel>();

    final ultimoKm = vehiculoVM.ultimoKilometraje;
    final ultimoPrecio = combustibleVM.ultimoCostoLitro;

    if (!_precioInicialAsignado && ultimoPrecio != null) {
      _precioCtrl.text = ultimoPrecio.toStringAsFixed(2);
      _precioInicialAsignado = true;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Recarga', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: recargaVM.isLoading ? null : _guardar,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FECHA Y HORA CON ÍCONO
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInlinePicker(
                        label: 'Fecha',
                        value: '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        onTap: _pickFecha,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInlinePicker(
                        label: 'Hora',
                        value: _hora.format(context),
                        onTap: _pickHora,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // ODÓMETRO CON ÍCONO
                TextFormField(
                  controller: _odometroCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.shutter_speed_outlined, color: Colors.grey, size: 28),
                    labelText: 'Odómetro',
                    helperText: 'Último: ${ultimoKm ?? 0} km',
                  ),
                ),
                const SizedBox(height: 20),

                // COMBUSTIBLE CON ÍCONO
                DropdownButtonFormField<Combustible>(
                  value: combustibleVM.combustibleActivo,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.gas_meter_outlined, color: Colors.grey, size: 28),
                    labelText: 'Combustible',
                  ),
                  items: combustibleVM.combustibles
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.nombre)))
                      .toList(),
                  onChanged: (c) {
                    if (c != null) {
                      combustibleVM.seleccionarCombustible(c);
                      _precioInicialAsignado = false;
                      combustibleVM.obtenerUltimoCostoLitro();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // FILA DE PRECIOS Y LITROS CON ÍCONO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.payments_outlined, color: Colors.grey, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _precioCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Precio / L'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _totalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Costo total'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _litrosCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Litros'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // TANQUE LLENO CON ÍCONO
                Row(
                  children: [
                    const Icon(Icons.gas_meter_rounded, color: Colors.grey, size: 28),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('¿Está llenando el tanque?', style: TextStyle(fontSize: 16)),
                    ),
                    Switch(
                      value: _tanqueLleno,
                      activeColor: Colors.orange,
                      onChanged: (v) => setState(() => _tanqueLleno = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlinePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.only(bottom: 8),
        ),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}