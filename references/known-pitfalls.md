# Errores conocidos

Catálogo de fallos que aparecen una y otra vez en interfaces de Roblox, con la causa real y el arreglo. Consultar cuando algo se ve mal y no está claro por qué, y repasar antes de entregar.

Cada entrada sigue el mismo formato: **síntoma** (lo que se ve), **causa** (lo que pasa de verdad) y **arreglo**.

Contenido:
1. Layout y tamaños
2. Listas y scroll
3. Texto e iconos
4. Interacción y eventos
5. Responsive y móvil
6. Instalación y Command Bar
7. Rendimiento y fugas

---

## 1. Layout y tamaños

### Una fila queda tapada por el contenido de abajo

**Síntoma:** los chips de filtro, o la barra de búsqueda, aparecen cortados o con las tarjetas pintadas encima. Suele verse solo en pantallas de poca altura.

**Causa:** el último hijo del contenedor tiene el alto calculado a mano, del tipo `Size = UDim2.new(1, 0, 1, -160)`. Ese 160 tiene que coincidir exactamente con la suma de las otras filas, sus separaciones y el padding del contenedor. En cuanto cambia cualquiera de los tres, el hijo pide más espacio del que hay y desborda.

**Arreglo:** que el espacio restante se reparta, no se calcule.

```lua
cuerpo.Size = UDim2.new(1, 0, 0, 0)
local flex = Instance.new("UIFlexItem")
flex.FlexMode = Enum.UIFlexMode.Fill
flex.Parent = cuerpo
```

Si la versión de Studio no tiene `UIFlexItem`, mide en lugar de restar un número fijo: recorre los hermanos, suma sus `AbsoluteSize.Y` y el padding del layout, y resta eso al alto disponible.

### Un elemento se pinta encima de otro sin razón aparente

**Síntoma:** parece un problema de `ZIndex`, pero cambiar el `ZIndex` no lo arregla del todo.

**Causa:** el contenedor no tiene `ClipsDescendants` y algo dentro es más grande de lo que cabe, así que se dibuja fuera de sus límites, sobre sus hermanos.

**Arreglo:** `ClipsDescendants = true` en el contenedor. No arregla el tamaño mal calculado, pero convierte un fallo confuso en uno evidente: verás el contenido recortado y sabrás dónde mirar.

### Una cápsula sale deformada

**Síntoma:** un botón redondeado se ve como un óvalo raro.

**Causa:** `UICorner` con `CornerRadius = UDim.new(0.5, 0)` en un elemento que no es cuadrado. El 0.5 escalar se calcula sobre el lado menor, y el resultado depende de la proporción.

**Arreglo:** para una píldora, radio en offset igual a la mitad del alto (`UDim.new(0, 22)` para un botón de 44 px). Para un círculo perfecto, `UDim.new(0.5, 0)` **más** un `UIAspectRatioConstraint` de 1.

### Los hijos ignoran la posición que les asigno

**Síntoma:** pones `Position` y el elemento aparece en otro sitio.

**Causa:** el padre tiene un `UIListLayout` o `UIGridLayout`. El layout posiciona a todos sus hijos y sobrescribe lo que pongas.

**Arreglo:** ordena con `LayoutOrder`, no con `Position`. Si de verdad necesitas posicionar a mano un elemento dentro de ese contenedor (un badge en una esquina, un overlay), sácalo del flujo poniéndolo en un contenedor sin layout, o usa un wrapper.

### El borde negro por defecto arruina el diseño

**Síntoma:** todos los frames tienen una línea oscura de 1 px alrededor.

**Causa:** `BorderSizePixel` vale 1 por defecto.

**Arreglo:** `BorderSizePixel = 0` en absolutamente todo. Si quieres borde, `UIStroke`, que sí se puede colorear y hacer semitransparente.

## 2. Listas y scroll

### La lista crece pero no se puede desplazar

**Síntoma:** hay más elementos de los que caben y el scroll no llega al final, o no se mueve.

**Causa:** `CanvasSize` está fijo y no crece con el contenido.

**Arreglo:** `AutomaticCanvasSize = Enum.AutomaticSize.Y` y `CanvasSize = UDim2.new(0, 0, 0, 0)`. Con eso el canvas se ajusta solo. La única excepción es cuando virtualizas: ahí sí se fija a mano, porque tú controlas las posiciones.

### Un elemento que no debería estar en la rejilla aparece como una celda

**Síntoma:** el estado vacío, un overlay o un separador se coloca como si fuera un ítem más de la lista.

**Causa:** `UIGridLayout` y `UIListLayout` gestionan **todos** los `GuiObject` hijos. No hay forma de excluir uno.

**Arreglo:** envuelve la lista en un contenedor sin layout, y pon el overlay como hermano del `ScrollingFrame`, no como hijo:

