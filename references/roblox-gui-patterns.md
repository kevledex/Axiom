# Patrones de GUI en Roblox

Leer en las Fases 2 y 3.

Contenido:
1. Mentalidad CSS traducida a Roblox
2. Layouts: UIListLayout y UIGridLayout
3. Constraints
4. Elección de clase de instancia
5. Propiedades que casi nadie configura y deberían
6. Patrones de estructura
7. Errores comunes que rompen la UI
8. Reglas de rendimiento

---

## 1. Mentalidad CSS traducida a Roblox

La idea es pensar como en CSS moderno, no copiar CSS.

| CSS | Roblox | Nota |
|---|---|---|
| `display: flex` | `UIListLayout` + `FillDirection` | `Horizontal` o `Vertical` |
| `gap` | `UIListLayout.Padding` | usa `UDim.new(0, 12)` |
| `justify-content` | `HorizontalAlignment` / `VerticalAlignment` | |
| `flex-wrap` | `UIListLayout.Wraps = true` | disponible en versiones recientes de Studio |
| `flex: 1` | `UIFlexItem.FlexMode = Enum.UIFlexMode.Fill` | hijo de un elemento con UIListLayout |
| `display: grid` | `UIGridLayout` | celdas de tamaño uniforme |
| `padding` | `UIPadding` | los cuatro lados por separado |
| `border-radius` | `UICorner` | |
| `border` | `UIStroke` | `Thickness`, `Color`, `Transparency`, `ApplyStrokeMode` |
| `background: linear-gradient` | `UIGradient` | `Color` (ColorSequence) y `Rotation` |
| `opacity` en un contenedor | `CanvasGroup` + `GroupTransparency` | |
| `transition` | `TweenService` | ver `animations.md` |
| `transform: scale()` | `UIScale` | anima `Scale`, no `Size` |
| `aspect-ratio` | `UIAspectRatioConstraint` | |
| `min-width` / `max-width` | `UISizeConstraint` | en píxeles |
| `overflow: auto` | `ScrollingFrame` | + `AutomaticCanvasSize` |
| `z-index` | `ZIndex` | con `ZIndexBehavior = Sibling` en el ScreenGui |
| `@media` | tamaño de `ScreenGui.AbsoluteSize` + layouts alternativos | ver `responsive-ui.md` |
| `width: fit-content` | `AutomaticSize` | `Enum.AutomaticSize.X`, `.Y` o `.XY` |
| `cursor: pointer` | `TextButton` / `ImageButton` (`Active`, `AutoButtonColor`) | apaga `AutoButtonColor` y anima tú |

## 2. Layouts: UIListLayout y UIGridLayout

`UIListLayout` es la herramienta principal. Con él, dejas de calcular posiciones.

```lua
local lista = Instance.new("UIListLayout")
lista.FillDirection = Enum.FillDirection.Vertical
lista.Padding = UDim.new(0, 12)
lista.SortOrder = Enum.SortOrder.LayoutOrder
lista.HorizontalAlignment = Enum.HorizontalAlignment.Center
lista.Parent = contenedor
```

- Pon **siempre** `SortOrder = LayoutOrder` y asigna `LayoutOrder` a los hijos. Con el orden por nombre, "Item10" va antes de "Item2".
- Los hijos gestionados por un layout no necesitan `Position`. Asignarla no hace nada y confunde a quien lea el código.
- `UIListLayout` no recorta: si el contenido supera el contenedor, se desborda. Para listas largas usa `ScrollingFrame`.

`UIGridLayout` obliga a que todas las celdas midan igual (`CellSize`, `CellPadding`). Es ideal para inventarios y catálogos. Si las tarjetas deben tener anchos distintos, no uses grid: usa lista con `Wraps` o filas anidadas.

`ScrollingFrame` bien configurado:

```lua
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ElasticBehavior = Enum.ElasticBehavior.Never
```

Con `AutomaticCanvasSize` ya no hay que recalcular `CanvasSize` a mano cada vez que se añade un ítem — un bug clásico que deja listas que no se pueden desplazar.

## 3. Constraints

- **`UIAspectRatioConstraint`** — mantiene la proporción de tarjetas e iconos al escalar. Imprescindible para que un icono cuadrado no se deforme entre monitores.
- **`UISizeConstraint`** — `MinSize` y `MaxSize` en píxeles. La forma correcta de evitar que un panel escalado se vuelva minúsculo en móvil o absurdo en 4K.
- **`UITextSizeConstraint`** — límites de `TextSize` cuando usas `TextScaled`.
- **`UIScale`** — un único punto para escalar todo un subárbol; también es la palanca para el escalado global por resolución.

Regla: si un elemento usa `Size` en escala, casi siempre necesita también un `UISizeConstraint` o un `UIAspectRatioConstraint`.

## 4. Elección de clase de instancia

| Necesidad | Clase |
|---|---|
| Contenedor / panel | `Frame` |
| Contenedor con opacidad de grupo o máscara | `CanvasGroup` |
| Texto | `TextLabel` |
| Texto clicable | `TextButton` |
| Icono o imagen | `ImageLabel` |
| Icono clicable | `ImageButton` |
| Botón con icono **y** texto | `TextButton` + `ImageLabel` hijo (no `ImageButton` con texto encima) |
| Lista larga | `ScrollingFrame` |
| Barra de progreso | `Frame` exterior + `Frame` interior animando `Size` |
| Entrada de texto | `TextBox` |
| Modelo 3D en la UI | `ViewportFrame` |

