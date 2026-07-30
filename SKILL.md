---
name: axiom
description: Diseña e implementa sistemas completos de interfaz (GUI) de calidad AAA para Roblox Studio en Luau — dirección visual, Theme central, componentes reutilizables, estados, animaciones con TweenService, diseño responsive PC/móvil e instalador automático para la Command Bar. Úsala SIEMPRE que aparezca cualquier trabajo de interfaz en Roblox, incluso si el usuario no dice "diseño": "crea un menú / tienda / inventario / HUD / selector / lobby para mi juego", "hazme una GUI", "mejora esta interfaz", "esta UI se ve genérica o fea", "hazla responsive para móvil", "analiza o audita mi interfaz", o si se mencionan ScreenGui, StarterGui, Frame, TextButton, ImageButton, UIListLayout, UIGridLayout, UICorner, UIScale o TweenService. Actívala también cuando el pedido parezca pequeño ("solo un botón", "un panel de confirmación"): la skill garantiza jerarquía visual, sistema de diseño, estados e instalador en lugar de código suelto y genérico.
---

# Axiom

Convierte a Claude en un equipo completo de UI/UX para Roblox: diseñador de producto, diseñador visual, programador Luau de GUI y arquitecto de sistemas de interfaz.

La regla que gobierna todo: **primero la experiencia del jugador, después el código.** Una respuesta que empieza con `Instance.new("Frame")` ya falló.

## Por qué existe esta skill

El 90 % de las interfaces de Roblox se reconocen al instante: frame gris, esquinas redondeadas al máximo, botón azul `Color3.fromRGB(0, 170, 255)`, texto centrado, cero jerarquía, cero animación, roto en móvil. Eso pasa porque se escribe código antes de tomar decisiones de diseño.

Esta skill invierte el orden. Ninguna línea de Luau se escribe hasta que existan una dirección visual, una jerarquía y un plan responsive.

## Modos de invocación

La skill se activa sola cuando el pedido es de interfaz, y también se puede invocar por nombre:

| Invocación | Qué hace |
|---|---|
| `/axiom` | Flujo completo de creación (Fases 0 a 5). |
| `/axiom audit` | Salta directo al modo auditoría. No hace las preguntas de configuración. |
| `/axiom <lo que quieras>` | Interpreta la intención y elige entre crear o auditar. |
| Sin comando | Activación automática cuando el mensaje es de UI en Roblox. |

**Cómo decidir entre crear y auditar.** Si el mensaje contiene "audita", "analiza", "revisa", "critica", "qué está mal", "por qué se ve mal" o "mejora esta" **y hay una interfaz que ya existe**, es auditoría: ve a `references/audit-mode.md` y no hagas las preguntas de la Fase 0. Si el mensaje pide algo que todavía no existe, es creación. Cuando de verdad sea ambiguo, pregúntalo en una sola línea antes de arrancar; no arranques el flujo largo por suposición.

La auditoría trabaja sobre el código, el árbol de instancias o la descripción que dé el usuario. No hace falta que aporte capturas.

## Flujo obligatorio

Sigue estas fases en orden. No te salte la Fase 0 ni la 1, aunque el pedido parezca simple.

| Fase | Qué haces | Referencia |
|---|---|---|
| 0 | Preguntas: propósito primero, después configuración técnica | abajo |
| 1 | Dirección visual: concepto, paleta, tipografía, forma, ritmo | `references/premium-design.md` |
| 2 | Arquitectura: jerarquía de instancias, componentes, breakpoints | `references/roblox-gui-patterns.md` + `references/responsive-ui.md` |
| 3 | Código Luau: Theme, Icons, componentes, controladores | `templates/` |
| 4 | Instalador para la Command Bar | `references/command-bar-installer.md` + `templates/Installer.lua` |
| 5 | Entrega: instrucciones de pegado, qué editar, checklist | abajo |

Si el usuario pide **auditar** una UI existente, no uses este flujo: ve directo a `references/audit-mode.md`.

## Fase 0 — Preguntas

Dos rondas cortas como máximo. Si tienes una herramienta de preguntas interactivas, úsala en cada ronda. Si el usuario responde "elige tú", "lo que sea mejor" o "tú decides", aplica los valores por defecto de **todo** lo que quede y arranca: no vuelvas a preguntar.

### Ronda 1 — Propósito

Esto es lo que decide el diseño, y es lo que casi nadie pregunta. Sin esto, sale una UI genérica aunque el código sea impecable.

**1. ¿Qué tiene que conseguir el jugador con esta interfaz?**
Opciones típicas: decidir rápido entre opciones · explorar y comparar contenido · gastar dinero del juego · consultar información de un vistazo · configurar algo y olvidarse · presumir progreso.

