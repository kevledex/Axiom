# Overlays a pantalla completa

Leer siempre que la interfaz cubra toda la pantalla: pantallas de carga, transiciones, modales que oscurecen el fondo, cinemáticas, pantallas de resultados.

Un overlay no es un panel grande. Tiene tres problemas propios que ninguna otra interfaz tiene, y los tres se descubren tarde si no se previenen desde la instalación.

Contenido:
1. Nace apagado
2. Ocultarse siempre implica fade
3. Crossfade de dos capas
4. Precarga y diagnóstico honesto
5. Bloqueo de interacción y de la interfaz de Roblox
6. Progreso real frente a progreso simulado
7. Checklist

---

## 1. Nace apagado

Un `ScreenGui` con `Enabled = true` dentro de `StarterGui` **se previsualiza en vivo en el viewport de edición de Studio**. Con un panel pequeño es una molestia; con un overlay a pantalla completa tapa el mundo entero y deja el proyecto imposible de editar hasta que alguien descubre por qué todo está negro.

Regla, sin excepciones: **todo overlay a pantalla completa se instala con `Enabled = false`** y lo enciende el script en tiempo de ejecución.

```lua
-- En el instalador
local pantalla = crear("ScreenGui", {
    Name = "LoadingScreenUI",
    -- Apagado a proposito: con true, Studio lo previsualiza en el viewport
    -- de edicion y tapa todo el mundo mientras se trabaja en el juego.
    Enabled = false,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 100,
}, destino)
```

```lua
-- En el LocalScript, en tiempo de ejecucion
pantalla.Enabled = true
```

Si el instalador deja un overlay encendido, el usuario lo va a descubrir de la peor manera posible. Cuando generes uno, dilo explícitamente en la entrega: "se instala apagado a propósito; lo enciende `Controllers/LoadingController` al entrar al juego".

## 2. Ocultarse siempre implica fade

`Enabled = false` corta la imagen de golpe. En una interfaz donde todo lo demás tiene transiciones suaves, ese corte se siente como un fallo — sobre todo al final de una pantalla de carga, que es justo el momento en que el jugador está juzgando la calidad del juego.

La solución no es "acordarse de animar el cierre": es **construir el contenedor como `CanvasGroup` desde el principio**, para que ocultar implique fade por defecto y no sea algo que haya que pedir aparte.

```lua
local raiz = crear("CanvasGroup", {
    Name = "Root",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    GroupTransparency = 0,
}, pantalla)
```

```lua
local function ocultar()
    local tween = TweenService:Create(
        raiz,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { GroupTransparency = 1 }
    )
    tween:Play()
    tween.Completed:Wait()
    pantalla.Enabled = false
end
```

`GroupTransparency` desvanece todo el subárbol con una sola propiedad: fondo, textos, imágenes y barras a la vez. Sin `CanvasGroup` habría que animar la transparencia de cada elemento por separado, que es tedioso y siempre se olvida alguno.

## 3. Crossfade de dos capas

El patrón para rotar imágenes de fondo: dos `ImageLabel` que alternan, uno visible y otro preparando la siguiente imagen.

El fallo que produce parpadeos negros intermitentes y cuesta horas de depuración: **darle fondo opaco propio a cada una de las dos capas**. Como una de las dos siempre queda encima en el orden de dibujado, esa capa tapa a su pareja con su propio fondo justo cuando debería estar transparente. El síntoma parece un asset roto o una imagen que no carga, y no lo es.

Regla: **ninguna de las dos capas del par lleva fondo opaco.** Si hace falta un respaldo sólido, va **una sola vez, detrás de las dos**.

```lua
-- Respaldo unico y estatico detras del par
local respaldo = crear("Frame", {
    Name = "RespaldoFondo",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    ZIndex = 1,
}, raiz)

-- Las dos capas que alternan: SIN fondo propio
for indice = 1, 2 do
    crear("ImageLabel", {
        Name = "Fondo" .. indice,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,   -- obligatorio
        ImageTransparency = indice == 1 and 0 or 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 2,
    }, raiz)
end
```

El crossfade anima **solo `ImageTransparency`**, nunca el fondo:

```lua
local function cambiarA(imagen)
    local entrante = activo == fondo1 and fondo2 or fondo1
    entrante.Image = imagen
    entrante.ImageTransparency = 1

    animar(entrante, 0.45, { ImageTransparency = 0 })
    animar(activo, 0.45, { ImageTransparency = 1 })

    activo = entrante
end
```

