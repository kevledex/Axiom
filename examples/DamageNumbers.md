# Ejemplo: números de daño

**Petición típica:** "Que salgan los números de daño cuando golpeo a algo."

Este ejemplo existe porque introduce una superficie distinta: **`BillboardGui`**, que vive en el mundo 3D en lugar de en la pantalla. Y porque es el caso donde el rendimiento se rompe más rápido de toda la interfaz de un juego.

## Por qué es el caso más delicado

Un menú se abre una vez. Un número de daño puede aparecer **veinte veces por segundo** en un combate intenso. Si cada uno hace `Instance.new` y `Destroy`, el recolector de basura no da tregua y el juego da tirones justo en el momento de máxima acción.

La regla, sin excepciones: **lote reutilizable obligatorio**. Aquí no es una optimización, es un requisito.

## BillboardGui frente a ScreenGui

| | `ScreenGui` | `BillboardGui` |
|---|---|---|
| Vive en | la pantalla | el mundo 3D |
| Se mueve con | nada | el objeto al que está anclado |
| Escala con la distancia | no | sí (o no, con `AlwaysOnTop` y tamaño en offset) |
| Se oculta detrás de objetos | no | sí, salvo `AlwaysOnTop = true` |

Para números de daño quieres `BillboardGui`: el número tiene que salir **donde** está el enemigo, no en un rincón de la pantalla.

## Estructura

```
Workspace
└── DamageNumbers (Folder)          <- el lote vive aquí, no en el enemigo
    └── Number x MAX (BillboardGui, Enabled = false)
        └── Label (TextLabel + UIStroke)
```

Punto importante: el lote **no** se parentea a los enemigos. Vive en una carpeta propia y se mueve mediante `Adornee`. Así el mismo número sirve para cualquier objetivo y no se destruye cuando el enemigo muere.

## Configuración del BillboardGui

```lua
local numero = Instance.new("BillboardGui")
numero.Name = "Number"
numero.Size = UDim2.fromOffset(120, 50)
numero.AlwaysOnTop = true        -- que no lo tape una pared
numero.LightInfluence = 0        -- que no se oscurezca de noche
numero.MaxDistance = 120         -- deja de dibujarse de lejos
numero.Enabled = false
numero.Parent = carpeta

local etiqueta = Instance.new("TextLabel")
etiqueta.BackgroundTransparency = 1
etiqueta.Size = UDim2.fromScale(1, 1)
etiqueta.FontFace = Theme.fuente(Theme.Weights.Bold)
etiqueta.TextScaled = true
etiqueta.Parent = etiqueta.Parent or numero

local limite = Instance.new("UITextSizeConstraint")
limite.MaxTextSize = 36
limite.MinTextSize = 14
limite.Parent = etiqueta

local contorno = Instance.new("UIStroke")
contorno.Thickness = 2
contorno.Color = Color3.fromRGB(10, 10, 12)
contorno.Parent = etiqueta
```

Las cuatro propiedades que la gente olvida y que marcan la diferencia:

- **`AlwaysOnTop = true`** — sin esto, el número desaparece si hay algo delante del enemigo.
- **`LightInfluence = 0`** — sin esto, los números se oscurecen de noche o en interiores y dejan de leerse.
- **`MaxDistance`** — deja de dibujar los que están lejos. Rendimiento gratis.
- **`UIStroke`** — el fondo es el mundo entero. Sin contorno, un número blanco desaparece contra el cielo.

## El lote

```lua
local MAX_NUMEROS = 20
local libres = {}
local indiceRotatorio = 1
local lote = {}

-- Se crean todos al arrancar, una sola vez
for indice = 1, MAX_NUMEROS do
    lote[indice] = crearNumero()
end

local function obtener()
    -- Rotacion circular: si se agotan, se reutiliza el mas antiguo.
    -- Perder un numero de dano es mucho mejor que crear instancias en combate.
    local numero = lote[indiceRotatorio]
    indiceRotatorio = indiceRotatorio % MAX_NUMEROS + 1
    return numero
end
```