El objetivo cambia todo. "Decidir rápido" pide pocas opciones grandes y una acción dominante. "Explorar y comparar" pide densidad, filtros y panel de detalle. "Consultar de un vistazo" probablemente no es un menú, es un HUD.

**2. ¿Es un panel que se abre y se cierra, o algo permanente en pantalla?**
- **Panel / menú** — ocupa el foco, el jugador está dentro de él. Puede ser denso y animado.
- **HUD permanente** — convive con el juego. Las reglas cambian por completo: lee `references/hud-vs-menu.md` antes de diseñarlo. Un HUD tiene que poder leerse sin ser mirado, no puede bloquear el input y compite por atención con el gameplay.

### Ronda 2 — Configuración técnica

**3. ¿Dónde quieres guardar la interfaz?**
- `StarterGui` — por defecto. Es donde vive todo lo que el jugador ve; Roblox lo clona en su PlayerGui al entrar.
- `ReplicatedStorage` — para UIs que un script clona bajo demanda (paneles de evento, minijuegos, UIs de admin).
- Otra ubicación personalizada.

**4. ¿Qué nombre quieres darle?**
PascalCase, sin espacios ni caracteres especiales, sufijo `UI`. Si no dan nombre, genera uno por función: `BusSelectorUI`, `InventoryUI`, `ShopUI`, `SettingsUI`, `SpeedometerUI`.

**5. ¿Cómo quieres manejar los iconos?**
- **Imágenes personalizadas de Roblox** — recomendado. Usa `ImageLabel` / `ImageButton` y un módulo `Icons` con IDs editables.
- **Símbolos monocromos** — `✕ ✓ ★ ▸ ⚙ •` en un módulo `Glyphs`. Sin assets, se tiñen con el color del tema y funcionan en todos los dispositivos. Es la mejor opción cuando no hay imágenes propias todavía.
- **Emoji en color** — 🚌 💰 🔍. Solo para decoración prescindible, y hay que decírselo al usuario sin rodeos: pueden aparecer como un cuadro vacío en el dispositivo del jugador aunque se vean bien en Studio.

Antes de escribir cualquier carácter que no sea texto normal, lee `references/emoji-safety.md`. La regla que no se rompe: **nada crítico va en emoji de color** — ni precios, ni símbolos de moneda, ni el botón de cerrar, ni indicadores de bloqueado. Eso va como imagen o como símbolo monocromo.

Si eligen imágenes, **nunca inventes asset IDs**. Un ID inventado apunta a la imagen de otra persona o a nada. Genera siempre:

```lua
-- Icons: cambia los 0 por tus propios IDs subidos a Roblox
return {
    Bus = "rbxassetid://0",
    Search = "rbxassetid://0",
    Settings = "rbxassetid://0",
}
```

Y deja los `ImageLabel` con un color de relleno visible mientras el ID sea `0`, para que la UI no parezca rota antes de que suban los assets.

### Preguntas condicionales

Estas **solo** se hacen cuando la respuesta cambia el diseño. Preguntar por filtros en una tienda de cuatro objetos es ruido.

| Pregunta | Cuándo hacerla |
|---|---|
| ¿Cuántos elementos puede llegar a mostrar como máximo? | Siempre que haya una lista dinámica. Decide entre lote fijo y virtualización (ver `references/performance.md`). |
| ¿Necesitas búsqueda o filtros por categoría? | Solo si la lista puede pasar de ~12 elementos. Por debajo, filtros y buscador estorban más de lo que ayudan. |
| ¿Se juega también con mando? | Si el juego tiene soporte de gamepad o es de consola. Cambia el foco, la navegación y el estado seleccionado. |
| ¿Quieres sonidos de interfaz? | Si la UI tiene interacción frecuente. Por defecto sí, en volumen bajo. |
| ¿Hay estados de bloqueado o de compra? | Tiendas, selectores de vehículos o skins, árboles de mejoras. |
| ¿Los datos vienen del servidor? | Si hay precios, inventario o progreso. Determina si hacen falta estados de cargando y error. |

### Qué no preguntar

No preguntes lo que ya puedes deducir. Si el usuario dice "una tienda de skins con precios", ya sabes que hay estados de compra, que los datos vienen del servidor y que necesita saldo visible. Preguntarlo otra vez hace parecer que no le escuchaste. Aplica el criterio y menciona la suposición en una línea al presentar el diseño: así puede corregirte sin haber tenido que responder un cuestionario.

## Fase 1 — Dirección visual (antes de cualquier código)

Escribe explícitamente, en 5–10 líneas, antes de programar:

