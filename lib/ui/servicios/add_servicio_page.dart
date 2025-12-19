import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/movimiento_detalle.dart';
import '../../models/tipo_servicio.dart';
import '../shared/app_colors.dart';
import '../../viewmodels/vehiculo_viewmodel.dart';
import '../../viewmodels/servicio_viewmodel.dart';
import '../../viewmodels/servicio_movimiento_viewmodel.dart';

class AddServicioPage extends StatefulWidget {
  const AddServicioPage({super.key});

  @override
  State<AddServicioPage> createState() => _AddServicioPageState();
}

class _AddServicioPageState extends State<AddServicioPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();

  final _odometroCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  /// 👉 Estado LOCAL de formulario
  TipoServicio? _servicioSeleccionado;
  final List<ServicioDetalleForm> _detalles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarUltimoKilometraje();
      context.read<ServicioViewModel>().cargarServicios();
    });
  }

  @override
  void dispose() {
    _odometroCtrl.dispose();
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

  double get _total =>
      _detalles.fold(0, (sum, d) => sum + d.subtotal);

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
    final vehiculoActivo = vehiculoVM.vehiculoActivo;

    if (vehiculoActivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay vehículo activo')),
      );
      return;
    }

    await servicioMovVM.registrarServicio(
      vehiculoId: vehiculoActivo.idVehiculo!,
      fecha: _fecha,
      odometro: double.parse(_odometroCtrl.text),
      observaciones: _obsCtrl.text,
      detalles: _detalles
          .map((d) => d.toMovimientoDetalle())
          .toList(),
    );

    await vehiculoVM.cargarUltimoKilometraje();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<double?> _mostrarInputPrecio({double? valorInicial}) async {
    final precioCtrl = TextEditingController(
      text: valorInicial?.toString() ?? '',
    );

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Precio del servicio'),
        content: TextField(
          controller: precioCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Costo',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(precioCtrl.text);
              if (val != null) Navigator.pop(context, val);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiculoVM = context.watch<VehiculoViewModel>();
    final servicioVM = context.watch<ServicioViewModel>();
    final ultimoKm = vehiculoVM.ultimoKilometraje;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.headerNotificationBarServicio,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headerBackgroundServicio,
          elevation: 0,
          title: const Text('Registrar servicio'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.headerBackgroundServicio,
          child: const Icon(Icons.add),
          onPressed: () async {
            if (_servicioSeleccionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Seleccione un tipo de servicio')),
              );
              return;
            }

            final precio = await _mostrarInputPrecio();
            if (precio != null) {
              setState(() {
                _detalles.add(
                  ServicioDetalleForm(
                    servicio: _servicioSeleccionado!,
                    precio: precio,
                  ),
                );
              });
            }
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// FECHA / HORA
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: 'Fecha',
                        value:
                            '${_fecha.day}/${_fecha.month}/${_fecha.year}',
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
                    if (v == null || v.isEmpty) {
                      return 'Campo requerido';
                    }
                    final val = double.tryParse(v);
                    if (val == null) return 'Valor inválido';
                    if (ultimoKm != null && val < ultimoKm) {
                      return 'No puede ser menor a $ultimoKm km';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// SELECTOR DE SERVICIO
                DropdownButtonFormField<TipoServicio>(
                  value: _servicioSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de servicio',
                    border: OutlineInputBorder(),
                  ),
                  items: servicioVM.servicios
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (s) {
                    setState(() => _servicioSeleccionado = s);
                  },
                ),

                const SizedBox(height: 16),

                /// DETALLES
                ..._detalles.map((detalle) {
                  return Card(
                    child: ListTile(
                      title: Text(detalle.servicio.nombre),
                      subtitle: Text(
                        'Precio unitario: \$ ${detalle.precio.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$ ${detalle.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              setState(() =>
                                  _detalles.remove(detalle));
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final nuevoPrecio =
                            await _mostrarInputPrecio(
                          valorInicial: detalle.precio,
                        );
                        if (nuevoPrecio != null) {
                          setState(() {
                            detalle.precio = nuevoPrecio;
                          });
                        }
                      },
                    ),
                  );
                }),

                const SizedBox(height: 12),

                /// TOTAL
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: \$ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

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
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          AppColors.headerBackgroundServicio,
                    ),
                    child: const Text('Guardar servicio'),
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

/// ---------------------------------------------------------------------------
/// COMPONENTE PICKER
/// ---------------------------------------------------------------------------

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

/// ---------------------------------------------------------------------------
/// MODELO UI
/// ---------------------------------------------------------------------------

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
