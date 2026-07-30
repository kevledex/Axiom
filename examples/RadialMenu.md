# Ejemplo: menú radial

**Petición típica:** "Un menú circular tipo rueda para elegir cosas rápido."

Es un panel, pero uno muy particular: se abre y se cierra en menos de un segundo, sin sacar al jugador del juego. Emotes, armas, herramientas, acciones de vehículo.

## Cuándo tiene sentido y cuándo no

**Sí:** entre 4 y 8 opciones fijas, que el jugador va a memorizar por posición, y que necesita elegir rápido sin dejar de jugar.

**No:** más de 8 opciones (los sectores se vuelven finos y se falla al seleccionar), opciones que cambian de orden (se pierde la memoria muscular, que es toda la ventaja del formato), o listas que hay que leer para elegir. Para eso, una lista normal es mejor y más honesta.

Ocho es el máximo real. Seis es el punto dulce.

## Estructura

```
RadialMenuUI (ScreenGui)
└── Overlay (TextButton, pantalla completa, fondo oscuro 0.4)
    └── Wheel (Frame cuadrado, centrado, UIAspectRatioConstraint = 1)
        ├── Slice x N (ImageButton o Frame, colocados por trigonometría)
        │   ├── Icon
        │   └── Label (solo el de la opción activa)
        ├── CenterHub (Frame circular)
        │   └── ActiveLabel (nombre de la opción apuntada)
        └── DeadZone (zona central = cancelar)
```

El `Overlay` como `TextButton` a pantalla completa captura el clic y sirve para cerrar tocando fuera.

## Colocación de los sectores

```lua
local RADIO = 110

local function colocar(indice, total, elemento)
    -- Se empieza arriba y se reparte en sentido horario
    local angulo = math.rad((indice - 1) / total * 360 - 90)

    elemento.AnchorPoint = Vector2.new(0.5, 0.5)
    elemento.Position = UDim2.new(
        0.5, math.cos(angulo) * RADIO,
        0.5, math.sin(angulo) * RADIO
    )
end
```

El `-90` pone la primera opción arriba en lugar de a la derecha. Si tu diseño empieza arriba, la memoria muscular del jugador funciona mejor: "arriba es saludar, abajo es bocina".

## Selección por ángulo, no por colisión

Aquí está la diferencia entre un menú radial que se siente bien y uno frustrante. **No** dependas de que el cursor toque el sector: calcula el ángulo desde el centro y decide.

```lua
local function sectorApuntado(posicionPantalla)
    local centro = rueda.AbsolutePosition + rueda.AbsoluteSize / 2
    local delta = posicionPantalla - centro

    -- Zona muerta central: cancelar
    if delta.Magnitude < 40 then
        return nil
    end

    local angulo = math.deg(math.atan2(delta.Y, delta.X)) + 90
    if angulo < 0 then
        angulo = angulo + 360
    end

    local sector = math.floor(angulo / (360 / TOTAL_OPCIONES)) + 1
    return math.clamp(sector, 1, TOTAL_OPCIONES)
end
```

Ventaja enorme: el jugador puede empujar el cursor o el dedo **más allá** del sector y sigue funcionando. No hace falta precisión, solo dirección. Es exactamente cómo funcionan las ruedas de los juegos que se sienten bien.

La **zona muerta central** es lo que permite cancelar sin pensar: suelta en el centro y no pasa nada.

## Feedback

Solo la opción apuntada cambia, y de forma inequívoca:

- Escala 1.12 (más generosa que en un botón normal: aquí el jugador no está mirando con precisión).
- Fondo del sector al color de acento.
- Su nombre aparece en el `CenterHub`. Este detalle importa: es lo que permite tener solo iconos en los sectores y aun así saber qué es cada cosa.
- Sonido `Hover` al cambiar de sector, con throttle. Sin throttle, girar el ratón alrededor de la rueda dispara una ráfaga (ver `sound-design.md`).

## Interacción por dispositivo

**PC** — se mantiene una tecla pulsada, se apunta con el ratón, se suelta para confirmar. Es lo más rápido y lo que espera un jugador de PC. Alternativa: clic para abrir, clic para elegir.

**Móvil** — no hay cursor. Se toca el botón para abrir la rueda, y luego:
- Toque directo en el sector, o
- Arrastre desde el centro y se suelta en la dirección (mejor, más rápido y más tolerante).

En móvil, sube el radio y el tamaño de los sectores: el dedo tapa el sector que está tocando, así que el nombre en el `CenterHub` pasa de ser un extra a ser imprescindible.

**Mando** — el stick derecho apunta y el gatillo confirma. Es el dispositivo para el que este formato se inventó:

```lua
local direccion = Vector2.new(entrada.Position.X, -entrada.Position.Y)
if direccion.Magnitude > 0.4 then   -- zona muerta del stick
    local angulo = math.deg(math.atan2(direccion.Y, direccion.X))
    -- misma conversion a sector
end
```

## Apertura y cierre

La animación de un menú radial tiene que ser **muy** rápida: 0.15 s como máximo. El jugador lo abre para hacer algo ya, no para admirarlo.

```lua
local function abrir()
    overlay.Visible = true
    escalaRueda.Scale = 0.85
    animar(overlay, 0.12, { BackgroundTransparency = 0.5 })
    animar(escalaRueda, 0.15, { Scale = 1 }, Enum.EasingStyle.Back)
end
```

Los sectores pueden aparecer en cascada, pero con retardos mínimos (0.015 s por sector). Con 0.05 s por sector, seis sectores tardan 0.3 s y ya se siente lento.

**Al cerrar, más rápido todavía**: 0.1 s. Y la acción se ejecuta al instante, sin esperar a que la animación termine.

## Ralentización del juego

Muchos juegos ralentizan el tiempo mientras la rueda está abierta. En Roblox no puedes cambiar la velocidad global del juego con facilidad, pero sí puedes:

- Reducir la sensibilidad de la cámara mientras está abierta.
- Bloquear el movimiento del personaje si el menú es de una acción crítica.

Valóralo con cuidado: bloquear el movimiento en un juego de acción puede matar al jugador y eso se percibe como culpa de la interfaz.

## Estados

- **Opción bloqueada**: icono atenuado con candado. Apuntarla no la resalta con el color de acento, y suena `Locked` en lugar de `Hover`.
- **Opción en enfriamiento**: un arco de progreso alrededor del sector, o simplemente el icono atenuado con los segundos restantes.
- **Sin opciones disponibles**: no abras la rueda vacía. Un toast con el motivo es mejor que un círculo vacío.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Radio | 110 px | 130 px (el dedo necesita más) |
| Tamaño de sector | 64 px | 76 px |
| Etiquetas en sectores | opcionales | nunca, solo el hub central |
| Apertura | tecla mantenida | botón + arrastre |

Es uno de los pocos casos donde la versión móvil es **más grande** que la de PC, no más pequeña. El dedo necesita más superficie y tapa lo que toca.