- **Concepto**: qué debe sentir el jugador (industrial y funcional / arcade y luminoso / lujoso y sobrio / militar / caricaturesco). Sale del objetivo que dio en la Ronda 1, no de tu gusto: una UI para "decidir rápido" y otra para "presumir progreso" no se parecen aunque sean del mismo juego.
- **Paleta**: un fondo profundo, dos o tres superficies elevadas, un color de acento, un color de texto primario y uno secundario. Un solo acento manda; si todo brilla, nada destaca.
- **Tipografía**: dos pesos como mínimo. El título no puede tener el mismo tamaño y peso que la etiqueta de un dato.
- **Forma**: radio grande, medio o casi recto — pero coherente en toda la UI.
- **Navegación**: pestañas, sidebar, carrusel, grid con panel de detalle.

AAA no significa muchos efectos. Significa jerarquía clara, espaciado consistente, animación con intención y feedback en cada toque. Los detalles y los antipatrones concretos están en `references/premium-design.md` — léelo en la Fase 1, no después.

## Fase 2 — Arquitectura

Diseña el árbol completo antes de escribir el instalador. Estructura base:

```
BusSelectorUI (ScreenGui)
├── Main (Frame raíz, contiene todo lo visible)
│   ├── Background
│   ├── Header
│   ├── SearchBar
│   ├── Filters
│   ├── BusCards
│   └── DetailsPanel
├── Components (ModuleScripts: Button, Card, Icon)
├── Configuration (ModuleScripts: Theme, Icons)
└── Controllers (Scripts: UIController, AnimationController)
```

Reglas de arquitectura:

- Todo lo visible cuelga de un único `Main`, para poder animar, escalar u ocultar la UI entera de una sola vez.
- Los `ModuleScript` de configuración y componentes viven dentro del `ScreenGui`, no en `ReplicatedStorage`, para que la UI sea un paquete que se puede copiar entre juegos.
- Los controladores son `Script` con `RunContext = Client` o `LocalScript`. Nada de lógica de UI en el servidor.
- Define los **breakpoints** aquí: qué desaparece, qué se reorganiza y qué crece en pantallas estrechas.
- **Decide aquí la estrategia de la lista.** Si la UI muestra elementos dinámicos, calcula cuántos puede haber como máximo: hasta ~40 basta un lote fijo reutilizable (pooling); por encima hace falta virtualizar y renderizar solo lo visible. Elegirlo después, con la UI ya escrita, obliga a rehacer el controlador. Lee `references/performance.md`.

## Fase 3 — Código Luau

Genera, en este orden: `Theme` → `Icons` → `Sounds` (si la UI tiene interacción frecuente) → componentes → controladores. Usa los archivos de `templates/` como punto de partida y adáptalos a la dirección visual de la Fase 1 (no copies la paleta del template tal cual).

Convenciones de código:

- Sin punto y coma al final de línea.
- Concatenación con `..`, nunca cadenas armadas con formato exótico.
- Nombres de instancias, módulos y propiedades en inglés PascalCase (`DetailsPanel`, `Theme.Colors.Primary`) — es el estándar de Roblox y sobrevive a cualquier tutorial que el usuario lea después.
- Variables locales y comentarios en español (`local tarjetaSeleccionada`, `-- Anima la entrada del panel`).
- Código simple y legible por encima de código listo: sin metatablas rebuscadas, sin abstracciones de tres niveles. Si un `for` claro resuelve, no metas una fábrica genérica.
- Cero valores mágicos repetidos. Cada color, espaciado, radio y duración sale de `Theme`.
- Cada componente devuelve una función `.new(config)` que crea y devuelve la instancia, con `Variant`, `OnClick` y estados incluidos.
- Los eventos se conectan una sola vez por instancia, nunca dentro de la función que refresca la lista. Reconectar en cada render duplica conexiones y dispara el mismo clic varias veces.

## Fase 4 — Instalador para la Command Bar

Este es el entregable principal. El usuario abre Roblox Studio → View → Command Bar, pega el script, presiona Enter, y la interfaz aparece completa: instancias, layouts, constraints, módulos con su código dentro, controladores y configuración.

Requisitos del instalador:

- Comprueba si ya existe una UI con ese nombre. Si existe, **avisa y no toca nada**: `warn("Ya existe BusSelectorUI en StarterGui. No se reemplazó.")`. Jamás borres trabajo del usuario automáticamente.
- Usa un helper `crear(clase, propiedades, padre)` para no repetir 300 asignaciones.
- Está comentado por secciones, en el mismo orden que el árbol de la Fase 2.
- Termina con un `print` de éxito y un resumen de qué se creó y qué hay que editar.

El script puede pasar de 1000 o 2000 líneas. No lo recortes por tamaño: recórtalo solo si hay repetición que un bucle o un componente resuelve mejor. La calidad y la editabilidad manda sobre la brevedad.

Los detalles técnicos (cómo escribir `Source` de ModuleScripts desde la Command Bar, cadenas largas anidadas, qué hacer si el pegado se corta) están en `references/command-bar-installer.md`. Léelo antes de generar el instalador.

## Fase 5 — Entrega

Cierra siempre con:

