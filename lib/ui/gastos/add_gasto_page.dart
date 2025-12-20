import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/movimiento_detalle.dart';
import '../../models/tipo_gasto.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../viewmodels/gasto_viewmodel.dart';
import '../../viewmodels/gasto_movimiento_viewmodel.dart';

class AddGastoPage extends StatefulWidget {
  const AddGastoPage({super.key});

  @override
  State<AddGastoPage> createState() => _AddGastoPageState();
}

class _AddGastoPageState extends State<AddGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometroCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final List<GastoDetalleForm> _detalles = [];

  // 🎨 COLORES SEGÚN IMÁGENES DE REFERENCIA
  static const Color orangeHeader = Color(0xFFFF5722); // Naranja de AppBar Gasto
  static const Color orangePrimary = Color(0xFFE64A19); // Naranja oscuro Status Bar
  static const Color grayIcons = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarUltimoKilometraje();
      context.read<GastoViewModel>().cargarGastos();
    });
  }

  @override
  void dispose() {
    _odometroCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  double get _total => _detalles.fold(0, (sum, d) => sum + d.subtotal);

  // ─────────────────────────────────────────────
  // FECHA / HORA
  // ─────────────────────────────────────────────
  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: orangeHeader),
        ),
        child: child!,
      ),
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: orangeHeader),
        ),
        child: child!,
      ),
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

  // ─────────────────────────────────────────────
  // GUARDAR
  // ─────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un gasto')),
      );
      return;
    }

    final vehiculoVM = context.read<VehiculoViewModel>();
    final gastoMovVM = context.read<GastoMovimientoViewmodel>();
    final vehiculo = vehiculoVM.vehiculoActivo;

    if (vehiculo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay vehículo activo')),
      );
      return;
    }

    await gastoMovVM.resgistrarGasto(
      vehiculoId: vehiculo.idVehiculo!,
      fecha: _fecha,
      odometro: double.tryParse(_odometroCtrl.text) ?? 0,
      observaciones: _obsCtrl.text,
      detalles: _detalles.map((d) => d.toMovimientoDetalle()).toList(),
    );

    await vehiculoVM.cargarUltimoKilometraje();

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────
  // SELECTOR DE GASTOS
  // ─────────────────────────────────────────────
  void _abrirSelectorGastos() async {
    final gastoVM = context.read<GastoViewModel>();

    final List<GastoDetalleForm>? seleccion =
        await Navigator.push<List<GastoDetalleForm>>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarGastosPage(
          gastos: gastoVM.gastos,
          actuales: _detalles,
        ),
      ),
    );

    if (seleccion != null) {
      setState(() {
        _detalles
          ..clear()
          ..addAll(seleccion);
      });
    }
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final ultimoKm = vehiculoVM.ultimoKilometraje;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: orangePrimary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: orangeHeader,
          elevation: 0,
          title: const Text('Gasto', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(icon: const Icon(Icons.check, color: Colors.white), onPressed: _guardar),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: grayIcons),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _picker('Fecha',
                          '${_fecha.day}/dic/${_fecha.year}', _pickFecha),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _picker('Hora', '${_hora.hour}:${_hora.minute.toString().padLeft(2, '0')}', _pickHora),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _odometroCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.shutter_speed_outlined, color: grayIcons),
                    labelText: 'Odómetro',
                    labelStyle: const TextStyle(color: Colors.grey),
                    helperText: 'Último: ${ultimoKm?.toInt() ?? 0} km',
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: orangeHeader)),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null) return 'Valor inválido';
                    if (ultimoKm != null && val < ultimoKm) {
                      return 'No puede ser menor a $ultimoKm km';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.attach_money, color: grayIcons),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          ..._detalles.map(_buildItemGasto),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _abrirSelectorGastos,
                              icon: const Icon(Icons.add, color: orangeHeader),
                              label: const Text('Tipo de gasto', style: TextStyle(color: orangeHeader, fontSize: 16)),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Costo total', style: TextStyle(fontSize: 16)),
                              Text('MXN ${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _obsCtrl,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.notes, color: grayIcons),
                    labelText: 'Observaciones',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: orangeHeader)),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemGasto(GastoDetalleForm d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(d.gasto.nombre, style: const TextStyle(fontSize: 16))),
          Row(
            children: [
              Text('MXN ${d.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _detalles.remove(d)),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _picker(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: orangeHeader)),
        ),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// SELECTOR DE GASTOS
/// ─────────────────────────────────────────────
class SeleccionarGastosPage extends StatefulWidget {
  final List<TipoGasto> gastos;
  final List<GastoDetalleForm> actuales;

  const SeleccionarGastosPage({
    super.key,
    required this.gastos,
    required this.actuales,
  });

  @override
  State<SeleccionarGastosPage> createState() =>
      _SeleccionarGastosPageState();
}

class _SeleccionarGastosPageState extends State<SeleccionarGastosPage> {
  late List<_GastoSeleccionable> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.gastos.map((g) {
      final previo = widget.actuales.where(
        (a) => a.gasto.idTipoGasto == g.idTipoGasto,
      );
      return _GastoSeleccionable(
        gasto: g,
        seleccionado: previo.isNotEmpty,
        precioInicial: previo.isNotEmpty ? previo.first.precio : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688), // Teal de la imagen del selector
        title: const Text('Tipos de gastos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final seleccion = _items.where((i) => i.seleccionado).map((i) {
                return GastoDetalleForm(
                  gasto: i.gasto,
                  precio: double.tryParse(i.precioCtrl.text) ?? 0,
                );
              }).toList();
              Navigator.pop(context, seleccion);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          return Column(
            children: [
              CheckboxListTile(
                title: Text(item.gasto.nombre),
                value: item.seleccionado,
                activeColor: const Color(0xFF009688),
                onChanged: (v) =>
                    setState(() => item.seleccionado = v ?? false),
              ),
              if (item.seleccionado)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 72, right: 16, bottom: 12),
                  child: TextField(
                    controller: item.precioCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(color: Color(0xFF009688)),
                      isDense: true,
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF009688))),
                    ),
                  ),
                ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}

// Estructura de modelo y helper de selección sin cambios...
class _GastoSeleccionable {
  final TipoGasto gasto;
  bool seleccionado;
  final TextEditingController precioCtrl;

  _GastoSeleccionable({
    required this.gasto,
    this.seleccionado = false,
    double? precioInicial,
  }) : precioCtrl =
            TextEditingController(text: precioInicial?.toString() ?? '');
}

class GastoDetalleForm {
  final TipoGasto gasto;
  double precio;
  double cantidad;

  GastoDetalleForm({
    required this.gasto,
    required this.precio,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;

  MovimientoDetalle toMovimientoDetalle() {
    return MovimientoDetalle(
      tipoDetalle: 'gasto',
      idReferencia: gasto.idTipoGasto,
      descripcion: gasto.nombre,
      cantidad: cantidad,
      precioUnitario: precio,
      subtotal: subtotal,
    );
  }
}