```
ListWrapper (Frame, sin layout)
├── Cards (ScrollingFrame + UIGridLayout)
└── EmptyState (Frame, encima, ZIndex mayor)
```

### Scroll dentro de scroll que se pelean

**Síntoma:** al arrastrar, unas veces se mueve la lista interior y otras la exterior.

**Causa:** dos `ScrollingFrame` anidados en el mismo eje.

**Arreglo:** evita anidarlos en el mismo eje. Si de verdad hacen falta (una lista vertical con carruseles horizontales dentro), que sean ejes distintos y fija `ScrollingDirection` en cada uno.

### La lista da un tirón al filtrar

**Síntoma:** microcongelación cada vez que se escribe en el buscador.

**Causa:** el refresco destruye y vuelve a crear las instancias.

**Arreglo:** lote fijo reutilizable. Ver `performance.md`.

## 3. Texto e iconos

### Aparece un cuadro vacío en lugar de un icono

**Síntoma:** un rectángulo donde debería haber un emoji, sobre todo en el dispositivo del jugador y no en tu Studio.

**Causa:** las fuentes de Roblox no incluyen el set de emoji en color, y el respaldo depende del sistema de cada dispositivo.

**Arreglo:** `ImageLabel` para lo importante, o símbolos monocromos del tipo `✕ ✓ ★ ▸ ⚙`. Detalle completo en `emoji-safety.md`. Ojo con `⚙` frente a `⚙️`: el segundo lleva un selector de variación invisible que lo convierte en emoji de color.

### El texto se sale del contenedor

**Síntoma:** un nombre largo desborda la tarjeta o se solapa con el elemento de al lado.

**Causa:** no hay control de qué pasa cuando el texto no cabe.

**Arreglo:** `TextTruncate = Enum.TextTruncate.AtEnd` para una línea, o `TextWrapped = true` con un alto suficiente para varias. Y prueba siempre con el nombre más largo que pueda existir, no con "Bus 1".

### El texto se vuelve ilegible en móvil

**Síntoma:** letra minúscula en pantallas pequeñas.

**Causa:** `TextScaled = true` sin límites, así que el texto se encoge con el contenedor sin suelo.

**Arreglo:** añade un `UITextSizeConstraint` con `MinTextSize = 14`.

### La imagen aparece en blanco al abrir la UI y luego se rellena

**Síntoma:** parpadeo de iconos vacíos durante el primer segundo.

**Causa:** los assets se cargan cuando se muestran.

**Arreglo:** precarga con `ContentProvider:PreloadAsync` antes de mostrar el panel.

## 4. Interacción y eventos

### Un clic dispara la acción varias veces

**Síntoma:** compras dobles, el panel se abre y se cierra, el contador sube de dos en dos.

**Causa:** el evento se conectó dentro de una función que se ejecuta más de una vez (el refresco de la lista, la apertura del panel). Cada pasada añade una conexión más.

**Arreglo:** conecta una sola vez, justo después de crear la instancia. Si la instancia se reutiliza (pooling), esto sale gratis. Si de verdad hay que reconectar, guarda las conexiones y desconéctalas antes.

### El botón se oscurece de forma fea al pulsarlo

**Síntoma:** el color del botón cambia a algo que no está en tu paleta.

**Causa:** `AutoButtonColor` está activo y Roblox aplica su propio oscurecimiento por encima de tu animación.

**Arreglo:** `AutoButtonColor = false` y anima tú el color con `TweenService`.

### La interfaz parece muerta en móvil

**Síntoma:** en PC responde bien; en el teléfono, nada reacciona al tocar.

**Causa:** todo el feedback está en `MouseEnter` / `MouseLeave`. En táctil no existe el hover.

**Arreglo:** el estado presionado lleva el peso en móvil. Usa `InputBegan` / `InputEnded` filtrando por `MouseButton1` y `Touch`, o `MouseButton1Down` / `Up`, que también se disparan con el toque.

### Se puede pulsar un botón que está detrás del modal

**Síntoma:** el jugador toca "fuera" del diálogo y activa algo del panel de abajo.

**Causa:** el overlay es decorativo y no captura la entrada.

**Arreglo:** el overlay es un `TextButton` (o un `Frame` con `Active = true`) que cubre toda la pantalla y consume el clic. Si quieres que tocar fuera cierre el modal, ese mismo elemento lo hace.

### Un dato solo se ve al pasar el ratón

**Síntoma:** información que en móvil no existe.

**Causa:** tooltips o detalles ligados a hover.

**Arreglo:** si el dato importa, hazlo visible siempre o muéstralo al tocar. El hover es un extra de PC, nunca el único camino.

### La UI se reinicia cuando el jugador muere

**Síntoma:** el menú se cierra y pierde su estado al reaparecer.