La rotación circular es una decisión de diseño consciente: con 20 números y un combate que genera 25 a la vez, los 5 más antiguos se reciclan a mitad de animación. El jugador no lo nota, y el rendimiento se mantiene constante sin importar cuánto daño haya en pantalla.

## Mostrar y animar

```lua
local TweenService = game:GetService("TweenService")

local function mostrar(cantidad, parte, esCritico)
    local numero = obtener()
    local etiqueta = numero.Label

    etiqueta.Text = (esCritico and "¡" or "") .. tostring(math.floor(cantidad)) .. (esCritico and "!" or "")
    etiqueta.TextColor3 = esCritico and Theme.Colors.Warning or Theme.Colors.TextPrimary
    etiqueta.TextTransparency = 0

    -- Dispersion horizontal para que dos golpes seguidos no se solapen
    local desvio = math.random(-25, 25) / 10
    numero.StudsOffsetWorldSpace = Vector3.new(desvio, 1.5, 0)
    numero.Adornee = parte
    numero.Enabled = true

    local subida = TweenService:Create(
        numero,
        TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { StudsOffsetWorldSpace = Vector3.new(desvio, 4.5, 0) }
    )

    local desvanecido = TweenService:Create(
        etiqueta,
        TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.4),
        { TextTransparency = 1 }
    )

    subida:Play()
    desvanecido:Play()

    desvanecido.Completed:Connect(function()
        numero.Enabled = false
        numero.Adornee = nil
    end)
end
```

Detalles del movimiento:

- **Sube y se desvanece.** 0.9 s de subida, con el desvanecido empezando a los 0.4 s (el `DelayTime` del `TweenInfo`). Aparece nítido y se va suave.
- **Dispersión horizontal aleatoria.** Sin ella, tres golpes rápidos apilan tres números en la misma línea vertical y no se lee ninguno.
- **`StudsOffsetWorldSpace`** en vez de `StudsOffset`: el primero es en coordenadas del mundo, así que el número sube en vertical real sin importar hacia dónde mire la cámara. Con `StudsOffset` el movimiento depende de la orientación de la cámara y queda raro.
- **`Adornee = nil` al terminar.** Si no lo sueltas, el `BillboardGui` mantiene una referencia al enemigo.

## Jerarquía visual del daño

El número tiene que comunicar magnitud sin que el jugador lo lea:

| Tipo | Tamaño | Color | Extra |
|---|---|---|---|
| Normal | 24 | texto primario | — |
| Crítico | 34 | advertencia | signos de exclamación, escala inicial 1.3 → 1 |
| Curación | 24 | éxito | signo `+` |
| Bloqueado / inmune | 20 | texto secundario | "Bloqueado" en vez de número |
| Daño recibido por el jugador | 28 | peligro | en pantalla, no en el mundo |

Ese último es una decisión importante: **el daño que recibe el jugador no va como número flotante en el mundo**, porque el jugador está mirando al enemigo, no a sí mismo. Va en el HUD, cerca de la barra de vida, o como viñeta en los bordes.

## Qué no hacer

- **Nada de `Instance.new` en el evento de daño.** Es la razón de existir de este documento.
- **No parentear el `BillboardGui` al enemigo.** Cuando el enemigo muera, el número se va con él a mitad de animación.
- **Sin sonido por número.** El impacto ya tiene su sonido; añadir uno por número es la metralleta de `sound-design.md`.
- **No acumular decimales.** `math.floor` siempre. `12.7 de daño` no aporta nada y ocupa más.
- **No mostrar cada tick de daño por veneno o quemadura.** Agrupa por segundo, o el jugador ve una cascada de 1s.

## Ajuste recomendado

Los números de daño son de lo primero que un jugador quiere apagar si el combate es muy denso. Un interruptor en los ajustes ("Mostrar números de daño") es barato de implementar y se agradece. Ver `examples/Settings.md`.
