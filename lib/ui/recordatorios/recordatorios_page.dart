import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recordatorio.dart';
import '../../viewmodels/recordatorio_viewmodel.dart';

class RecordatoriosPage extends StatefulWidget {
  const RecordatoriosPage({super.key});

  @override
  State<RecordatoriosPage> createState() => _RecordatoriosPageState();
}

class _RecordatoriosPageState extends State<RecordatoriosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordatorioViewModel>().cargarRecordatorios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordatorioViewModel>();

    return Scaffold(
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.recordatorios.isEmpty
              ? _emptyState()
              : ListView.separated(
                  itemCount: vm.recordatorios.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _buildItem(context, vm.recordatorios[i]),
                ),
    );
  }

  Widget _buildItem(BuildContext context, Recordatorio r) {
    final icon = r.tipoRecordatorio == 'gasto'
        ? Icons.credit_card
        : Icons.build;

    return ListTile(
      leading: Icon(icon),
      title: Text(
        r.notas ?? 'Sin notas',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_buildDescripcion(r)),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') {
            context
                .read<RecordatorioViewModel>()
                .eliminarRecordatorio(r.idRecordatorio!);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'delete', child: Text('Eliminar')),
        ],
      ),
    );
  }

  String _buildDescripcion(Recordatorio r) {
    final partes = <String>[];

    if (r.porKm && r.kmObjetivo != null) {
      partes.add('Km: ${r.kmObjetivo!.toInt()}');
    }

    if (r.porFecha && r.fechaObjetivo != null) {
      partes.add(
        'Fecha: ${_fmtFecha(r.fechaObjetivo!)}',
      );
    }

    if (r.frecuencia == 'repetir') {
      partes.add('Repetir');
    } else {
      partes.add('Una vez');
    }

    if (!r.activo) {
      partes.add('Inactivo');
    } else if (r.notificado) {
      partes.add('Ya notificado');
    }

    return partes.join(' · ');
  }

  String _fmtFecha(DateTime f) {
    return '${f.day.toString().padLeft(2, '0')}/'
        '${f.month.toString().padLeft(2, '0')}/'
        '${f.year}';
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No hay recordatorios',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
