import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/recordatorio.dart';
import '../../viewmodels/recordatorio_viewmodel.dart';
import '../../services/app_preferences.dart';

class AddRecordatorioPage extends StatefulWidget {
  const AddRecordatorioPage({super.key});

  @override
  State<AddRecordatorioPage> createState() => _AddRecordatorioPageState();
}

class _AddRecordatorioPageState extends State<AddRecordatorioPage> {
  final _formKey = GlobalKey<FormState>();

  // Segmentos
  String _tipoRecordatorio = 'Gasto';
  String _frecuencia = 'Sólo una vez';

  // Checkboxes
  bool _porKm = true;
  bool _porFecha = false;

  // Datos
  DateTime? _fechaSeleccionada;

  // Controllers
  final _odometroController = TextEditingController();
  final _notasController = TextEditingController();

  static const Color purplePrimary = Color(0xFF673AB7);
  static const Color purpleDark = Color(0xFF512DA8);

  @override
  void dispose() {
    _odometroController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // GUARDAR
  // ─────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_porKm && !_porFecha) {
      _mostrarError('Seleccione al menos km o fecha');
      return;
    }

    final vehiculoId = await AppPreferences.getVehiculoActivo();
    if (vehiculoId == null) {
      _mostrarError('No hay vehículo activo');
      return;
    }

    final recordatorio = Recordatorio(
      idVehiculo: vehiculoId,
      tipoRecordatorio: _tipoRecordatorio.toLowerCase(),
      frecuencia:
          _frecuencia == 'Sólo una vez' ? 'una_vez' : 'repetido',
      porKm: _porKm,
      kmObjetivo: _porKm
          ? double.tryParse(_odometroController.text)
          : null,
      porFecha: _porFecha,
      fechaObjetivo: _porFecha ? _fechaSeleccionada : null,
      notas: _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
      createdAt: DateTime.now(),
    );

    await context
        .read<RecordatorioViewModel>()
        .crearRecordatorio(recordatorio);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ─────────────────────────────────────────────
  // FECHA
  // ─────────────────────────────────────────────
  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: purplePrimary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: purpleDark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: purplePrimary,
          title:
              const Text('Recordatorio', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _guardar,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipoRecordatorio(),
                const SizedBox(height: 24),
                _buildFrecuencia(),
                const SizedBox(height: 24),
                _buildPorKm(),
                const SizedBox(height: 16),
                _buildPorFecha(),
                const SizedBox(height: 32),
                _buildNotas(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECCIONES UI
  // ─────────────────────────────────────────────
  Widget _buildTipoRecordatorio() {
    return Row(
      children: [
        const Icon(Icons.credit_card, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Gasto', label: Text('Gasto')),
              ButtonSegment(
                  value: 'Servicio', label: Text('Servicio')),
            ],
            selected: {_tipoRecordatorio},
            onSelectionChanged: (s) =>
                setState(() => _tipoRecordatorio = s.first),
            style: _segmentedButtonStyle(),
          ),
        ),
      ],
    );
  }

  Widget _buildFrecuencia() {
    return Row(
      children: [
        const Icon(Icons.notifications, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'Sólo una vez', label: Text('Sólo una vez')),
              ButtonSegment(
                  value: 'Repita cada', label: Text('Repita cada')),
            ],
            selected: {_frecuencia},
            onSelectionChanged: (s) =>
                setState(() => _frecuencia = s.first),
            style: _segmentedButtonStyle(),
          ),
        ),
      ],
    );
  }

  Widget _buildPorKm() {
    return _buildCheckOption(
      value: _porKm,
      label: 'km',
      onChanged: (v) => setState(() => _porKm = v ?? false),
      child: TextFormField(
        controller: _odometroController,
        keyboardType: TextInputType.number,
        enabled: _porKm,
        decoration: const InputDecoration(
          labelText: 'Odómetro objetivo',
          isDense: true,
        ),
        validator: (v) {
          if (!_porKm) return null;
          final val = double.tryParse(v ?? '');
          if (val == null || val <= 0) return 'Km inválido';
          return null;
        },
      ),
    );
  }

  Widget _buildPorFecha() {
    return _buildCheckOption(
      value: _porFecha,
      label: 'Fecha',
      onChanged: (v) => setState(() => _porFecha = v ?? false),
      child: InkWell(
        onTap: _porFecha ? _pickFecha : null,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Fecha objetivo',
            isDense: true,
          ),
          child: Text(
            _fechaSeleccionada != null
                ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildNotas() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.notes, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _notasController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  Widget _buildCheckOption({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: purplePrimary,
          ),
          SizedBox(width: 60, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  ButtonStyle _segmentedButtonStyle() {
    return SegmentedButton.styleFrom(
      selectedBackgroundColor: purplePrimary,
      selectedForegroundColor: Colors.white,
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.grey[700],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
