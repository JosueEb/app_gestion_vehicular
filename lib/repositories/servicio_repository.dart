import '../models/tipo_servicio.dart';

abstract class ServicioRepository {
  Future<List<TipoServicio>> obtenerServicios();
  Future<int> insertarServicio(TipoServicio servicio);
}
