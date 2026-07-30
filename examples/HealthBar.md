# Ejemplo: barra de vida

**Petición típica:** "Una barra de vida que no se vea genérica."

HUD, no menú. Lee `references/hud-vs-menu.md`.

## Lo que separa una barra de vida buena de una mala

Una barra mala te dice cuánta vida tienes. Una buena te dice además **cuánta acabas de perder y con qué urgencia**. Toda la diferencia está en el feedback del cambio, no en el aspecto en reposo.

## Estructura

```
HealthUI (ScreenGui)
└── Root (Frame, Active = false)
    └── Bar (Frame, fondo oscuro)
        ├── Ghost (Frame, color de peligro atenuado)   <- daño reciente
        ├── Fill (Frame, color principal)              <- vida actual
        ├── Divisions (Frame x N, marcas cada 25 %)    <- opcional
        └── Value (TextLabel, "84/100")                <- opcional
```

El orden importa: `Ghost` debajo de `Fill`, ambos anclados a la izquierda.

## La barra fantasma

Es el detalle que más sube la percepción de calidad y cuesta veinte líneas. Cuando el jugador recibe daño, `Fill` baja al instante y `Ghost` se queda donde estaba, para bajar medio segundo después. El jugador **ve** el mordisco.

```lua
local function aplicarVida(actual, maxima)
    local proporcion = math.clamp(actual / maxima, 0, 1)

    -- La vida real baja de inmediato: la informacion no se hace esperar
    relleno.Size = UDim2.fromScale(proporcion, 1)

    if proporcion < proporcionAnterior then
        -- Dano: el fantasma se retrasa para que se vea cuanto se perdio
        task.delay(0.25, function()
            animar(fantasma, 0.35, { Size = UDim2.fromScale(proporcion, 1) })
        end)
    else
        -- Curacion: el fantasma acompana sin retraso
        animar(fantasma, 0.2, { Size = UDim2.fromScale(proporcion, 1) })
    end

    proporcionAnterior = proporcion
end
```

Asimetría deliberada: el daño se anuncia, la curación no necesita drama.

## Color por umbral, no gradiente continuo

Un gradiente de verde a rojo suena bien y funciona mal: el jugador no distingue el matiz en la periferia de la visión. Umbrales discretos sí se notan:

```lua
local function colorParaVida(proporcion)
    if proporcion > 0.5 then
        return Theme.Colors.Success
    elseif proporcion > 0.25 then
        return Theme.Colors.Warning
    end
    return Theme.Colors.Danger
end
```

Anima el cambio de color con un tween corto para que el salto de umbral no sea brusco.

Y no dependas solo del color: los jugadores con daltonismo necesitan otra señal. La proporción de la barra ya la da, pero por debajo del 25 % conviene añadir algo más (pulso lento, borde, el número).

## Estado crítico

Por debajo del 25 %, el HUD tiene permiso para llamar la atención — es la excepción a la regla de "nada que parpadee":

- Pulso lento del borde de la barra (1–1.5 s por ciclo, no 0.2).
- Opcionalmente, una viñeta roja tenue en los bordes de la pantalla. Muy tenue: transparencia 0.85 como punto de partida.
- **Nunca** un parpadeo rápido a pantalla completa. Además de molesto, puede provocar molestias reales.

Y por encima del 25 %, el pulso se apaga. Un HUD que late siempre pierde todo su valor de aviso.

## Divisiones

Marcas cada 25 % (o cada 20 puntos de vida) convierten la barra en algo cuantificable: el jugador sabe "me quedan tres cuartos" sin leer un número. Son `Frame` de 2 px de ancho, transparencia 0.6, posicionados con escala. Cinco instancias que aportan mucho.

## El número, ¿sí o no?

Depende del juego. En un shooter competitivo, sí: la información exacta importa. En un juego casual, la barra sola es menos ruido. Si lo pones:

- Ancho fijo, para que no baile.
- `UIStroke` para que se lea sobre cualquier fondo.
- Formato `84` o `84/100`, no `84.0` ni `84%` (el porcentaje es redundante con la barra).

## Conexión con el Humanoid

```lua
local humanoide = personaje:WaitForChild("Humanoid")

local function refrescar()
    aplicarVida(humanoide.Health, humanoide.MaxHealth)
end

humanoide.HealthChanged:Connect(refrescar)
humanoide:GetPropertyChangedSignal("MaxHealth"):Connect(refrescar)
refrescar()
```

Por eventos, no en un bucle. `HealthChanged` se dispara exactamente cuando hace falta, así que aquí no hace falta ningún throttle — es un caso distinto al del velocímetro, donde el valor cambia continuamente.

Ojo con la reaparición: el `Humanoid` es nuevo cada vez que el jugador muere. Escucha `Player.CharacterAdded` y vuelve a conectar, o la barra dejará de funcionar tras la primera muerte. Es uno de los fallos más habituales.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Ancho | 280 px | 45 % del ancho de pantalla |
| Alto | 18 px | 22 px (más visible de reojo) |
| Número | visible | solo si es un juego competitivo |
| Posición | inferior izquierda | arriba, centrado o a la izquierda |

En móvil, arriba suele ser mejor que abajo: la franja inferior está ocupada por el joystick y el botón de salto, y el pulgar puede tapar la barra justo cuando más importa.

## Variantes

- **Barra de escudo** encima de la de vida, con su propio color. Se vacía primero.
- **Segmentada por corazones o bloques** para juegos con vida discreta. Cada bloque es una instancia; con más de 10 conviene reutilizarlas (ver `performance.md`).
- **Barra de jefe** en la parte superior central, más larga y con nombre. Es un HUD contextual: aparece y desaparece con el combate.
