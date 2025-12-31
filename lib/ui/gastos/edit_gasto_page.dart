import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/movimiento_detalle.dart';
import '../../models/tipo_gasto.dart';
import '../../viewmodels/gasto_viewmodel.dart';
import '../../viewmodels/gasto_movimiento_viewmodel.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import 'add_tipo_gasto_page.dart';

class EditGastoPage extends StatefulWidget {
  final int idMovimiento;

  const EditGastoPage({super.key, required this.idMovimiento});

  @override
  State<EditGastoPage> createState() => _EditGastoPageState();
}

class _EditGastoPageState extends State<EditGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometroCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  // Se corrigió el tipo de la lista para que use la clase del formulario local
  final List<MovimientoDetalle> _detalles = [];
  bool _datosCargados = false;

  // 🎨 COLORES SEGÚN IMÁGENES DE REFERENCIA
  static const Color orangeHeader = Color(0xFFFF5722);
  static const Color orangePrimary = Color(0xFFE64A19);
  static const Color grayIcons = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gastoVM = context.read<GastoViewModel>();
      final gastoMovVM = context.read<GastoMovimientoViewmodel>();
      final vehiculoVM = context.read<VehiculoViewModel>();

      await gastoVM.cargarGastos();
      await gastoMovVM.prepararEdicion(widget.idMovimiento);

      final vehiculo = vehiculoVM.vehiculoActivo;
      final movimiento = gastoMovVM.movimientoSeleccionado;

      if (vehiculo != null && movimiento != null) {
        await gastoMovVM.calcularRangoOdometro(
          vehiculoId: vehiculo.idVehiculo!,
          fecha: movimiento.fecha,
        );
      }

      _cargarDatosIniciales();
    });
  }

  void _cargarDatosIniciales() {
    final gastoMovVM = context.read<GastoMovimientoViewmodel>();
    // final gastoVM = context.read<GastoViewModel>();

    // Obtenemos los datos cargados en el ViewModel
    final movimiento = gastoMovVM.movimientoSeleccionado;
    final detallesDB = gastoMovVM.detallesSeleccionados;

    if (movimiento == null || _datosCargados) return;

    setState(() {
      _fecha = movimiento.fecha;
      _hora = TimeOfDay.fromDateTime(movimiento.fecha);
      _odometroCtrl.text = movimiento.odometro.toStringAsFixed(0);
      _obsCtrl.text = movimiento.observaciones ?? '';

      _detalles.clear();
      for (var det in detallesDB) {
        _detalles.add(
          MovimientoDetalle(
            tipoDetalle: 'gasto',
            idReferencia: det.idReferencia, // 👈 Importante
            descripcion: det.descripcion,
            cantidad: 1.0,
            precioUnitario: det.precioUnitario,
            subtotal: det.precioUnitario,
          ),
        );
      }
      _datosCargados = true;
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
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: orangeHeader)),
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

    final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
    if (vehiculo != null) {
      context.read<GastoMovimientoViewmodel>().calcularRangoOdometro(
        vehiculoId: vehiculo.idVehiculo!,
        fecha: _fecha,
      );
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: orangeHeader)),
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
  // ACTUALIZAR (Modificado para usar ID)
  // ─────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un gasto')),
      );
      return;
    }

    final gastoMovVM = context.read<GastoMovimientoViewmodel>();

    // Se llama al nuevo método del ViewModel para actualizar
    // Busca esta sección en tu método _guardar
    await gastoMovVM.actualizarGasto(
      idMovimiento: widget.idMovimiento,
      fecha: _fecha,
      odometro: double.tryParse(_odometroCtrl.text) ?? 0,
      observaciones: _obsCtrl.text,
      detalles:
          _detalles, // 👈 Pasa la lista directamente, ya son MovimientoDetalle
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _abrirSelectorGastos() async {
    final gastoVM = context.read<GastoViewModel>();
    final List<MovimientoDetalle>? seleccion =
        await Navigator.push<List<MovimientoDetalle>>(
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

  @override
  Widget build(BuildContext context) {
    final gastoMovVM = context.watch<GastoMovimientoViewmodel>();
    final minKm = gastoMovVM.odometroMinPermitido;
    final maxKm = gastoMovVM.odometroMaxPermitido;

    if (gastoMovVM.isLoading && !_datosCargados) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: orangeHeader)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: orangePrimary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: orangeHeader,
          elevation: 0,
          title: const Text(
            'Editar Gasto',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _guardar,
            ),
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
                      child: _picker(
                        'Fecha',
                        '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        _pickFecha,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _picker(
                        'Hora',
                        '${_hora.hour}:${_hora.minute.toString().padLeft(2, '0')}',
                        _pickHora,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _odometroCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.shutter_speed_outlined,
                      color: grayIcons,
                    ),
                    labelText: 'Odómetro',
                    labelStyle: const TextStyle(color: Colors.grey),
                    helperText: _buildHelperKm(minKm, maxKm),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: orangeHeader),
                    ),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null) return 'Valor inválido';

                    if (minKm != null && val < minKm) {
                      return 'No puede ser menor a ${minKm.toInt()} km';
                    }
                    if (maxKm != null && val > maxKm) {
                      return 'No puede ser mayor a ${maxKm.toInt()} km';
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
                              label: const Text(
                                'Tipo de gasto',
                                style: TextStyle(
                                  color: orangeHeader,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Costo total',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'MXN ${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: orangeHeader),
                    ),
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

  String _buildHelperKm(double? min, double? max) {
    if (min == null && max == null) return '';

    if (min != null && max != null) {
      return 'Mín: ${min.toInt()} km · Máx: ${max.toInt()} km';
    }

    if (min != null) {
      return 'Mín: ${min.toInt()} km';
    }

    return 'Máx: ${max!.toInt()} km';
  }

  Widget _buildItemGasto(MovimientoDetalle d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              d.descripcion ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              Text(
                'MXN ${d.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
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
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: orangeHeader),
          ),
        ),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class SeleccionarGastosPage extends StatefulWidget {
  final List<TipoGasto> gastos;
  final List<MovimientoDetalle> actuales;

  const SeleccionarGastosPage({
    super.key,
    required this.gastos,
    required this.actuales,
  });

  @override
  State<SeleccionarGastosPage> createState() => _SeleccionarGastosPageState();
}

class _SeleccionarGastosPageState extends State<SeleccionarGastosPage> {
  List<_GastoSeleccionable> _items = [];

  @override
  void initState() {
    super.initState();
    _reconstruirItems(widget.gastos);
  }

  void _reconstruirItems(List<TipoGasto> gastos) {
    final previos = {for (final i in _items) i.gasto.idTipoGasto!: i};

    _items = gastos.map((g) {
      final previo = previos[g.idTipoGasto];
      final actual = widget.actuales.firstWhere(
        (a) => a.idReferencia == g.idTipoGasto,
        orElse: () => MovimientoDetalle(
          tipoDetalle: 'gasto',
          idReferencia: g.idTipoGasto,
          descripcion: g.nombre,
          cantidad: 1,
          precioUnitario: 0,
          subtotal: 0,
        ),
      );

      return _GastoSeleccionable(
        gasto: g,
        seleccionado: previo?.seleccionado ?? actual.precioUnitario > 0,
        precioInicial: previo != null && previo.precioCtrl.text.isNotEmpty
            ? double.tryParse(previo.precioCtrl.text)
            : actual.precioUnitario > 0
            ? actual.precioUnitario
            : null,
      );
    }).toList();
  }

  Future<void> _abrirNuevoGasto() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTipoGastoPage()),
    );

    if (ok == true && mounted) {
      final gastoVM = context.read<GastoViewModel>();
      await gastoVM.cargarGastos();
      setState(() => _reconstruirItems(gastoVM.gastos));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text('Tipos de gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final seleccion = _items.where((i) => i.seleccionado).map((i) {
                final precio = double.tryParse(i.precioCtrl.text) ?? 0;
                return MovimientoDetalle(
                  tipoDetalle: 'gasto',
                  idReferencia: i.gasto.idTipoGasto,
                  descripcion: i.gasto.nombre,
                  cantidad: 1.0,
                  precioUnitario: precio,
                  subtotal: precio,
                );
              }).toList();

              Navigator.pop(context, seleccion);
            },
          ),
        ],
      ),

      // 🔥 FAB NUEVO
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF009688),
        onPressed: _abrirNuevoGasto,
        child: const Icon(Icons.add),
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
                  padding: const EdgeInsets.only(
                    left: 72,
                    right: 16,
                    bottom: 12,
                  ),
                  child: TextField(
                    controller: item.precioCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      isDense: true,
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

class _GastoSeleccionable {
  final TipoGasto gasto;
  bool seleccionado;
  final TextEditingController precioCtrl;

  _GastoSeleccionable({
    required this.gasto,
    this.seleccionado = false,
    double? precioInicial,
  }) : precioCtrl = TextEditingController(
         text: precioInicial?.toString() ?? '',
       );
}
