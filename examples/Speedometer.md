# Ejemplo: velocímetro

**Petición típica:** "Un velocímetro bien hecho para mi juego de conducción."

Esto no es un menú. Es un HUD: lee `references/hud-vs-menu.md` antes de diseñarlo. El jugador está mirando la carretera, no el velocímetro.

## Decisiones antes de diseñar

- **¿Digital, analógico o los dos?** Un número grande se lee más rápido. Un arco con aguja comunica mejor la proporción (cuánto queda para el máximo). La combinación —arco de fondo con el número grande en el centro— es lo que usa casi todo juego de conducción moderno, y por buena razón.
- **¿Qué más necesita el jugador ahí?** Marcha, combustible, límite de la vía, nombre de la ruta. Cada dato extra compite con la velocidad. Si son más de dos, el resto va en un panel aparte.
- **¿Dónde?** Esquina inferior derecha o centro-abajo. En móvil, cuidado: abajo a la derecha está el botón de salto y abajo a la izquierda el joystick.

## Estructura

```
SpeedometerUI (ScreenGui, DisplayOrder bajo)
└── Root (Frame, Active = false)      <- el clic atraviesa al mundo
    ├── Gauge (ImageLabel, arco de fondo)
    │   └── Needle (ImageLabel, Rotation animada)
    ├── Readout
    │   ├── Value (TextLabel, "120", Bold, ancho fijo)
    │   └── Unit (TextLabel, "km/h", pequeño, TextSecondary)
    └── Gear (TextLabel, "D")
```

`Active = false` en `Root` es obligatorio. Sin eso, el HUD roba los clics que deberían llegar al juego.

## El arco no existe como primitiva

Roblox no tiene un elemento de arco. Tres formas de resolverlo, de más simple a más flexible:

**1. Imagen de arco + aguja rotada.** Un `ImageLabel` con el arco dibujado (subido por ti) y una aguja encima cuya `Rotation` se anima. Es la más barata en instancias y la que mejor se ve.

```lua
local ANGULO_MINIMO = -120
local ANGULO_MAXIMO = 120

local function anguloParaVelocidad(velocidad, maxima)
    local proporcion = math.clamp(velocidad / maxima, 0, 1)
    return ANGULO_MINIMO + (ANGULO_MAXIMO - ANGULO_MINIMO) * proporcion
end
```

**2. Segmentos que se encienden.** N marcas colocadas en círculo con trigonometría; las que están por debajo de la velocidad actual se pintan del color de acento. Se ve más "digital" y no necesita ningún asset.

```lua
local RADIO = 70
local TOTAL = 24

for indice = 1, TOTAL do
    local proporcion = (indice - 1) / (TOTAL - 1)
    local angulo = math.rad(ANGULO_MINIMO + (ANGULO_MAXIMO - ANGULO_MINIMO) * proporcion - 90)

    local marca = Instance.new("Frame")
    marca.Size = UDim2.new(0, 3, 0, 12)
    marca.AnchorPoint = Vector2.new(0.5, 0.5)
    marca.Position = UDim2.new(0.5, math.cos(angulo) * RADIO, 0.5, math.sin(angulo) * RADIO)
    marca.Rotation = ANGULO_MINIMO + (ANGULO_MAXIMO - ANGULO_MINIMO) * proporcion
    marca.BorderSizePixel = 0
    marca.Parent = gauge
end
```

El `-90` en el ángulo es para que el cero quede arriba en vez de a la derecha, que es como funciona la trigonometría por defecto.

**3. Barra recta.** Si el estilo del juego lo permite, una barra horizontal de progreso es más legible que cualquier arco y cuesta dos instancias. No la descartes por parecer menos vistosa.

## El número: los tres detalles que importan

**Ancho fijo.** Si el contenedor se ajusta al contenido, todo el HUD se desplaza cuando el número pasa de 99 a 100. Reserva el ancho del valor máximo:

```lua
valor.Size = UDim2.new(0, 90, 0, 44)  -- espacio para "999"
valor.TextXAlignment = Enum.TextXAlignment.Center
```

**Sin decimales.** `120` se lee de reojo; `119.7` obliga a fijar la vista. `math.floor` siempre.

**Contorno.** El fondo es la carretera, el cielo o un túnel. Un `UIStroke` de 2 px del color de fondo del tema hace que el número se lea sobre cualquier cosa.

## Refresco: las dos guardas

```lua
local RunService = game:GetService("RunService")

local ultimoTick = 0
local ultimoValor = -1

RunService.RenderStepped:Connect(function()
    local ahora = os.clock()
    if ahora - ultimoTick < 0.05 then
        return
    end
    ultimoTick = ahora

    local velocidad = math.floor(obtenerVelocidad())
    if velocidad == ultimoValor then
        return
    end
    ultimoValor = velocidad

    valor.Text = tostring(velocidad)
    aguja.Rotation = anguloParaVelocidad(velocidad, VELOCIDAD_MAXIMA)
end)
```

La primera guarda limita a ~20 actualizaciones por segundo, indistinguible de 60 para un número. La segunda evita recalcular los límites del texto cuando el valor redondeado no cambió. Sin ellas, el velocímetro asigna `.Text` 60 veces por segundo durante toda la partida.

La aguja se puede animar con un tween muy corto (0.08 s) para que no salte de golpe, pero **no encadenes un tween por frame**: si el refresco es de 20/s y el tween dura 0.08 s, encaja justo.

## De dónde sale la velocidad

```lua
local function obtenerVelocidad()
    local personaje = jugador.Character
    local asiento = personaje and personaje:FindFirstChildOfClass("Humanoid")
    -- En vehiculo: la velocidad del ensamblaje del asiento
    if asiento and asiento.SeatPart then
        return asiento.SeatPart.AssemblyLinearVelocity.Magnitude * 3.6  -- studs/s a "km/h"
    end
    return 0
end
```

El factor de conversión es tu decisión de diseño, no una constante física: los studs no son metros. Elige un multiplicador que haga que las velocidades de tu juego se sientan creíbles y úsalo de forma consistente.

## Estados

- **Sin vehículo**: el velocímetro se oculta con transparencia animada, no con `Visible` de golpe. Un HUD que desaparece bruscamente parece un bug.
- **Velocidad máxima alcanzada**: el color del arco pasa al de advertencia. Sutil; no hace falta que parpadee.
- **Vehículo dañado o sin combustible**: el número en color de peligro, y el dato de la causa cerca.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Tamaño del conjunto | 180 px | 130 px |
| Número | 44 px | 34 px |
| Posición | esquina inferior derecha | centro-abajo, por encima de los controles |
| Marcha y datos extra | visibles | solo la marcha |

En móvil, súbelo lo suficiente para no chocar con el botón de salto, y no lo pongas en las esquinas inferiores.
