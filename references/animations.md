# Animaciones

Leer en la Fase 3. La animación no es decoración: es lo que hace que la interfaz se sienta viva y confirma al jugador que su acción fue registrada.

Contenido:
1. Duraciones y easing
2. Cómo usar TweenService
3. Patrones concretos
4. Feedback de entrada
5. Qué evitar

---

## 1. Duraciones y easing

Guarda las duraciones en `Theme.Animation` y no escribas números sueltos en el código.

| Uso | Duración |
|---|---|
| Hover, press, cambio de color | 0.10 – 0.15 s |
| Selección, cambio de pestaña | 0.20 s |
| Abrir o cerrar panel / modal | 0.25 – 0.30 s |
| Transición de pantalla completa | 0.35 – 0.45 s |

Nada de UI debería tardar más de medio segundo. Una animación de un segundo se siente como lag, no como elegancia.

Easing, con criterio:

- `Quad` / `Quart` con `Out` — el caballo de batalla. Arranca rápido y frena suave: se siente responsivo.
- `Back` con `Out` — un rebote muy leve al aparecer. Úsalo en modales y tarjetas, con moderación.
- `Sine` — transiciones sutiles y continuas.
- `Linear` — solo para barras de progreso y contadores.
- Evita `Elastic` y `Bounce` salvo en juegos deliberadamente caricaturescos; en una UI seria parecen un error.

Regla de dirección: lo que **aparece** usa `Out` (entra rápido, se asienta). Lo que **desaparece** usa `In` (arranca suave, se va rápido). Cerrar debe sentirse más rápido que abrir.

## 2. Cómo usar TweenService

```lua
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Configuration.Theme)

local function animar(objeto, duracion, propiedades, estilo, direccion)
    local info = TweenInfo.new(
        duracion,
        estilo or Enum.EasingStyle.Quad,
        direccion or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(objeto, info, propiedades)
    tween:Play()
    return tween
end
```

Con ese único helper cubres el 95 % de los casos. Detalles importantes:

- Un tween nuevo sobre la misma propiedad **cancela** el anterior automáticamente, así que no hace falta llevar control manual en hover/unhover.
- Si necesitas esperar el final: `tween.Completed:Wait()` o `tween.Completed:Connect(...)`. Para secuencias, mejor encadenar con `Completed` que usar `task.wait` con números que luego no cuadran.
- `TweenService` no puede animar propiedades que no sean numéricas ni `Color3`/`UDim2`/`Vector2`. `Visible` no se anima: se anima la transparencia y se apaga `Visible` al terminar.
- Anima `UIScale.Scale` en vez de `Size` cuando quieras un efecto de escala: es una sola propiedad y no rompe el layout de los hermanos.

## 3. Patrones concretos

**Abrir un panel**
```lua
local function abrirPanel(panel, escala)
    panel.Visible = true
    escala.Scale = 0.94
    animar(panel, Theme.Animation.Normal, { BackgroundTransparency = 0 })
    animar(escala, Theme.Animation.Normal, { Scale = 1 }, Enum.EasingStyle.Back)
end
```
Escala desde 0.94 (no desde 0: eso se siente como un pop de móvil barato) más un desvanecido. Si el panel está dentro de un `CanvasGroup`, anima `GroupTransparency` de 1 a 0 y desvaneces todo el conjunto con una sola propiedad.

**Cerrar un panel**
```lua
local function cerrarPanel(panel, escala)
    animar(escala, Theme.Animation.Fast, { Scale = 0.96 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = animar(panel, Theme.Animation.Fast, { BackgroundTransparency = 1 })
    tween.Completed:Connect(function()
        panel.Visible = false
    end)
end
```

**Hover de botón**
```lua
boton.MouseEnter:Connect(function()
    animar(boton, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.PrimaryHover })
    animar(escala, Theme.Animation.Fast, { Scale = 1.03 })
end)

boton.MouseLeave:Connect(function()
    animar(boton, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.Primary })
    animar(escala, Theme.Animation.Fast, { Scale = 1 })
end)
```

**Press**
```lua
boton.MouseButton1Down:Connect(function()
    animar(escala, 0.08, { Scale = 0.97 })
end)

boton.MouseButton1Up:Connect(function()
    animar(escala, 0.12, { Scale = 1 }, Enum.EasingStyle.Back)
end)
```
El press que hunde ligeramente el botón y vuelve con un micro-rebote es la diferencia entre "clic registrado" y "no sé si funcionó".

**Indicador de pestaña deslizante**
```lua
local function moverIndicador(indicador, boton)
    animar(indicador, Theme.Animation.Normal, {
        Position = UDim2.new(0, boton.AbsolutePosition.X - indicador.Parent.AbsolutePosition.X, 1, -2),
        Size = UDim2.new(0, boton.AbsoluteSize.X, 0, 2)
    })
end
```

**Entrada en cascada de una lista**
```lua
for indice, tarjeta in ipairs(tarjetas) do
    tarjeta.BackgroundTransparency = 1
    task.delay(indice * 0.03, function()
        animar(tarjeta, Theme.Animation.Normal, { BackgroundTransparency = 0 })
    end)
end
```
Retardo de 0.03 s por elemento, con tope: más de 10–12 elementos en cascada y el último tarda demasiado. Para listas largas, anima solo lo visible.

**Barra de progreso**
```lua
animar(relleno, 0.4, { Size = UDim2.fromScale(porcentaje, 1) }, Enum.EasingStyle.Quad)
```

## 4. Feedback de entrada

Cada acción del jugador necesita una respuesta perceptible en menos de 150 ms. Formas de darla, de menor a mayor intensidad:

1. Cambio de color o de transparencia.
2. Escala (`UIScale`).
3. Desplazamiento pequeño (2–4 px).
4. Sonido corto y de volumen bajo. El detalle está en `sound-design.md`; lo esencial es que va acompañando al cambio visual, nunca solo.
5. Aparición de un elemento (check, badge, toast).

En móvil no hay hover, así que el estado **presionado** carga con todo el peso del feedback. Usa `InputBegan` / `InputEnded` en el botón para cubrir ratón y toque con el mismo código:

```lua
boton.InputBegan:Connect(function(entrada)
    if entrada.UserInputType == Enum.UserInputType.MouseButton1
        or entrada.UserInputType == Enum.UserInputType.Touch then
        -- estado presionado
    end
end)
```

## 5. Qué evitar

- Animaciones de más de 0.5 s en interacciones normales.
- `Elastic` y `Bounce` exagerados: parecen un bug físico.
- Animar `Position` de elementos gestionados por un `UIListLayout`: el layout los devuelve a su sitio y produce parpadeo. Anima transparencia, escala o el `LayoutOrder` con reordenación instantánea.
- Movimiento constante en pantalla: iconos que laten sin motivo, bordes que pulsan, gradientes girando. Cansa y roba atención al contenido.
- Animar decenas de elementos a la vez en móvil: los dispositivos de gama baja lo notan.
- Bloquear la interacción durante la animación de cierre. Si el jugador vuelve a pulsar mientras se cierra, debe funcionar.
