# Revisión del proyecto contra la Evaluación 03

Revisión del código y de los archivos, realizada el 5 de noviembre de 2026. La columna de resultado indica presencia en el código; no equivale a una prueba de ejecución ni a una calificación garantizada. La compilación con Xcode, las pruebas XCTest y la inspección del simulador quedan pendientes en Mac.

| Requisito | Evidencia en el proyecto | Resultado de revisión |
| --- | --- | --- |
| Splash con logo centrado | SplashView y ClubMark con el PNG original MLBLogo | Implementado |
| Animación de entrada | opacity y scaleEffect controlados con @State | Implementado |
| Nombre con .font() | MLB CLUB con fuente system rounded y peso black | Implementado |
| Login después de 2 segundos | Task.sleep de 2 000 000 000 ns; RootView cambia el flujo | Implementado |
| Email y SecureField | LoginView enlaza ambos campos al ViewModel | Implementado |
| Login deshabilitado con campos vacíos | canSubmit y .disabled en LoginView | Implementado |
| Formato de correo | LoginViewModel llama a Validation.isValidEmail, con formato y longitud controlados | Implementado |
| Contraseña mínima de 6 caracteres | Validation.passwordError llamada desde LoginViewModel | Implementado |
| Una mayúscula y un símbolo especial válido | uppercaseLetters y lista explícita de símbolos; puntos, comas, punto y coma y tildes no satisfacen el símbolo | Implementado |
| Error reactivo | @Published errorMessage y FeedbackView | Implementado |
| Enlace a Registro | NavigationLink de LoginView a RegisterView | Implementado |
| Nombre, correo, contraseña y confirmación | Cuatro campos en RegisterView | Implementado |
| Campos completos, correo único y coincidencia | RegisterViewModel y SessionStore.contains; normaliza el correo | Implementado |
| Usuario en memoria compartida | SessionStore se inyecta con .environmentObject; @Published currentUser | Implementado |
| Feedback de éxito antes de Home | Mensaje y espera de 1,2 segundos antes de session.activate | Implementado |
| @Published items con al menos 8 elementos | HomeViewModel y ItemModel.catalog con 10 equipos | Implementado |
| Lista con imagen, nombre y subtítulo | ScrollView y LazyVStack; TeamRow con SF Symbol, nombre y ciudad/división | Implementado |
| Búsqueda reactiva | .searchable; didSet y filteredItems en el ViewModel | Implementado |
| Logout limpia usuario y regresa al Login | SessionStore.logout pone currentUser en nil; RootView sustituye el NavigationStack | Implementado |
| Navegación pasando ItemModel | NavigationLink(value:) y navigationDestination(for:) | Implementado |
| Imagen grande, título y 3 atributos adicionales | DetailView: hero de béisbol, nombre y ciudad, liga, división y abreviatura | Implementado |
| ScrollView para detalle largo | DetailView usa ScrollView | Implementado |
| Modelo struct Identifiable | ItemModel también conforma a Hashable | Implementado |
| Cinco respuestas analíticas | Entregadas por separado en Respuestas_Analiticas_MLB.docx | Entrega independiente |

## Identidad visual

El logo enviado se incorporó sin modificar sus bytes. El diseño usa azul marino #041E42 y rojo #BF0D3E tomados de sus colores predominantes, blanco y fondos claros. El azul de interacción #0067B1 es una elección de interfaz. La composición se inspira en la identidad de la web; no replica todas sus pantallas ni sus estilos CSS. Los colores de las tarjetas de equipos conservan sus acentos individuales.

## Comprobaciones realizadas

- Análisis sintáctico de los 15 archivos Swift con tree-sitter-swift, sin errores detectados. No es una compilación ni una comprobación de tipos.
- Lectura y validación de la estructura OpenStep del project.pbxproj, referencias y rutas de todos los archivos.
- Verificación del esquema compartido, los dos targets y los recursos de imágenes.
- Comparación de bytes del logo original y del asset incluido.
- Verificación de tamaños y formato RGB de los 18 iconos de iOS.
- Comprobación de integridad del ZIP.

## Comprobaciones pendientes en Mac

1. Abrir MLBClub.xcodeproj, seleccionar un simulador iOS 16 o superior y pulsar Command R.
2. Seguir la prueba manual incluida en LEEME.md, especialmente animación, teclado, registro, errores y cierre de sesión.
3. Pulsar Command U para ejecutar las pruebas unitarias incluidas.

El catálogo sigue hardcodeado y las cuentas siguen en memoria, como exige la evaluación. Las funciones adicionales de calendario e historial consultan MLB Stats API y guardan localmente los resultados públicos; no sustituyen ninguno de los requisitos. Tampoco exige los logos oficiales de cada equipo: admite SF Symbols o assets. La imagen proporcionada se usa como identidad principal de la aplicación.


## Ampliación de partidos

Detalle conserva una imagen destacada y los cuatro atributos, y añade TeamScheduleView. ScheduleViewModel consulta el mes seleccionado y los últimos 30 días con URLSession, maneja errores y conserva hasta 12 meses consultados por equipo. GameModel decodifica rivales, marcadores, fechas y estados. El resumen excluye partidos pendientes, cancelados y suspendidos. El guardado es un JSON por equipo en Application Support, con escritura atómica y fecha de consulta visible.

Se comprobaron respuestas HTTP 200 de la fuente MLB, coincidencia de los identificadores de los diez equipos y los campos requeridos por el modelo. Las pruebas unitarias nuevas están incluidas; su ejecución y la verificación visual en el simulador siguen pendientes en Mac.
