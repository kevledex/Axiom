# Ejemplo: notificaciones

**Petición típica:** "Un sistema de notificaciones para avisar de cosas al jugador."

HUD contextual: aparece, se lee y se va sola. Lee `references/hud-vs-menu.md`.

## El problema real

Las notificaciones son fáciles de hacer y fáciles de convertir en spam. Los tres fallos que las arruinan:

1. **No hay cola.** Cinco eventos a la vez producen cinco avisos apilados que tapan media pantalla.
2. **Se crean y destruyen por evento.** En un juego con eventos frecuentes, eso es `Instance.new` constante.
3. **Duran demasiado o demasiado poco.** Cinco segundos es una eternidad; un segundo no da tiempo a leer.

Todo el diseño gira alrededor de resolver eso.

## Estructura

```
NotificationUI (ScreenGui)
└── Stack (Frame, Active = false)
    ├── UIListLayout (vertical, VerticalAlignment según posición)
    └── Toast x MAX_VISIBLES (creados una vez, ocultos)
        ├── Icon (ImageLabel)
        ├── TextBlock (Title + Message)
        ├── AccentBar (Frame de 3 px, color según tipo)
        └── UIScale
```

`MAX_VISIBLES` = 3. Más de tres a la vez y el jugador no lee ninguna.

## Tipos

Cuatro, y cada uno con su color y su duración:

| Tipo | Color | Duración | Ejemplo |
|---|---|---|---|
| `Info` | acento | 3 s | "Ruta desbloqueada" |
| `Success` | éxito | 3 s | "Autobús comprado" |
| `Warning` | advertencia | 4 s | "Poco combustible" |
| `Error` | peligro | 5 s | "No tienes saldo suficiente" |

Los errores duran más porque suelen requerir una decisión. El color va en la barra de acento y en el icono, **no** en el fondo del toast: un rectángulo entero en rojo es agresivo y rompe la coherencia visual del HUD.

## La cola con lote reutilizable

```lua
local MAX_VISIBLES = 3
local cola = {}
local libres = {}     -- toasts disponibles
local activos = {}    -- toasts en pantalla

local function mostrar(toast, datos)
    toast.Title.Text = datos.Titulo
    toast.Message.Text = datos.Mensaje or ""
    toast.AccentBar.BackgroundColor3 = COLORES[datos.Tipo] or Theme.Colors.Primary
    toast.Icon.Image = Icons.obtener(ICONOS[datos.Tipo]) 
    toast.LayoutOrder = os.clock() * 1000   -- las nuevas van al final

    toast.Visible = true
    local escala = toast:FindFirstChildOfClass("UIScale")
    escala.Scale = 0.9
    toast.BackgroundTransparency = 1

    animar(toast, Theme.Animation.Normal, { BackgroundTransparency = 0.1 })
    animar(escala, Theme.Animation.Normal, { Scale = 1 }, Enum.EasingStyle.Back)

    table.insert(activos, toast)

    task.delay(datos.Duracion or 3, function()
        ocultar(toast)
    end)
end

local function ocultar(toast)
    local escala = toast:FindFirstChildOfClass("UIScale")
    animar(escala, Theme.Animation.Fast, { Scale = 0.95 })
    local tween = animar(toast, Theme.Animation.Fast, { BackgroundTransparency = 1 })

    tween.Completed:Connect(function()
        toast.Visible = false

        for indice, activo in ipairs(activos) do
            if activo == toast then
                table.remove(activos, indice)
                break
            end
        end
        table.insert(libres, toast)

        -- Si habia algo esperando, entra ahora
        local siguiente = table.remove(cola, 1)
        if siguiente then
            notificar(siguiente)
        end
    end)
end

function notificar(datos)
    if #activos >= MAX_VISIBLES then
        table.insert(cola, datos)
        return
    end

    local toast = table.remove(libres)
    if not toast then
        return   -- no deberia pasar, pero nunca crees uno nuevo aqui
    end
    mostrar(toast, datos)
end
```

Lo importante de este patrón: **el lote es fijo**. Si llegan veinte notificaciones, tres se muestran, diecisiete esperan, y no se crea una sola instancia nueva. Ver `performance.md`.

## Agrupar repeticiones

Si el mismo aviso llega varias veces seguidas ("+10 monedas" cinco veces), no muestres cinco toasts: actualiza el que ya está visible con un contador.

```lua
local function buscarSimilar(titulo)
    for _, toast in ipairs(activos) do
        if toast.Title.Text == titulo or toast:GetAttribute("Base") == titulo then
            return toast
        end
    end
    return nil
end
```

Y en el toast, un badge con `x5`. Es la diferencia entre un sistema que informa y uno que abruma.

## Posición

- **Arriba centro** — máxima visibilidad. Para avisos importantes. Ojo: es donde mira el jugador, así que interrumpe.
- **Arriba derecha** — el estándar. Visible sin tapar la acción.
- **Abajo centro** — bueno en móvil, pero cuidado con los controles.

En móvil, arriba derecha choca con el chat y la lista de jugadores. Arriba centro, ligeramente por debajo del inset, suele funcionar mejor.

## Sonido

Uno solo, y solo para `Warning` y `Error`. Las notificaciones de información y éxito llegan a menudo, y un sonido por cada una es exactamente el tipo de spam que describe `sound-design.md`. Si agrupas repeticiones, el sonido suena una vez por grupo, no una por evento.

## Interacción

- **Se pueden descartar tocándolas.** Un toast que no se puede quitar es frustrante cuando tapa algo.
- **Si es táctil, el área de toque completa**, no una X de 20 px.
- Si una notificación lleva a algún sitio ("Nuevo objeto — Ver"), el toast entero es el botón y la duración sube a 5 s.
- Nada crítico va solo en un toast. Si el jugador tiene que enterarse, va en un modal o en un estado persistente de la UI: un aviso que se va solo se puede perder.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Ancho del toast | 320 px | 90 % del ancho de pantalla |
| Máximo visible | 3 | 2 |
| Mensaje secundario | visible | solo el título |
| Alto | 64 px | 56 px, sin descripción |

En compacto, dos toasts ya ocupan una parte considerable de la pantalla. Y el mensaje largo se corta: solo el título, que debe funcionar por sí solo. Si un aviso necesita dos líneas para entenderse, probablemente no es un toast.
