import 'package:flutter/material.dart';

class SeccionHeader extends StatelessWidget {
  final String titulo;
  final Color color;
  const SeccionHeader({super.key, required this.titulo, this.color = const Color(0xFF0097A7)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(titulo, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class InfoSummary extends StatelessWidget {
  final String texto;
  const InfoSummary({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(texto, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }
}

class TripleStatsRow extends StatelessWidget {
  final List<String> labels;
  final List<String> values;
  final bool isMini;

  const TripleStatsRow({super.key, required this.labels, required this.values, this.isMini = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(label: labels[0], value: values[0], isMini: isMini),
        _buildDivider(),
        _StatItem(label: labels[1], value: values[1], isMini: isMini),
        _buildDivider(),
        _StatItem(label: labels[2], value: values[2], isMini: isMini),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: Colors.grey[300]);
}

class DoubleStatsRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  const DoubleStatsRow({super.key, required this.l1, required this.v1, required this.l2, required this.v2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(label: l1, value: v1),
        Container(height: 30, width: 1, color: Colors.grey[300]),
        _StatItem(label: l2, value: v2),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final bool isMini;
  const _StatItem({required this.label, required this.value, this.isMini = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: isMini ? 10 : 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: isMini ? 14 : 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class SelectorGrafico extends StatelessWidget {
  const SelectorGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
      child: const Row(
        children: [
          Icon(Icons.bar_chart, color: Colors.grey),
          SizedBox(width: 10),
          Text('Seleccionar', style: TextStyle(color: Colors.black87, fontSize: 16)),
          Spacer(),
          Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }
}