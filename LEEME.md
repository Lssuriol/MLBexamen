# MLB CLUB — Proyecto iOS

Aplicación nativa de SwiftUI para la Evaluación 03: Splash, Login, Registro, Home y Detalle. Arquitectura MVVM, sesión compartida y diez equipos locales. Interfaz en español, con soporte para iPhone y iPad.

## Abrir en tu Mac

1. Descomprime el ZIP por completo.
2. Abre **MLBClub.xcodeproj**, dentro de esta carpeta. No abras un archivo .swift suelto.
3. Selecciona el esquema **MLBClub**, junto al botón de ejecutar.
4. Elige un **simulador de iPhone con iOS 16 o superior**, no “Any iOS Device”.
5. Pulsa **⌘R**. Si falta un simulador, instala un runtime de iOS desde los ajustes de Xcode.
6. Tras la bienvenida de dos segundos, pulsa **Regístrate**. No hay cuentas precreadas.

Ejemplo de cuenta para que tú la crees: nombre Jose, correo jose@correo.com, contraseña MLB2026!

El proyecto usa Swift 5, SwiftUI y un deployment target iOS 16.0. Requiere Xcode 14 o posterior; utiliza una versión compatible con tu macOS y el simulador instalado. No requiere paquetes, CocoaPods, Firebase, servidor propio ni claves de API. El catálogo y el acceso funcionan sin internet; el calendario y los resultados se consultan por HTTPS en MLB Stats API y necesitan conexión para actualizarse. Después de una consulta correcta, se pueden volver a ver los datos guardados sin conexión.

Para un iPhone físico, selecciona tu Team en Target MLBClub → Signing & Capabilities. Si Xcode indica que el identificador ya existe, cambia com.josepurizaga.MLBClub por uno único. En simulador normalmente no necesitas configurar un Team.

## Comportamiento de la cuenta

- Las cuentas se guardan únicamente en RAM. Al terminar y volver a abrir la app tendrás que registrarte otra vez.
- Cerrar sesión conserva las cuentas mientras el proceso siga abierto. Puedes volver a iniciar sesión.
- Email único sin distinguir mayúsculas y con espacios exteriores eliminados.
- Contraseña: mínimo seis caracteres, al menos una mayúscula y un símbolo de la lista !@#$%^&*()_+-=[]{}:/?\|<>~. Puntos, comas, punto y coma y tildes no satisfacen el requisito especial.
- El botón de login se deshabilita con campos vacíos. Las demás validaciones se muestran al intentar entrar. Los errores se limpian al editar.
- Después de un registro válido se muestra “Cuenta creada” durante 1,2 segundos y se abre Home.

El almacenamiento de contraseñas en memoria es una simplificación académica del enunciado. Una aplicación real necesitaría autenticación de servidor y un diseño específico para manejar credenciales.

## Correspondencia con la rúbrica

| Criterio | Implementación |
| --- | --- |
| Splash | SplashView.swift: ícono central, .font(), opacity y scale, Task.sleep de 2 s, navegación automática |
| Login | LoginViewModel: validación; @Published errorMessage; SecureField; .disabled; enlace a Registro |
| Registro | RegisterViewModel: campos, contraseña y confirmación, unicidad; SessionStore compartido; feedback antes de Home |
| Home | HomeViewModel: @Published items con 10 equipos, filtro reactivo almacenado; LazyVStack; logout |
| Detalle | NavigationLink con ItemModel; struct Identifiable y Hashable; hero con SF Symbol; 4 atributos y ScrollView |
| Preguntas técnicas | Entregadas por separado en Respuestas_Analiticas_MLB.docx, con cinco respuestas fundamentadas |

## Prueba rápida para la exposición

1. Ejecutar: comprobar animación y llegada automática al Login.
2. Verificar que Entrar está deshabilitado con campos vacíos.
3. Probar correo inválido y contraseña sin mayúscula o sin símbolo especial: se muestra el error.
4. Registrar una cuenta válida: mensaje de éxito, después Home.
5. Buscar “New York”: aparecen Yankees y Mets; seleccionar Nacional: solo Mets.
6. Buscar algo inexistente: aparece el estado vacío; “Limpiar filtros” recupera la lista.
7. Abrir un equipo: verificar imagen grande, ciudad, liga, división, abreviatura y desplazamiento.
8. Volver y cerrar sesión: se regresa al Login sin acceso hacia atrás al Home.
9. Intentar registrar el mismo correo en mayúsculas: se rechaza por duplicado.
10. Entrar con la cuenta creada; detener la app desde Xcode y volver a ejecutarla para comprobar que no hay persistencia.

## Pruebas automatizadas y límites de verificación

Incluye un target MLBClubTests con pruebas de contraseña, email, duplicados, login/logout, registro y filtrado. Para ejecutarlas en tu Mac elige un simulador y pulsa **⌘U**. Si el simulador seleccionado no tiene el runtime instalado, elige uno disponible.

El proyecto fue generado y revisado en un entorno Linux: se revisó la sintaxis de los 15 archivos Swift con un analizador, la estructura OpenStep del proyecto, todos los recursos y las referencias, el esquema y la integridad del ZIP. El analizador de sintaxis no sustituye al compilador Swift ni comprueba tipos o disponibilidad de APIs. **No se compiló con Xcode ni se ejecutaron las pruebas de SwiftUI/XCTest o el simulador en este entorno.** La compilación y la revisión visual final deben hacerse en tu Mac.