**Causa:** `ResetOnSpawn` vale `true` por defecto en el `ScreenGui`.

**Arreglo:** `ResetOnSpawn = false`.

## 5. Responsive y móvil

### El panel se sale de la pantalla en el teléfono

**Síntoma:** el botón de cerrar queda fuera y no hay forma de salir.

**Causa:** tamaño y posición en offsets fijos (`UDim2.new(0, 800, 0, 500)`).

**Arreglo:** `UDim2.fromScale` con `AnchorPoint` centrado, más un `UISizeConstraint` con `MinSize` y `MaxSize`. Ver `responsive-ui.md`.

### La UI se adapta al abrir pero no al girar el teléfono

**Síntoma:** en horizontal se ve mal hasta que se cierra y se vuelve a abrir.

**Causa:** el modo se calculó una sola vez al arrancar.

**Arreglo:** conecta `GetPropertyChangedSignal("AbsoluteSize")` del `ScreenGui` y vuelve a aplicar el layout. Eso cubre también el redimensionado de la ventana en PC.

### Algo queda debajo del botón de Roblox

**Síntoma:** el título o un botón chocan con el logo de arriba a la izquierda.

**Causa:** `IgnoreGuiInset = true` da toda la pantalla, incluida la zona reservada.

**Arreglo:** reserva 36–48 px de margen superior, o consulta `GuiService:GetGuiInset()`. En móvil, además, respeta las esquinas inferiores donde están el joystick y el botón de salto.

### Los botones son incómodos de tocar

**Síntoma:** hay que apuntar, se falla, se toca el de al lado.

**Causa:** objetivos táctiles dimensionados para un cursor.

**Arreglo:** mínimo 44×44 px de área tocable, con 8 px de separación entre objetivos. El área puede ser mayor que el icono visible.

## 6. Instalación y Command Bar

### El instalador no crea nada y no dice por qué

**Síntoma:** se pega el script, se pulsa Enter y no pasa nada visible.

**Causa:** ya existía una UI con ese nombre y el script terminó en el `warn` de protección. El mensaje está en la Output, que puede estar cerrada.

**Arreglo:** abre la Output (View → Output). Es donde el instalador informa de todo.

### `script.Parent` es nil en el instalador

**Síntoma:** error al ejecutar el script en la Command Bar.

**Causa:** el código de la Command Bar no está dentro de ningún script, así que no hay `script`.

**Arreglo:** referencias explícitas: `game:GetService("StarterGui")`.

### No se puede escribir el código de los módulos

**Síntoma:** falla al asignar `Source`.

**Causa:** se está ejecutando en tiempo de ejecución (modo Play) en lugar de en modo edición. Escribir `Source` requiere el nivel de permisos de la Command Bar en edición.

**Arreglo:** detén la simulación y ejecuta el instalador en modo edición.

### La cadena larga se corta a mitad

**Síntoma:** error de sintaxis en el instalador, o un módulo con el código truncado.

**Causa:** el código de dentro contiene `]]` (de un comentario de bloque o de una tabla anidada) y cierra antes de tiempo la cadena `[[ ... ]]`.

**Arreglo:** usa delimitadores con signos igual: `[==[ ... ]==]`. Si el contenido incluye `]==]`, sube a `[===[`.

### El pegado del script se corta

**Síntoma:** el instalador está incompleto al pegarlo.

**Causa:** límite de entrada del campo.

**Arreglo:** parte el instalador en partes numeradas, donde cada una comprueba que la anterior se ejecutó. Ver `command-bar-installer.md`.

## 7. Rendimiento y fugas

### El número de instancias crece cada vez que se abre el panel

**Síntoma:** el juego va cada vez peor con el uso.

**Causa:** algo se crea al abrir y no se destruye al cerrar, o se duplica el `ScreenGui`.

**Arreglo:** comprueba con `print(#pantalla:GetDescendants())` al abrir y cerrar varias veces. Si sube, ahí está la fuga. Prefiere `Visible = false` sobre destruir y reconstruir.

### Tirones en móvil con la UI abierta

**Síntoma:** los FPS caen al mostrar el panel.

**Causa habitual, por orden:** demasiadas instancias vivas, un `ViewportFrame` por tarjeta, `CanvasGroup` grandes animándose, o un bucle refrescando texto cada frame.

**Arreglo:** ver `performance.md`. Empieza contando instancias: suele ser eso.

### Los eventos siguen ejecutándose tras cerrar la UI

**Síntoma:** errores en la Output que mencionan objetos que ya no existen.

**Causa:** conexiones a señales externas (`RunService`, remotos, atributos) que sobreviven al `Destroy` de la interfaz.

**Arreglo:** `Destroy()` limpia los eventos de la propia instancia, pero no esas. Guárdalas y desconéctalas explícitamente al cerrar.
