import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/movimiento_detalle.dart';
import '../../models/tipo_servicio.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../viewmodels/servicio_viewmodel.dart';
import '../../viewmodels/servicio_movimiento_viewmodel.dart';
import 'add_tipo_servicio_page.dart';

class AddServicioPage extends StatefulWidget {
  const AddServicioPage({super.key});

  @override
  State<AddServicioPage> createState() => _AddServicioPageState();
}

class _AddServicioPageState extends State<AddServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometroCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final List<ServicioDetalleForm> _detalles = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehiculoVM = context.read<VehiculoViewModel>();
      final servicioMovVM = context.read<ServicioMovimientoViewModel>();

      vehiculoVM.cargarUltimoKilometraje();
      context.read<ServicioViewModel>().cargarServicios();

      final vehiculo = vehiculoVM.vehiculoActivo;
      if (vehiculo != null) {
        servicioMovVM.calcularRangoOdometro(
          vehiculoId: vehiculo.idVehiculo!,
          fecha: _fecha,
        );
      }
    });
  }

  @override
  void dispose() {
    _odometroCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  double get _total => _detalles.fold(0, (sum, d) => sum + d.subtotal);

  // ─────────────────────────────────────────────────────
  // FECHA / HORA
  // ─────────────────────────────────────────────────────
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

      final vehiculo = context.read<VehiculoViewModel>().vehiculoActivo;
      if (vehiculo != null) {
        context.read<ServicioMovimientoViewModel>().calcularRangoOdometro(
          vehiculoId: vehiculo.idVehiculo!,
          fecha: _fecha,
        );
      }
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

  // ─────────────────────────────────────────────────────
  // GUARDAR (MISMA LÓGICA FUNCIONAL)
  // ─────────────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un servicio')),
      );
      return;
    }

    final vehiculoVM = context.read<VehiculoViewModel>();
    final servicioMovVM = context.read<ServicioMovimientoViewModel>();
    final vehiculo = vehiculoVM.vehiculoActivo;

    if (vehiculo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay vehículo activo')));
      return;
    }

    await servicioMovVM.registrarServicio(
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

  // ─────────────────────────────────────────────────────
  // MODAL SELECTOR DE SERVICIOS (NUEVA UI)
  // ─────────────────────────────────────────────────────
  void _abrirSelectorServicios() async {
    final servicioVM = context.read<ServicioViewModel>();

    // Navegar a la nueva página completa
    final List<ServicioDetalleForm>? seleccion =
        await Navigator.push<List<ServicioDetalleForm>>(
          context,
          MaterialPageRoute(
            builder: (context) => SeleccionarServiciosPage(
              servicios: servicioVM.servicios,
              actuales: _detalles,
            ),
          ),
        );

    if (seleccion != null) {
      setState(() {
        // Reemplazamos la lista completa con la nueva selección de la página
        _detalles.clear();
        _detalles.addAll(seleccion);
      });
    }
  }

  // Future<double?> _mostrarInputPrecio({required String nombreServicio}) async {
  //   final precioCtrl = TextEditingController();

  //   return showDialog<double>(
  //     context: context,
  //     barrierDismissible: false, // Obliga a elegir o cancelar
  //     builder: (context) => AlertDialog(
  //       title: Text('Precio de $nombreServicio'),
  //       content: TextField(
  //         controller: precioCtrl,
  //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //         autofocus: true,
  //         decoration: const InputDecoration(
  //           labelText: 'Costo total',
  //           prefixText: 'MXN ',
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             final val = double.tryParse(precioCtrl.text);
  //             if (val != null) Navigator.pop(context, val);
  //           },
  //           child: const Text(
  //             'ACEPTAR',
  //             style: TextStyle(color: Color(0xFF8D6E63)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ─────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final ultimoKm = vehiculoVM.ultimoKilometraje;
    final servicioMovVM = context.watch<ServicioMovimientoViewModel>();

    final minKm = servicioMovVM.odometroMinPermitido;
    final maxKm = servicioMovVM.odometroMaxPermitido;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF5D4037),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF8D6E63),
          title: const Text('Servicio'),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: _guardar),
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
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUnderlinePicker(
                        'Fecha',
                        '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        _pickFecha,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUnderlinePicker(
                        'Hora',
                        _hora.format(context),
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
                    icon: const Icon(Icons.shutter_speed_outlined),
                    labelText: 'Odómetro',
                    helperText: _buildHelperKm(
                      minKm,
                      maxKm,
                      ultimoKm?.toDouble(),
                    ),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null) return 'Valor inválido';

                    if (minKm != null && val < minKm) {
                      return 'Debe ser ≥ ${minKm.toInt()} km';
                    }

                    if (maxKm != null && val > maxKm) {
                      return 'Debe ser ≤ ${maxKm.toInt()} km';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.build_outlined),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          ..._detalles.map(_buildItemServicio),
                          TextButton.icon(
                            onPressed: _abrirSelectorServicios,
                            icon: const Icon(Icons.add),
                            label: const Text('Tipo de servicio'),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Costo total'),
                              Text('MXN ${_total.toStringAsFixed(2)}'),
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
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildHelperKm(double? min, double? max, double? ultimo) {
    if (min != null && max != null) {
      return 'Entre ${min.toInt()} y ${max.toInt()} km';
    }
    if (min != null) return 'Mínimo ${min.toInt()} km';
    if (max != null) return 'Máximo ${max.toInt()} km';
    return 'Último: ${ultimo ?? 0} km';
  }

  Widget _buildItemServicio(ServicioDetalleForm d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nombre del servicio a la izquierda
              Expanded(
                child: Text(
                  d.servicio.nombre,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              // Precio y Botón de borrar a la derecha
              Row(
                children: [
                  Text(
                    'MXN ${d.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _detalles.remove(d)),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlinePicker(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────
/// MODELO UI
/// ─────────────────────────────────────────────────────
class ServicioDetalleForm {
  final TipoServicio servicio;
  double precio;
  double cantidad;

  ServicioDetalleForm({
    required this.servicio,
    required this.precio,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;

  MovimientoDetalle toMovimientoDetalle() {
    return MovimientoDetalle(
      tipoDetalle: 'servicio',
      idReferencia: servicio.idTipoServicio,
      descripcion: servicio.nombre,
      cantidad: cantidad,
      precioUnitario: precio,
      subtotal: subtotal,
    );
  }
}

class _ServiciosModal extends StatefulWidget {
  final List<TipoServicio> servicios;
  final List<int?> inicialesIds;
  final Function(List<TipoServicio>) onConfirm;

  const _ServiciosModal({
    required this.servicios,
    required this.inicialesIds,
    required this.onConfirm,
  });

  @override
  State<_ServiciosModal> createState() => _ServiciosModalState();
}

class _ServiciosModalState extends State<_ServiciosModal> {
  late List<TipoServicio> _filtrados;
  final List<TipoServicio> _seleccionados = [];
  // String _query = '';

  @override
  void initState() {
    super.initState();
    _filtrados = widget.servicios;
    // Pre-cargar los ya seleccionados del formulario principal
    for (var s in widget.servicios) {
      if (widget.inicialesIds.contains(s.idTipoServicio)) {
        _seleccionados.add(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // BARRA SUPERIOR (TEAL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF009688), // Verde Teal
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Tipos de servicios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () {
                    // Solo cerramos devolviendo la lista de seleccionados
                    Navigator.pop(context, _seleccionados);
                  },
                ),
              ],
            ),
          ),

          // BUSCADOR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _filtrados = widget.servicios
                      .where(
                        (s) =>
                            s.nombre.toLowerCase().contains(val.toLowerCase()),
                      )
                      .toList();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Búsqueda',
                prefixIcon: Icon(Icons.search),
                border: UnderlineInputBorder(),
              ),
            ),
          ),

          // LISTA CON CHECKBOXES
          Expanded(
            child: ListView.builder(
              itemCount: _filtrados.length,
              itemBuilder: (context, index) {
                final s = _filtrados[index];
                final isSelected = _seleccionados.any(
                  (sel) => sel.idTipoServicio == s.idTipoServicio,
                );

                return CheckboxListTile(
                  title: Text(s.nombre, style: const TextStyle(fontSize: 16)),
                  value: isSelected,
                  activeColor: const Color(0xFF009688),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? val) {
                    setState(() {
                      if (val == true) {
                        _seleccionados.add(s);
                      } else {
                        _seleccionados.removeWhere(
                          (sel) => sel.idTipoServicio == s.idTipoServicio,
                        );
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServicioSeleccionable {
  final TipoServicio servicio;
  bool seleccionado;
  final TextEditingController precioCtrl;

  ServicioSeleccionable({
    required this.servicio,
    this.seleccionado = false,
    double? precioInicial,
  }) : precioCtrl = TextEditingController(
         text: precioInicial?.toString() ?? '',
       );
}

class SeleccionarServiciosPage extends StatefulWidget {
  final List<TipoServicio> servicios;
  final List<ServicioDetalleForm> actuales;

  const SeleccionarServiciosPage({
    super.key,
    required this.servicios,
    required this.actuales,
  });

  @override
  State<SeleccionarServiciosPage> createState() =>
      _SeleccionarServiciosPageState();
}

class _SeleccionarServiciosPageState extends State<SeleccionarServiciosPage> {
  late List<ServicioSeleccionable> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.servicios.map((s) {
      // Buscar si ya está seleccionado para mantener el precio anterior
      final detallePrevio = widget.actuales.where(
        (a) => a.servicio.idTipoServicio == s.idTipoServicio,
      );
      return ServicioSeleccionable(
        servicio: s,
        seleccionado: detallePrevio.isNotEmpty,
        precioInicial: detallePrevio.isNotEmpty
            ? detallePrevio.first.precio
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688), // Color Teal de tu imagen
        title: const Text('Tipos de servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Retornar la lista convertida a ServicioDetalleForm
              final seleccion = _items.where((i) => i.seleccionado).map((i) {
                return ServicioDetalleForm(
                  servicio: i.servicio,
                  precio: double.tryParse(i.precioCtrl.text) ?? 0,
                );
              }).toList();
              Navigator.pop(context, seleccion);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF009688), // mismo color del header
        child: const Icon(Icons.add),
        onPressed: () => _abrirAltaServicio(context),
      ),

      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Column(
            children: [
              CheckboxListTile(
                title: Text(item.servicio.nombre),
                value: item.seleccionado,
                activeColor: const Color(0xFF009688),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) =>
                    setState(() => item.seleccionado = val ?? false),
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
                      labelStyle: TextStyle(color: Color(0xFF009688)),
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

  void _abrirAltaServicio(BuildContext context) async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTipoServicioPage()),
    );

    if (creado != true) return;

    await context.read<ServicioViewModel>().cargarServicios();

    final serviciosActuales = context.read<ServicioViewModel>().servicios;

    setState(() {
      _items = serviciosActuales.map((s) {
        final previo = _items.where(
          (i) => i.servicio.idTipoServicio == s.idTipoServicio,
        );

        if (previo.isNotEmpty) {
          final old = previo.first;

          return ServicioSeleccionable(
            servicio: s,
            seleccionado: old.seleccionado,
            precioInicial: double.tryParse(old.precioCtrl.text),
          );
        }

        // 🆕 Servicio nuevo
        return ServicioSeleccionable(servicio: s);
      }).toList();
    });
  }
}
