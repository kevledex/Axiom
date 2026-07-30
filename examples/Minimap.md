# Ejemplo: minimapa

**Petición típica:** "Un minimapa para mi juego."

HUD, y de los más caros de hacer bien. Lee `references/hud-vs-menu.md`.

## Primera decisión: cómo se dibuja el mapa

Tres enfoques, con costes muy distintos:

**1. Imagen estática del mapa (recomendado).** Haces una captura aérea de tu mundo en Studio, la subes como asset, y la muestras desplazada según la posición del jugador. Coste: un `ImageLabel`. Es lo que usa la mayoría de los juegos y con diferencia la opción más eficiente.

**2. `ViewportFrame` con una cámara superior.** Muestra el mundo real, así que refleja cambios en tiempo real. Coste: **es lo más caro que se puede poner en una UI de Roblox**. Un `ViewportFrame` renderiza una escena aparte cada frame. Solo si el mapa cambia de verdad y es imprescindible verlo.

**3. Formas generadas.** Dibujar el mapa con `Frame` a partir de las partes del mundo. Solo viable en mapas muy simples o basados en cuadrícula; con cien partes son cien instancias.

Para el 90 % de los casos: opción 1.

## Estructura

```
MinimapUI (ScreenGui)
└── Root (Frame, cuadrado, Active = false)
    ├── Viewport (Frame, ClipsDescendants = true)
    │   ├── MapImage (ImageLabel, más grande que el viewport, se desplaza)
    │   └── Markers (Frame)
    │       ├── PlayerDot (siempre en el centro)
    │       ├── TeammateDot x N (pooling)
    │       └── ObjectiveIcon x N
    ├── Frame decorativo (borde, brújula)
    └── ZoomButtons (opcional, solo si el diseño lo pide)
```

`ClipsDescendants = true` en `Viewport` es lo que hace que el mapa se recorte al cuadro. Sin eso, la imagen desborda por toda la pantalla.

## La conversión de mundo a UI

Es el núcleo del minimapa. Se necesitan dos datos de tu mundo: el centro y el tamaño total en studs.

```lua
local CENTRO_MUNDO = Vector2.new(0, 0)      -- X, Z del centro del mapa
local TAMANO_MUNDO = 2048                    -- studs de lado
local TAMANO_IMAGEN = 1024                   -- pixeles de lado de tu imagen
local ZOOM = 3                               -- cuanto se amplia dentro del cuadro

local ESCALA = (TAMANO_IMAGEN * ZOOM) / TAMANO_MUNDO

-- Convierte una posicion del mundo a un desplazamiento en pixeles de la imagen
local function mundoAImagen(posicion)
    local relativo = Vector2.new(posicion.X, posicion.Z) - CENTRO_MUNDO
    return relativo * ESCALA
end
```

Y el desplazamiento del mapa, para mantener al jugador siempre en el centro:

```lua
local function actualizar()
    local personaje = jugador.Character
    local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
    if not raiz then
        return
    end

    local desplazamiento = mundoAImagen(raiz.Position)

    -- La imagen se mueve al contrario que el jugador
    mapa.Position = UDim2.new(0.5, -desplazamiento.X, 0.5, -desplazamiento.Y)
end
```

El signo negativo es la parte que todo el mundo equivoca la primera vez: si el jugador va al norte, el mapa baja.

## Marcadores

Los marcadores de otros jugadores u objetivos usan la misma conversión, pero relativa al jugador:

```lua
local function posicionarMarcador(marcador, posicionMundo, posicionJugador)
    local relativo = mundoAImagen(posicionMundo) - mundoAImagen(posicionJugador)

    -- Si sale del cuadro, se pega al borde en vez de desaparecer
    local limite = viewport.AbsoluteSize.X / 2 - 8
    if relativo.Magnitude > limite then
        relativo = relativo.Unit * limite
        marcador.ImageTransparency = 0.4   -- fuera de rango, atenuado
    else
        marcador.ImageTransparency = 0
    end

    marcador.Position = UDim2.new(0.5, relativo.X, 0.5, relativo.Y)
end
```

Pegar al borde en lugar de ocultar es una decisión de diseño importante: le dice al jugador "hay algo en esa dirección, lejos", que es información útil.

Los marcadores **se reutilizan**, nunca se crean por frame. Un lote fijo de 12–16 basta para casi cualquier caso (ver `performance.md`).

## Rotación: el punto polémico

Dos modos, y conviene ofrecer el ajuste:

- **Norte arriba** — el mapa no gira; el icono del jugador sí. Mejor para orientarse y para memorizar el mapa. Es el que eligen los juegos con mapas grandes.
- **Jugador arriba** — el mapa gira; el icono siempre mira hacia arriba. Más intuitivo para moverse, más desorientador para aprender el mapa.

Si haces el segundo: rota la **imagen**, no el contenedor, y compensa la rotación de cada marcador para que sus iconos no queden del revés.

```lua
local direccion = raiz.CFrame.LookVector
local anguloY = math.deg(math.atan2(direccion.X, direccion.Z))
mapa.Rotation = anguloY
```

Al rotar una imagen cuadrada dentro de un cuadro cuadrado, las esquinas se quedan vacías al girar 45°. La imagen tiene que ser al menos 1.42 veces (raíz de 2) el lado del cuadro para cubrirlo en cualquier ángulo.

## Refresco

```lua
local ultimo = 0
RunService.RenderStepped:Connect(function()
    local ahora = os.clock()
    if ahora - ultimo < 0.06 then   -- ~16 veces por segundo
        return
    end
    ultimo = ahora
    actualizar()
end)
```

Un minimapa a 16 actualizaciones por segundo se ve perfectamente fluido y cuesta un cuarto de hacerlo cada frame. Con marcadores de otros jugadores, la diferencia en móvil es notable.

## Estados

- **Fuera del mapa** (el jugador sale de los límites): el mapa deja de desplazarse en ese eje y el icono se mueve hacia el borde. Nunca dejes que la imagen se despegue y aparezca el fondo vacío.
- **Zona sin descubrir**, si el juego lo usa: una capa oscura encima que se recorta. Es costoso de hacer bien; valóralo antes de prometerlo.
- **Sin personaje** (muerto, cargando): el minimapa se atenúa, no desaparece de golpe.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Lado | 180 px | 110 px |
| Zoom | 3 | 4 (menos superficie, más cerca) |
| Marcadores | todos | solo jugadores y objetivo activo |
| Posición | esquina superior derecha | esquina superior derecha, más pegado |

En compacto, sube el zoom: un mapa de 110 px con el mismo zoom que uno de 180 muestra tanto terreno que no se distingue nada.

## Cómo capturar la imagen del mapa

En Studio: coloca una cámara mirando hacia abajo sobre el centro del mapa, con `FieldOfView` bajo y a suficiente altura para abarcarlo todo, y captura la ventana. Anota la altura y el centro exactos: son los números que necesitas para `CENTRO_MUNDO` y `TAMANO_MUNDO`. Si el mapa cambia, hay que volver a capturar — es la contrapartida de la opción más eficiente.
