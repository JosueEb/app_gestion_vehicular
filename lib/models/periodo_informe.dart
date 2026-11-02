enum PeriodoInforme {
  mes('Este mes'),
  tresMeses('3 meses'),
  anio('12 meses'),
  todo('Todo');

  final String etiqueta;

  const PeriodoInforme(this.etiqueta);

  DateTime? desde([DateTime? ahora]) {
    final hoy = ahora ?? DateTime.now();
    return switch (this) {
      PeriodoInforme.mes => DateTime(hoy.year, hoy.month),
      PeriodoInforme.tresMeses => DateTime(hoy.year, hoy.month - 2),
      PeriodoInforme.anio => DateTime(hoy.year, hoy.month - 11),
      PeriodoInforme.todo => null,
    };
  }

  DateTime? hasta([DateTime? ahora]) {
    if (this == PeriodoInforme.todo) return null;
    final hoy = ahora ?? DateTime.now();
    return DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
  }
}
