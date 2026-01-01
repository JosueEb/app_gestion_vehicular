import 'package:app_gestion_vehicular/viewmodels/combustible_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/recarga_viewmodel.dart';
import '../../models/combustible.dart';

class RecargaFormPage extends StatefulWidget {
  final int idMovimiento;

  const RecargaFormPage({super.key, required this.idMovimiento});

  @override
  State<RecargaFormPage> createState() => _RecargaFormPageState();
}

class _RecargaFormPageState extends State<RecargaFormPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final _odometroCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _litrosCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _tanqueLleno = true;
  bool _datosCargados = false;
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();

    _precioCtrl.addListener(_onPrecioChanged);
    _litrosCtrl.addListener(_onLitrosChanged);
    _totalCtrl.addListener(_onTotalChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recargaVM = context.read<RecargaViewModel>();
      final combustibleVM = context.read<CombustibleViewModel>();

      await recargaVM.prepararEdicion(widget.idMovimiento);
      await combustibleVM.cargarCombustibles();

      _cargarDatosIniciales();
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

  // ───────────────── CARGA INICIAL ─────────────────

  void _cargarDatosIniciales() {
    if (_datosCargados) return;

    final recargaVM = context.read<RecargaViewModel>();
    final combustibleVM = context.read<CombustibleViewModel>();
    final recarga = recargaVM.recargaSeleccionada;

    if (recarga == null || combustibleVM.combustibles.isEmpty) return;

    _actualizando = true;

    _fecha = DateTime.parse(recarga['fecha']);
    _hora = TimeOfDay.fromDateTime(_fecha);
    _odometroCtrl.text = recarga['odometro'].toString();
    _precioCtrl.text = recarga['precio_unitario'].toString();
    _litrosCtrl.text = recarga['cantidad'].toString();
    _totalCtrl.text = recarga['total'].toString();
    _obsCtrl.text = recarga['observaciones'] ?? '';
    _tanqueLleno = recarga['tanque_lleno'] == 1;

    final idCombustible = recarga['id_combustible'];
    try {
      final combustibleMatch = combustibleVM.combustibles.firstWhere(
        (c) => c.idCombustible == idCombustible,
      );
      combustibleVM.seleccionarCombustible(combustibleMatch);
    } catch (_) {}

    _datosCargados = true;
    _actualizando = false;

    // 🔥 calcular rango inicial
    recargaVM.calcularRangoOdometroSoloFecha(_fecha);

    if (mounted) setState(() {});
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

      // 🔥 recalcular rango
      await context
          .read<RecargaViewModel>()
          .calcularRangoOdometroSoloFecha(_fecha);
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

  // ───────────────── ACTUALIZAR ─────────────────

  Future<void> _actualizar() async {
    if (!_formKey.currentState!.validate()) return;

    final recargaVM = context.read<RecargaViewModel>();
    final combustibleVM = context.read<CombustibleViewModel>();

    final recarga = recargaVM.recargaSeleccionada;
    final combustible = combustibleVM.combustibleActivo;

    if (recarga == null || combustible == null) return;

    await recargaVM.actualizarRecarga(
      idMovimiento: widget.idMovimiento,
      vehiculoId: recarga['id_vehiculo'],
      fecha: _fecha,
      litros: double.parse(_litrosCtrl.text),
      precioUnitario: double.parse(_precioCtrl.text),
      odometro: double.parse(_odometroCtrl.text),
      idCombustible: combustible.idCombustible!,
      observaciones: _obsCtrl.text,
      tanqueLleno: _tanqueLleno,
      descripcion: combustible.nombre,
    );

    if (mounted) Navigator.pop(context);
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final recargaVM = context.watch<RecargaViewModel>();
    final combustibleVM = context.watch<CombustibleViewModel>();

    final minKm = recargaVM.odometroMinPermitido;
    final maxKm = recargaVM.odometroMaxPermitido;

    if (recargaVM.isLoading && !_datosCargados) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('Editar recarga', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: recargaVM.isLoading ? null : _actualizar,
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

                TextFormField(
                  controller: _odometroCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.shutter_speed_outlined, color: Colors.grey, size: 28),
                    labelText: 'Odómetro',
                    helperText: _buildHelperKm(minKm, maxKm),
                  ),
                  validator: (value) {
                    final km = double.tryParse(value ?? '');
                    if (km == null) return 'Ingrese un valor válido';
                    if (minKm != null && km < minKm) return 'Debe ser ≥ $minKm km';
                    if (maxKm != null && km > maxKm) return 'Debe ser ≤ $maxKm km';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

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
                    if (c != null) combustibleVM.seleccionarCombustible(c);
                  },
                ),

                const SizedBox(height: 20),

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
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _buildHelperKm(double? min, double? max) {
    if (min != null && max != null) {
      return 'Permitido entre $min y $max km';
    }
    if (min != null) return 'Mínimo permitido: $min km';
    if (max != null) return 'Máximo permitido: $max km';
    return '';
  }
}