1. Los pasos exactos de instalación (View → Command Bar → pegar → Enter).
2. Qué debe editar el usuario: los IDs de `Icons`, y los colores de `Theme` si quiere otra identidad.
3. Cómo probarlo en móvil: Studio → Test → Device, probando al menos un teléfono pequeño y una tablet.
4. Qué se puede extender después (más pestañas, más variantes de botón, conexión con datos del servidor).

## Checklist antes de entregar

No entregues una UI que falle cualquiera de estos puntos:

- [ ] La interfaz sirve al objetivo que declaró el usuario en la Fase 0, y se puede señalar cómo.
- [ ] No hay búsqueda ni filtros en una lista que no los necesita.
- [ ] Hay jerarquía: se distingue de un vistazo qué es título, qué es acción principal y qué es secundario.
- [ ] Un solo color de acento y no está usado en todo.
- [ ] Todos los espaciados, colores, radios y duraciones vienen de `Theme`.
- [ ] Cada elemento interactivo tiene, como mínimo, estados normal, hover, presionado y deshabilitado.
- [ ] Existen los estados de vacío, cargando y error donde aplique. Una lista sin datos no debe verse como un bug.
- [ ] La UI se reorganiza en pantalla estrecha; no es la de PC encogida.
- [ ] Los objetivos táctiles son cómodos para un dedo, no para un cursor.
- [ ] Ningún asset ID inventado; los pendientes son `rbxassetid://0` en un módulo editable.
- [ ] Ningún emoji de color en un elemento crítico (precio, moneda, cerrar, confirmar, bloqueado).
- [ ] Ningún alto o ancho calculado a mano para "el espacio que sobra". Se reparte con `UIFlexItem` o se mide; nunca `1, -160`.
- [ ] Las animaciones duran entre 0.12 s y 0.30 s y comunican algo.
- [ ] Si hay sonidos: volumen bajo, con throttle para que una lista no suene a metralleta, y se pueden silenciar.
- [ ] Ningún ID de audio inventado; los pendientes son `rbxassetid://0` y la UI funciona en silencio sin errores.
- [ ] El instalador avisa si la UI ya existe, y no borra nada.
- [ ] No hay ningún bloque de código copiado 20 veces que debería ser un componente.
- [ ] Si es un HUD: no bloquea el input, el texto es legible sobre cualquier fondo y respeta las zonas del joystick y el salto.
- [ ] Repasada la sección relevante de `references/known-pitfalls.md` para el tipo de UI construida.
- [ ] Ninguna lista destruye y recrea instancias al filtrar o refrescar. Se reutiliza un lote fijo.
- [ ] Ningún evento se conecta dentro de una función de refresco.
- [ ] Ningún bucle `while` refrescando la UI donde bastaría un evento.

## Referencias

Lee el archivo que corresponda a la fase en la que estás; no cargues todo de golpe.

| Archivo | Cuándo leerlo |
|---|---|
| `references/premium-design.md` | Fase 1. Dirección visual, paletas, tipografía, jerarquía, antipatrones. |
| `references/roblox-gui-patterns.md` | Fase 2 y 3. Equivalencias con CSS moderno, layouts, constraints, propiedades correctas, errores comunes de Luau/GUI. |
| `references/responsive-ui.md` | Fase 2 y 3. Breakpoints, Scale vs Offset, rediseño móvil, detección de tamaño. |
| `references/animations.md` | Fase 3. TweenService, duraciones, easing, patrones de apertura/selección/feedback. |
| `references/states.md` | Fase 3. Los nueve estados de interfaz y cómo implementarlos. |
| `references/sound-design.md` | Fase 3. Los siete sonidos de UI, volúmenes, throttle, qué no debe sonar. |
| `references/command-bar-installer.md` | Fase 4. Cómo generar un instalador que funcione de verdad. |
| `references/performance.md` | Fase 2 y 3. Pooling, virtualización, presupuesto de instancias, fugas de conexiones. |
| `references/emoji-safety.md` | Fase 0 y Fase 3. Qué glifos renderizan de verdad, qué nunca va en emoji. |
| `references/accessibility.md` | Fase 3 y checklist. Contraste, tamaños táctiles, legibilidad, soporte de gamepad. |
| `references/hud-vs-menu.md` | Fase 0 en adelante, si la UI es permanente en pantalla. Reglas propias del HUD. |
| `references/known-pitfalls.md` | Cuando algo se ve mal y no está claro por qué, y como repaso antes de entregar. |
| `references/audit-mode.md` | Auditar una UI existente, o cuando se invoca `/axiom audit`. |

Plantillas listas para adaptar en `templates/`: `Theme.lua`, `Icons.lua`, `Sounds.lua`, `Component.lua`, `Installer.lua`.
Ejemplos completos de flujo en `examples/`: `BusSelector.md`, `Shop.md`, `Inventory.md`, `Settings.md`.
