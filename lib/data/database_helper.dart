import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  static const _databaseName = 'gestion_vehicular.db';
  static const _databaseVersion = 1;

  // Valores iniciales para catálogos
  static const List<String> initialCombustibles = [
    'Gasolina Regular',
    'Gasolina Premium',
    'Diesel',
    'Eléctrico',
    'Híbrido',
  ];

  static const List<String> initialTiposServicio = [
    'Cambio de aceite',
    'Alineación y balanceo',
    'Lavado',
    'Reparación mecánica',
  ];

  static const List<String> initialTiposGasto = [
    'Peaje',
    'Seguro',
    'Multa',
    'Refacción',
  ];

  static const List<String> initialTiposIngreso = [
    'Renta',
    'Subsidio',
    'Reembolso',
    'Otro',
  ];
  static const List<String> initialMetodosPago = [
    'Efectivo',
    'Tarjeta de crédito',
    'Tarjeta de débito',
    'Transferencia bancaria',
  ];
  static const List<String> initialUnidades = [
    'Kilómetros',
    'Millas',
    'Litros',
    'Galones',
  ];

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createUsuarios);
    await db.execute(_createVehiculos);
    await db.execute(_createVehiculoUsuario);
    await db.execute(_createLocaciones);
    await db.execute(_createCombustibles);
    await db.execute(_createGasolineras);
    await db.execute(_createTiposServicio);
    await db.execute(_createTiposGasto);
    await db.execute(_createTiposIngreso);
    await db.execute(_createMetodosPago);
    await db.execute(_createMovimientos);
    await db.execute(_createMovimientoDetalle);
    await db.execute(_createMovimientoRuta);
    await db.execute(_createRecordatorios);
    await db.execute(_createUnidades);
    await db.insert('usuarios', {
      'nombre': 'Usuario por defecto',
      'email': 'default@local.app',
      'password_hash': '', // no importa por ahora
      'fecha_registro': DateTime.now().toIso8601String(),
      'activo': 1,
    });

    // ================= Insertar datos iniciales =================
    for (var combustible in initialCombustibles) {
      await db.insert('combustibles', {'nombre': combustible});
    }

    for (var servicio in initialTiposServicio) {
      await db.insert('tipos_servicio', {'nombre': servicio});
    }

    for (var gasto in initialTiposGasto) {
      await db.insert('tipos_gasto', {'nombre': gasto});
    }

    for (var ingreso in initialTiposIngreso) {
      await db.insert('tipos_ingreso', {'nombre': ingreso});
    }
    for (var metodo in initialMetodosPago) {
      await db.insert('metodos_pago', {'nombre': metodo});
    }
    for (var unidad in initialUnidades) {
      await db.insert('unidades', {'nombre': unidad});
    }
  }

  // =================== TABLAS ===================

  static const _createUsuarios = '''
  CREATE TABLE usuarios (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    telefono TEXT,
    fecha_registro TEXT,
    activo INTEGER DEFAULT 1
  );
  ''';

  static const _createVehiculos = '''
  CREATE TABLE vehiculos (
    id_vehiculo INTEGER PRIMARY KEY AUTOINCREMENT,
    marca TEXT,
    modelo TEXT,
    anio INTEGER,
    placas TEXT,
    vin TEXT,
    color TEXT,
    odometro_inicial REAL DEFAULT 0,
    activo INTEGER DEFAULT 1,
    tamanio_tanque INTEGER NOT NULL DEFAULT 0
  );
  ''';

  static const _createVehiculoUsuario = '''
  CREATE TABLE vehiculo_usuario (
    id_vehiculo_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    id_vehiculo INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    rol TEXT NOT NULL,
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
  );
  ''';

  static const _createLocaciones = '''
  CREATE TABLE locaciones (
    id_locacion INTEGER PRIMARY KEY AUTOINCREMENT,
    pais TEXT,
    estado TEXT,
    ciudad TEXT,
    direccion TEXT,
    latitud REAL,
    longitud REAL
  );
  ''';

  static const _createCombustibles = '''
  CREATE TABLE combustibles (
    id_combustible INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';

  static const _createGasolineras = '''
  CREATE TABLE gasolineras (
    id_gasolinera INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    id_locacion INTEGER,
    FOREIGN KEY (id_locacion) REFERENCES locaciones(id_locacion)
  );
  ''';

  static const _createTiposServicio = '''
  CREATE TABLE tipos_servicio (
    id_tipo_servicio INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';

  static const _createTiposGasto = '''
  CREATE TABLE tipos_gasto (
    id_tipo_gasto INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';

  static const _createTiposIngreso = '''
  CREATE TABLE tipos_ingreso (
    id_tipo_ingreso INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';

  static const _createMetodosPago = '''
  CREATE TABLE metodos_pago (
    id_metodo_pago INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';

  static const _createMovimientos = '''
  CREATE TABLE movimientos (
    id_movimiento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_vehiculo INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    tipo_movimiento TEXT NOT NULL,
    fecha TEXT NOT NULL,
    odometro REAL NOT NULL,
    total REAL NOT NULL,
    id_metodo_pago INTEGER,
    observaciones TEXT,
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_metodo_pago) REFERENCES metodos_pago(id_metodo_pago)
  );
  ''';

  static const _createMovimientoDetalle = '''
  CREATE TABLE movimiento_detalle (
    id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
    id_movimiento INTEGER NOT NULL,
    tipo_detalle TEXT NOT NULL,
    id_referencia INTEGER,
    descripcion TEXT,
    cantidad REAL DEFAULT 1,
    precio_unitario REAL NOT NULL,
    subtotal REAL NOT NULL,
    tanque_lleno INTEGER DEFAULT 0,
    FOREIGN KEY (id_movimiento) REFERENCES movimientos(id_movimiento)
      ON DELETE CASCADE
  );
  ''';

  static const _createMovimientoRuta = '''
  CREATE TABLE movimiento_ruta (
    id_movimiento INTEGER PRIMARY KEY,
    km_recorridos REAL NOT NULL,
    tiempo_minutos INTEGER,
    origen TEXT,
    destino TEXT,
    FOREIGN KEY (id_movimiento) REFERENCES movimientos(id_movimiento)
      ON DELETE CASCADE
  );
  ''';

  static const _createRecordatorios = '''
  CREATE TABLE recordatorios (
    id_recordatorio INTEGER PRIMARY KEY AUTOINCREMENT,
    id_vehiculo INTEGER NOT NULL,
    tipo_recordatorio TEXT,
    fecha_programada TEXT,
    odometro_objetivo REAL,
    notificado INTEGER DEFAULT 0,
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo)
  );
  ''';

  static const _createUnidades = '''
  CREATE TABLE unidades (
    id_unidad INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL
  );
  ''';
}
