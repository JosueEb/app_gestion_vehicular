import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: r'$');

// Paleta validada para daltonismo; cada categoría conserva su color en toda la app
const colorRecarga = Color(0xFFE8920C);
const colorGasto = Color(0xFFC8452F);
const colorServicio = Color(0xFF2B7BA8);

String nombreTipoMovimiento(String tipo) => switch (tipo.toLowerCase()) {
  'combustible' => 'Recarga',
  'gasto' => 'Gasto',
  'servicio' => 'Servicio',
  'ingreso' => 'Ingreso',
  _ => tipo,
};

Color colorTipoMovimiento(String tipo) => switch (tipo.toLowerCase()) {
  'combustible' => colorRecarga,
  'gasto' => colorGasto,
  'servicio' => colorServicio,
  'ingreso' => Colors.green,
  _ => Colors.blueGrey,
};

IconData iconoTipoMovimiento(String tipo) => switch (tipo.toLowerCase()) {
  'combustible' => Icons.local_gas_station,
  'gasto' => Icons.credit_card,
  'servicio' => Icons.build,
  'ingreso' => Icons.savings_outlined,
  _ => Icons.directions_car,
};
