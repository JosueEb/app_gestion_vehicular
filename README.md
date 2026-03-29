# App Gestión Vehicular

## Descripción
**App Gestión Vehicular** es una aplicación desarrollada en Flutter diseñada para ayudar a los usuarios a llevar un control detallado de sus vehículos. Permite gestionar gastos, recargas de combustible, servicios de mantenimiento y llevar un histórico de actividades, todo almacenado localmente en el dispositivo.

## Capturas de Pantalla
<p align="center">
  <img src="capturas/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-03-29%20at%2015.05.39.png" alt="Pantalla principal" width="220" />
  <img src="capturas/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-03-29%20at%2015.06.30.png" alt="Detalle del vehiculo" width="220" />
  <img src="capturas/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-03-29%20at%2015.08.18.png" alt="Registro de combustible" width="220" />
</p>

<p align="center">
  <img src="capturas/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-03-29%20at%2015.09.14.png" alt="Listado de movimientos" width="220" />
  <img src="capturas/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-03-29%20at%2015.09.36.png" alt="Resumen del vehiculo" width="220" />
</p>

## Arquitectura
El proyecto sigue una arquitectura **MVVM (Model-View-ViewModel)** complementada con el **Patrón Repositorio** para desacoplar la lógica de negocio y la capa de datos de la interfaz de usuario.

### Capas del Proyecto:

1.  **Model (Modelos - `lib/models/`)**:
    -   Define la estructura de los datos (e.g., `Vehiculo`, `Gasto`, `Servicio`).
    -   Son clases puras de Dart que representan las entidades del negocio.

2.  **View (Vista - `lib/ui/`)**:
    -   Contiene los Widgets y pantallas de la aplicación.
    -   Su única responsabilidad es mostrar datos y capturar interacciones del usuario.
    -   Se suscribe a los cambios en los ViewModels mediante `Provider`.

3.  **ViewModel (Vista-Modelo - `lib/viewmodels/`)**:
    -   Actúa como intermediario entre la Vista y el Repositorio.
    -   Extiende de `ChangeNotifier` para notificar a la UI sobre cambios en el estado.
    -   Contiene la lógica de presentación y manejo de estado (e.g., `VehiculoViewModel`, `CombustibleViewModel`).

4.  **Repository (Repositorios - `lib/repositories/`)**:
    -   Define contratos (interfaces) y sus implementaciones para el acceso a datos.
    -   Abstrae la fuente de datos (en este caso, SQLite) del resto de la aplicación.
    -   Ejemplo: `VehiculoRepository` define los métodos y `VehiculoRepositoryImpl` ejecuta las consultas a la base de datos.

5.  **Data (Datos - `lib/data/`)**:
    -   Contiene `DatabaseHelper`, responsable de la inicialización de la base de datos SQLite y la gestión de conexiones.

## Librerías Utilizadas
Las principales dependencias del proyecto (definidas en `pubspec.yaml`) son:

*   **[flutter](https://flutter.dev/)**: Framework principal para el desarrollo de la UI.
*   **[provider](https://pub.dev/packages/provider)** (`^6.1.2`): Gestión de estado e inyección de dependencias. Se utiliza `MultiProvider` en `main.dart` para inicializar y proveer los ViewModels a toda la app.
*   **[sqflite](https://pub.dev/packages/sqflite)** (`^2.3.3`): Plugin para base de datos SQLite, utilizado para la persistencia local de datos.
*   **[path](https://pub.dev/packages/path)** (`^1.9.0`): Utilidad para manipular rutas de archivos, necesaria para ubicar la base de datos en el dispositivo.
*   **[shared_preferences](https://pub.dev/packages/shared_preferences)** (`^2.3.2`): Almacenamiento persistente simple (clave-valor) para configuraciones ligeras.
*   **[intl](https://pub.dev/packages/intl)** (`^0.19.0`): Para formateo de fechas y números, y soporte de internacionalización (configurado para español 'es').
*   **[cupertino_icons](https://pub.dev/packages/cupertino_icons)**: Iconos estilo iOS.

## Flujo de la Aplicación
El flujo de datos típico sigue estos pasos:

1.  **Interacción**: El usuario realiza una acción en la UI (ej. guardar una nueva recarga de combustible).
2.  **ViewModel**: La UI llama a un método en el `CombustibleViewModel`.
3.  **Procesamiento**: El ViewModel valida los datos y llama al método correspondiente en el `CombustibleRepository`.
4.  **Persistencia**: El `CombustibleRepositoryImpl` utiliza el `DatabaseHelper` para ejecutar la sentencia SQL `INSERT`.
5.  **Notificación**:
    -   La base de datos confirma la operación.
    -   El Repositorio devuelve el resultado al ViewModel.
    -   El ViewModel actualiza su lista local de recargas y llama a `notifyListeners()`.
6.  **Actualización UI**: Los widgets que escuchan al ViewModel (mediante `Consumer` o `context.watch`) se reconstruyen automáticamente para mostrar los nuevos datos.

## Inicialización
En `main.dart`:
-   Se inicializa el binding de Flutter.
-   Se configura el formato de fechas (`initializeDateFormatting`).
-   Se levanta el `MultiProvider` con todos los ViewModels.
-   Se carga el vehículo activo al inicio (`VehiculoViewModel().obtenerVehiculoActivo()`).

## Pendientes
validación del kilometraje para gastos y servicios
Sección informes
Sección recordatorios
Notificaciones
Sección de mas