Detalle que agrava el problema: si el número de imágenes es **impar** y los buffers son dos, la alternancia no cae siempre en la misma capa, así que el parpadeo aparece de forma inconsistente y parece aleatorio. No lo es: es el fondo opaco de la capa que toca estar arriba.

## 4. Precarga y diagnóstico honesto

`ContentProvider:PreloadAsync` acepta una lista, pero **el diagnóstico de estado no es fiable si le pasas IDs como texto suelto**: el motor no puede verificar bien el estado de un `rbxassetid://` que no está asociado a ninguna instancia, y devuelve fallos en assets que en realidad cargan perfectamente.

Para precargar sin más, la lista de strings sirve. Para **saber qué falló de verdad**, envuelve cada ID en una instancia real:

```lua
local ContentProvider = game:GetService("ContentProvider")

local function precargarConDiagnostico(ids)
    local temporales = {}
    local contenedor = Instance.new("Folder")
    contenedor.Parent = pantalla

    for _, id in ipairs(ids) do
        local sonda = Instance.new("ImageLabel")
        sonda.Image = id
        sonda.Visible = false
        sonda.Parent = contenedor
        table.insert(temporales, sonda)
    end

    ContentProvider:PreloadAsync(temporales, function(recurso, estado)
        if estado ~= Enum.AssetFetchStatus.Success then
            warn("No se pudo cargar: " .. tostring(recurso))
        end
    end)

    contenedor:Destroy()
end
```

Sin esto, se pierde tiempo persiguiendo assets "rotos" que están bien. Un diagnóstico que miente es peor que no tener diagnóstico.

## 5. Bloqueo de interacción y de la interfaz de Roblox

Un overlay a pantalla completa tiene que capturar de verdad lo que hay debajo:

- El contenedor raíz con `Active = true` para consumir la entrada, o un `TextButton` invisible a pantalla completa. A diferencia de un HUD, aquí **sí** queremos bloquear.
- `DisplayOrder` alto (100 o más) para quedar por encima de cualquier otra interfaz del juego.
- Durante una pantalla de carga, conviene ocultar el chat y la lista de jugadores, y **volver a mostrarlos al terminar**:

```lua
local StarterGui = game:GetService("StarterGui")

local function alternarInterfazRoblox(visible)
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, visible)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, visible)
    end)
end
```

El `pcall` no es decorativo: estas llamadas fallan en algunos contextos y no deben tumbar la carga. Y lo importante es que la restauración esté en el mismo sitio que el cierre del overlay, para que sea imposible olvidarla.

## 6. Progreso real frente a progreso simulado

Dos opciones honestas, y una deshonesta:

- **Progreso real** — la barra refleja assets ya cargados sobre el total. Es lo correcto cuando se puede medir.
- **Indicador indeterminado** — un spinner que gira sin prometer un porcentaje. Es lo correcto cuando no se puede medir.
- **Progreso falso** — una barra que se llena en un tiempo fijo sin relación con nada. Miente al jugador y, peor, se queda al 99 % mientras el juego sigue cargando.

Un caso legítimo intermedio: **un mínimo de duración**. Si el juego carga en dos segundos pero quieres que la marca se vea, mantén el overlay hasta cumplir el mínimo con el progreso ya al 100 %, y alárgalo si la carga tarda más. Eso no es simular: el progreso sigue siendo real, solo se le pone un suelo de tiempo.

```lua
local MINIMO = 20

local inicio = os.clock()
esperarCargaReal()

local transcurrido = os.clock() - inicio
if transcurrido < MINIMO then
    task.wait(MINIMO - transcurrido)
end

ocultar()
```

## 7. Checklist

- [ ] El `ScreenGui` se instala con `Enabled = false`.
- [ ] El contenedor raíz es un `CanvasGroup` y el cierre anima `GroupTransparency`.
- [ ] Ninguna capa de un crossfade tiene fondo opaco propio; el respaldo sólido está una sola vez detrás.
- [ ] El crossfade anima `ImageTransparency`, nunca `BackgroundTransparency` de las capas.
- [ ] La precarga con diagnóstico usa instancias reales, no IDs sueltos.
- [ ] `DisplayOrder` alto y la entrada queda bloqueada.
- [ ] Lo que se oculte de la interfaz de Roblox se restaura al cerrar, en el mismo punto del código.
- [ ] El progreso es real o declaradamente indeterminado; nunca simulado.