Para el `ScreenGui` raíz:

```lua
pantalla.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pantalla.IgnoreGuiInset = true
pantalla.ResetOnSpawn = false
pantalla.DisplayOrder = 10
```

`ResetOnSpawn = false` evita que la UI se reinicie cada vez que el jugador muere. `IgnoreGuiInset = true` te da toda la pantalla, pero entonces **tú** eres responsable de dejar espacio para el botón de Roblox arriba a la izquierda.

## 5. Propiedades que casi nadie configura y deberían

- `AutoButtonColor = false` en todos los botones. El oscurecimiento automático de Roblox arruina cualquier diseño; anima tú el color.
- `BorderSizePixel = 0` en todo. El borde negro por defecto es el sello de una UI sin terminar.
- `BackgroundTransparency = 1` en los `TextLabel` que solo llevan texto.
- `TextTruncate = Enum.TextTruncate.AtEnd` para nombres largos; mejor "Autobús Interprovin…" que texto que se sale.
- `ClipsDescendants = true` en paneles con contenido animado que no debe salirse.
- `Active = true` en frames que reciben input táctil.
- `Selectable` / `SelectionOrder` si quieres soporte de gamepad.
- `ImageColor3` en `ImageLabel` con iconos monocromos: un solo asset blanco sirve para todos los colores del tema.
- `ScaleType = Enum.ScaleType.Slice` + `SliceCenter` para imágenes de marco que deben estirarse sin deformarse.

## 6. Patrones de estructura

**Tarjeta**
```
Card (Frame) — UICorner, UIStroke, UIPadding, UIScale
├── Icon (ImageLabel) — UIAspectRatioConstraint
├── Title (TextLabel)
├── Subtitle (TextLabel)
└── Badge (Frame + TextLabel)
```
El `UIScale` va en la tarjeta, no en los hijos: así hover y press animan el conjunto.

**Panel modal**
```
Overlay (Frame, fondo negro semitransparente, cubre la pantalla)
└── Dialog (Frame centrado)
    ├── Header
    ├── Content
    └── Actions (UIListLayout horizontal, alineado a la derecha)
```
El overlay también captura clics: sin él, el jugador puede pulsar botones detrás del modal.

**Pestañas**
```
Tabs (Frame + UIListLayout horizontal)
├── TabButton x N (LayoutOrder ascendente)
└── Indicator (Frame fino que se mueve con Tween al Tab activo)
```
El indicador que se desliza es uno de los detalles que más "sube" la percepción de calidad, y cuesta diez líneas.

## 7. Errores comunes que rompen la UI

- Poner `Position` a hijos de un `UIListLayout`: no tiene efecto y engaña.
- `ScrollingFrame` con `CanvasSize` fijo: la lista crece y no se puede bajar.
- Usar `Offset` para todo: la UI queda diminuta en pantallas grandes y desbordada en pequeñas.
- Usar `Scale` para todo sin `UISizeConstraint`: el texto queda ilegible en móvil.
- `UICorner` con `UDim.new(0.5, 0)` en un frame no cuadrado: sale una cápsula deformada.
- Depender solo de `MouseEnter`/`MouseLeave`: en táctil no existe hover, así que la UI parece muerta en móvil.
- Lógica de UI en un `Script` del servidor: la UI del jugador se maneja en cliente.
- `while true do ... end` para actualizar la UI: usa eventos, o `RunService.RenderStepped` solo si de verdad hace falta cada frame.
- Conectar eventos y nunca desconectarlos al destruir la UI: fuga de memoria.
- Nombres duplicados entre hermanos: `FindFirstChild` devuelve el que no esperas.
- **Calcular a mano el espacio que sobra**: `Size = UDim2.new(1, 0, 1, -160)` en el último hijo de un `UIListLayout`. Ese 160 tiene que coincidir exactamente con la suma de las otras filas, sus separaciones y el padding del contenedor; en cuanto cambia cualquiera de los tres, el hijo desborda y su contenido tapa la fila de arriba. Se ve sobre todo en teléfonos, donde la altura disponible es menor. La solución es `UIFlexItem` con `FlexMode = Fill`, o medir los hermanos con `AbsoluteSize` y repartir. Nunca el número a mano.
- **Fila horizontal de ancho fijo con contenido variable** (chips de filtro, pestañas): si los elementos no caben, se recortan sin avisar. `AutomaticSize.Y` en la fila más `Wraps = true` en el `UIListLayout` hace que crezca a dos líneas en vez de cortar.
- **Contenedores sin `ClipsDescendants`**: cuando algo desborda, se pinta encima de sus hermanos y el fallo parece un problema de `ZIndex` cuando en realidad es de tamaño.

## 8. Reglas de rendimiento

- Asigna `Parent` **al final**, después de las propiedades. Cada cambio con el objeto ya en el árbol dispara un recálculo de layout.
- No uses el segundo argumento de `Instance.new("Frame", padre)`: hace exactamente lo contrario a lo anterior.
- Reutiliza instancias en listas largas en vez de destruir y crear en cada refresco.
- `Visible = false` en el contenedor raíz es más barato que destruir y reconstruir una UI que se abre y cierra a menudo.
- Cachea las referencias (`local panelDetalles = main.DetailsPanel`) en vez de recorrer el árbol en cada llamada.
