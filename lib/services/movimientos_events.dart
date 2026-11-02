import 'package:flutter/foundation.dart';

/// Avisa que se creó, editó o eliminó un movimiento, para que las pantallas
/// que muestran datos derivados se recarguen sin depender de cómo se volvió a ellas.
class MovimientosEvents {
  static final ValueNotifier<int> cambios = ValueNotifier(0);

  static void notificar() => cambios.value++;
}
