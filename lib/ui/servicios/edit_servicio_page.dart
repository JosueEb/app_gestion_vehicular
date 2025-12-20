import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/movimiento_detalle.dart';
import '../../models/tipo_servicio.dart';
import '../../viewmodels/servicio_viewmodel.dart';
import '../../viewmodels/servicio_movimiento_viewmodel.dart';

class EditServicioPage extends StatefulWidget {
  final int idMovimiento;

  const EditServicioPage({super.key, required this.idMovimiento});

  @override
  State<EditServicioPage> createState() => _EditServicioPageState();
}

class _EditServicioPageState extends State<EditServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometroCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final List<MovimientoDetalle> _detalles = [];
  bool _datosCargados = false;

  // 🎨 COLORES DE LA UI DE SERVICIO (Café)
  static const Color servicioHeader = Color(0xFF8D6E63);
  static const Color servicioPrimary = Color(0xFF5D4037);
  static const Color grayIcons = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final servicioVM = context.read<ServicioViewModel>();
      final servicioMovVM = context.read<ServicioMovimientoViewModel>();

      await servicioVM.cargarServicios();
      await servicioMovVM.prepararEdicion(widget.idMovimiento);

      _cargarDatosIniciales();
    });
  }

  void _cargarDatosIniciales() {
    final servicioMovVM = context.read<ServicioMovimientoViewModel>();
    final movimiento = servicioMovVM.movimientoSeleccionado;
    final detallesDB = servicioMovVM.detallesSeleccionados;

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
            tipoDetalle: 'servicio',
            idReferencia: det.idReferencia,
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

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: servicioHeader),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fecha = DateTime(picked.year, picked.month, picked.day, _hora.hour, _hora.minute);
      });
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: servicioHeader),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _hora = picked;
        _fecha = DateTime(_fecha.year, _fecha.month, _fecha.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un servicio')),
      );
      return;
    }

    final servicioMovVM = context.read<ServicioMovimientoViewModel>();

    await servicioMovVM.actualizarServicio(
      idMovimiento: widget.idMovimiento,
      fecha: _fecha,
      odometro: double.tryParse(_odometroCtrl.text) ?? 0,
      observaciones: _obsCtrl.text,
      detalles: _detalles,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _abrirSelectorServicios() async {
    final servicioVM = context.read<ServicioViewModel>();
    final List<MovimientoDetalle>? seleccion = await Navigator.push<List<MovimientoDetalle>>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarServiciosPage(
          servicios: servicioVM.servicios,
          actuales: _detalles,
        ),
      ),
    );
    if (seleccion != null) {
      setState(() {
        _detalles..clear()..addAll(seleccion);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicioMovVM = context.watch<ServicioMovimientoViewModel>();

    if (servicioMovVM.isLoading && !_datosCargados) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: servicioHeader)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: servicioPrimary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: servicioHeader,
          elevation: 0,
          title: const Text('Editar Servicio', style: TextStyle(color: Colors.white)),
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
                    Expanded(child: _picker('Fecha', '${_fecha.day}/${_fecha.month}/${_fecha.year}', _pickFecha)),
                    const SizedBox(width: 12),
                    Expanded(child: _picker('Hora', _hora.format(context), _pickHora)),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _odometroCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.shutter_speed_outlined, color: grayIcons),
                    labelText: 'Odómetro',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: servicioHeader)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.build_outlined, color: grayIcons),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          ..._detalles.map(_buildItemServicio),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _abrirSelectorServicios,
                              icon: const Icon(Icons.add, color: servicioHeader),
                              label: const Text('Tipo de servicio', style: TextStyle(color: servicioHeader, fontSize: 16)),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Costo total', style: TextStyle(fontSize: 16)),
                              Text(
                                'MXN ${_total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: servicioHeader)),
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

  Widget _buildItemServicio(MovimientoDetalle d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(d.descripcion ?? '', style: const TextStyle(fontSize: 16))),
          Row(
            children: [
              Text('MXN ${d.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
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
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: servicioHeader)),
        ),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SELECTOR DE SERVICIOS (UI TEAL)
// ─────────────────────────────────────────────────────
class SeleccionarServiciosPage extends StatefulWidget {
  final List<TipoServicio> servicios;
  final List<MovimientoDetalle> actuales;

  const SeleccionarServiciosPage({super.key, required this.servicios, required this.actuales});

  @override
  State<SeleccionarServiciosPage> createState() => _SeleccionarServiciosPageState();
}

class _SeleccionarServiciosPageState extends State<SeleccionarServiciosPage> {
  late List<_ServicioSeleccionable> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.servicios.map((s) {
      final previo = widget.actuales.where((a) => a.idReferencia == s.idTipoServicio);
      return _ServicioSeleccionable(
        servicio: s,
        seleccionado: previo.isNotEmpty,
        precioInicial: previo.isNotEmpty ? previo.first.precioUnitario : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text('Tipos de servicios', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final seleccion = _items.where((i) => i.seleccionado).map((i) {
                final precio = double.tryParse(i.precioCtrl.text) ?? 0;
                return MovimientoDetalle(
                  tipoDetalle: 'servicio',
                  idReferencia: i.servicio.idTipoServicio,
                  descripcion: i.servicio.nombre,
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
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          return Column(
            children: [
              CheckboxListTile(
                title: Text(item.servicio.nombre),
                value: item.seleccionado,
                activeColor: const Color(0xFF009688),
                onChanged: (v) => setState(() => item.seleccionado = v ?? false),
              ),
              if (item.seleccionado)
                Padding(
                  padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
                  child: TextField(
                    controller: item.precioCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(color: Color(0xFF009688)),
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

class _ServicioSeleccionable {
  final TipoServicio servicio;
  bool seleccionado;
  final TextEditingController precioCtrl;

  _ServicioSeleccionable({required this.servicio, this.seleccionado = false, double? precioInicial})
      : precioCtrl = TextEditingController(text: precioInicial?.toString() ?? '');
}