## Estructura

- MLBClub/Models: modelo de equipos, usuario, sesión y reglas compartidas.
- MLBClub/ViewModels: lógica de Login, Registro y búsqueda.
- MLBClub/Views: cinco pantallas.
- MLBClub/Design: componentes, colores y estilos.
- MLBClubTests: pruebas unitarias para ejecutar con Xcode.
- REVISION_RUBRICA.md: revisión de cada requisito contra el código.

Las respuestas se entregan en un Word aparte del ZIP, como solicitaste.

## Referencia temática

MLB.com es el sitio oficial de Major League Baseball: https://www.mlb.com/ (consulta: 5 de noviembre de 2026). El documento adjunto solo especifica la temática MLB; no incluye un enlace obligatorio ni exige replicar la página. Los equipos, las ligas y las divisiones se tomaron como referencia de la navegación del sitio. El catálogo es local, los textos descriptivos son propios y el logo principal es exactamente el PNG proporcionado por el usuario; las ilustraciones de los equipos usan SF Symbols y composiciones de SwiftUI. Los resultados se consultan en MLB Stats API y muestran la fecha de la última actualización; no hay seguimiento automático en vivo.


## Identidad visual actualizada

La primera versión tenía una paleta propia azul oscuro y verde menta. Esta versión usa fondos claros, tarjetas blancas, texto y botones azul marino #041E42, rojo #BF0D3E y azul de interacción #0067B1. El azul marino y el rojo coinciden con los colores sólidos predominantes del logo enviado; el azul de interacción es una elección de interfaz. No se afirma que reproduzca todos los valores CSS del sitio.

El logo original está en Assets.xcassets/MLBLogo.imageset/mlb-logo.png, sin cambios en sus bytes. Aparece en Splash, Login, Registro y la barra del Home, usando scaledToFit para mantener su proporción. AppIcon contiene los tamaños de iOS con el mismo logo centrado sobre blanco. El Detalle utiliza una ilustración de béisbol del equipo, permitida por la rúbrica.


## Diseño del directorio

El Home usa un encabezado sencillo con saludo, el título Equipos y la identificación MLB. Los filtros de liga son botones con estado seleccionado. Los equipos se presentan en una lista blanca con separadores, distintivos pequeños en el color de cada club y tipografía del sistema. Cada fila permite abrir el mismo detalle. La búsqueda y los filtros siguen conectados a HomeViewModel.


## Calendario y resultados reales

Abre cualquier equipo y encontrarás el encabezado simplificado y el apartado Partidos.

- Calendario: usa las flechas para cambiar de mes; los puntos marcan días con encuentros. Toca un día para ver sus partidos, incluidos dos encuentros el mismo día cuando existen. Hoy vuelve a la fecha actual.
- Últimos 30 días: presenta los encuentros finalizados dentro de los 30 días calendario que terminan hoy, con marcadores, rival y balance de victorias y derrotas. Los partidos cancelados, suspendidos o pendientes no se cuentan como terminados. Puede haber empates; por eso victorias más derrotas no necesariamente equivalen al total jugado.
- Actualizar: consulta de nuevo el mes seleccionado y los resultados recientes. No se actualiza continuamente en segundo plano.
- Guardado: se conservan en Application Support hasta 12 meses consultados por equipo y la última consulta del historial reciente. La fecha de consulta siempre está visible. Si no hay internet, se conservan los datos anteriores y se muestra un aviso. Un mes que nunca se consultó necesita conexión.
- Las cuentas siguen siendo temporales en memoria, como pide el examen. La persistencia nueva guarda partidos públicos, no cambia el registro o el Login.

Los días usan la fecha oficial MLB (officialDate), mientras que las horas se muestran en la zona del dispositivo. Por diferencia horaria un encuentro puede empezar en otra fecha local; el calendario conserva el día oficial para coincidir con la programación de la liga.

El resumen consiste en resultados y balance de partidos. No incluye videos ni crónicas editoriales. No se incluyen datos de ejemplo como si fueran resultados reales. Es normal que ciertos meses no tengan encuentros para un equipo; en la comprobación del 5 de noviembre de 2026, la API devolvió ocho encuentros de Dodgers para octubre y ninguno de Yankees para noviembre.

### Comprobación de estas funciones en tu Mac

1. Ejecuta con internet, abre Dodgers, cambia a octubre de 2026 y toca un día marcado.
2. Cambia a Últimos 30 días y revisa los resultados disponibles para la fecha actual de tu dispositivo.
3. Vuelve al mes consultado, cierra la app, desconecta internet, vuelve a ejecutarla y regístrate otra vez. Abre el mismo equipo y mes: deben aparecer los datos guardados junto al aviso de que no pudieron actualizarse.
4. Reconecta internet y pulsa Actualizar.
5. Ejecuta Command U. Se añadieron pruebas de decodificación, resultados, años bisiestos, persistencia, fallo de red y partidos dobles; todavía requieren ejecución en Xcode.

Fuente de datos: https://statsapi.mlb.com/api/v1/schedule con sportId=1, teamId, startDate y endDate. Se comprobaron solicitudes reales con respuesta HTTP 200 y los identificadores de los diez equipos. El funcionamiento de URLSession y de la interfaz en iOS debe verificarse en tu Mac.
