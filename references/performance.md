# Rendimiento

Leer en la Fase 2 (al decidir la arquitectura de cualquier lista) y en la Fase 3.

Una interfaz que va perfecta en el PC del desarrollador puede provocar tirones en un teléfono de gama baja, que es donde juega buena parte del público de Roblox. El coste no está en lo bonito que sea el diseño: está en cuántas instancias hay vivas, cuántas veces se recalcula el layout y cada cuánto se toca una propiedad.

Contenido:
1. De dónde sale el coste
2. Pooling: reutilizar en vez de crear y destruir
3. Virtualización para listas largas
4. Presupuesto de instancias
5. Recálculo de layout
6. Actualizaciones por frame
7. Conexiones y fugas de memoria
8. Imágenes
9. Efectos con coste alto
10. Cómo medirlo

---

## 1. De dónde sale el coste

Tres fuentes, en orden de impacto:

1. **Crear y destruir instancias.** `Instance.new` no es gratis, y `Destroy` deja trabajo al recolector de basura. Hacerlo en bucle, en respuesta a cada búsqueda o cada scroll, es lo que produce los tirones más visibles.
2. **Recalcular el layout.** Cada cambio de tamaño, posición o padding en un objeto dentro de un `UIListLayout` o `UIGridLayout` obliga a recalcular la posición de todos sus hermanos.
3. **Renderizar.** Cada `GuiObject` visible es trabajo de dibujado en cada frame. Transparencias apiladas, `ClipsDescendants` anidados y `CanvasGroup` grandes lo encarecen.

Lo que **no** cuesta significativamente: tener muchas instancias con `Visible = false`, usar colores del tema, tener un `Theme` centralizado.

## 2. Pooling: reutilizar en vez de crear y destruir

El patrón más importante de este documento. En lugar de crear una tarjeta por cada dato y destruirla al filtrar, se crea un lote fijo una sola vez y se rellena.

```lua
-- Mal: crea y destruye en cada refresco
local function renderizar(datos)
    contenedor:ClearAllChildren()          -- destruye todo
    for _, fila in ipairs(datos) do
        local tarjeta = Instance.new("Frame")  -- crea de nuevo
        -- ...
        tarjeta.Parent = contenedor
    end
end
```

```lua
-- Bien: el lote existe desde el principio y solo se rellena
local function renderizar(datos)
    for indice, tarjeta in ipairs(lote) do
        local fila = datos[indice]
        if fila then
            tarjeta.Nombre.Text = fila.Nombre
            tarjeta.Visible = true
        else
            tarjeta.Visible = false
        end
    end
end
```

Ventajas más allá del rendimiento: los eventos se conectan una sola vez (ver sección 7), las instancias quedan visibles y editables en el Explorer de Studio, y el filtrado es instantáneo porque no hay construcción de por medio.

Cuando el número de datos es realmente variable y grande, un pool con reserva dinámica:

```lua
local function crearPool(fabricar, contenedor)
    local libres = {}
    local usados = {}
    local pool = {}

    function pool.obtener()
        local elemento = table.remove(libres) or fabricar(contenedor)
        elemento.Visible = true
        table.insert(usados, elemento)
        return elemento
    end

    function pool.liberarTodos()
        for _, elemento in ipairs(usados) do
            elemento.Visible = false
            table.insert(libres, elemento)
        end
        usados = {}
    end

    return pool
end
```

Crece hasta el máximo que haya necesitado y a partir de ahí no vuelve a crear nada.

## 3. Virtualización para listas largas

Si la lista puede tener cientos de elementos (un catálogo completo, un leaderboard global, un historial), no basta el pooling: hay que renderizar solo lo que se ve.

La idea: el lote tiene el tamaño de lo visible más un margen de dos o tres filas, y al hacer scroll se reasigna qué dato le toca a cada tarjeta.

```lua
local ALTO_FILA = 96 + 12  -- alto de celda + separacion

local function actualizarVentana()
    local desplazamiento = scroll.CanvasPosition.Y
    local primera = math.max(1, math.floor(desplazamiento / ALTO_FILA) - 2)

    for indice, tarjeta in ipairs(lote) do
        local fila = datos[primera + indice - 1]
        if fila then
            tarjeta.Nombre.Text = fila.Nombre
            tarjeta.Position = UDim2.new(0, 0, 0, (primera + indice - 2) * ALTO_FILA)
            tarjeta.Visible = true
        else
            tarjeta.Visible = false
        end
    end
end

scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(actualizarVentana)
```

Con virtualización se posiciona a mano, así que **no** se usa `UIListLayout` ni `UIGridLayout` en ese contenedor: el layout automático y el posicionamiento manual se pelean. Es la única excepción a la regla general de no calcular posiciones.

`CanvasSize` sí se fija a mano aquí: `UDim2.new(0, 0, 0, #datos * ALTO_FILA)`.

Umbral práctico: por debajo de unas 40 filas, el pooling simple sobra. Por encima, merece la pena virtualizar.

## 4. Presupuesto de instancias

Guía orientativa, no una ley: una interfaz de menú completa debería moverse por debajo de unos **300 objetos GUI vivos**, y un HUD permanente en pantalla bastante por debajo de eso, porque compite con el renderizado del juego.

Cómo se dispara el número sin darse cuenta: una tarjeta con `UICorner`, `UIStroke`, `UIPadding`, `UIScale`, `UIListLayout`, icono, título, subtítulo y badge son 9 instancias. Sesenta tarjetas son 540. Ahí es donde un inventario "sencillo" se vuelve pesado.

Cómo bajarlo:

- Quitar lo decorativo que no aporta jerarquía. Un `UIStroke` en cada tarjeta de una lista de 60 se puede sustituir por un color de fondo ligeramente distinto.
- No poner `UIPadding` en elementos que ya están posicionados por el layout del padre con separación suficiente.
- Un solo `UIScale` en la tarjeta, no uno por hijo.

## 5. Recálculo de layout

- Asigna `Parent` **al final**, después de todas las propiedades. Cada asignación con el objeto ya en el árbol dispara recálculo. Por eso el helper `crear(clase, propiedades, padre)` existe.
- Nunca uses `Instance.new("Frame", padre)`: hace justo lo contrario.
- Si tienes que actualizar muchas propiedades de un subárbol, considera `Visible = false` en el contenedor mientras lo haces, y `true` al final.
- `AutomaticSize` es cómodo pero encadena recálculos hacia arriba: un `AutomaticSize` dentro de otro dentro de otro es costoso. Úsalo en una capa, no en cinco.

## 6. Actualizaciones por frame

- Nada de `while true do ... task.wait() end` para refrescar la UI. Usa eventos: `GetPropertyChangedSignal`, `Changed`, señales del servidor, `:GetAttributeChangedSignal`.
- Un HUD que muestra un valor continuo (velocímetro, barra de resistencia) sí necesita refresco frecuente, pero no siempre cada frame: 15–20 actualizaciones por segundo son indistinguibles de 60 para un número, y cuestan un tercio.

```lua
local ultimo = 0
RunService.RenderStepped:Connect(function()
    local ahora = os.clock()
    if ahora - ultimo < 0.05 then  -- ~20 veces por segundo
        return
    end
    ultimo = ahora
    etiqueta.Text = math.floor(velocidad) .. " km/h"
end)
```

- Asignar `.Text` obliga a recalcular los límites del texto. Comprueba antes si el valor cambió: si el número redondeado es el mismo que el del frame anterior, no lo asignes.
- Anima con `TweenService`, no moviendo propiedades en un bucle propio. El tween corre en el motor y es más barato.

## 7. Conexiones y fugas de memoria

El error clásico: reconectar eventos en cada refresco de la lista. Después de diez búsquedas, cada tarjeta tiene diez conexiones y cada clic dispara diez veces.

- Conecta los eventos **una vez** por instancia, justo después de crearla. Con pooling esto sale gratis, porque la instancia nunca muere.
- Si de verdad hay que destruir algo, guarda las conexiones y desconéctalas:

```lua
local conexiones = {}

table.insert(conexiones, boton.MouseButton1Click:Connect(alPulsar))

local function limpiar()
    for _, conexion in ipairs(conexiones) do
        conexion:Disconnect()
    end
    conexiones = {}
end
```

- `Destroy()` desconecta los eventos de esa instancia, pero no las conexiones a señales externas (`RunService`, remotos, atributos del jugador). Esas hay que soltarlas a mano.

## 8. Imágenes

- **Precarga** los iconos antes de mostrar la UI, para que no aparezcan en blanco:

```lua
local ContentProvider = game:GetService("ContentProvider")
task.spawn(function()
    ContentProvider:PreloadAsync(listaDeImageLabels)
end)
```

- **Sprite sheet** para muchos iconos pequeños: un solo asset y `ImageRectOffset` / `ImageRectSize` para recortar cada icono. Menos peticiones y menos texturas en memoria.
- Sube los iconos al tamaño en que se van a ver. Una imagen de 1024×1024 para un icono de 24 px gasta memoria de textura sin ningún beneficio visual.
- Iconos monocromos en blanco + `ImageColor3` para teñir: un asset sirve para todos los estados y todos los temas.

## 9. Efectos con coste alto

- **`CanvasGroup`** renderiza su contenido en una textura aparte para poder aplicar transparencia de grupo. Es muy útil para desvanecer un panel entero, pero un `CanvasGroup` grande, animado constantemente, o varios anidados, cuestan. Úsalo para la transición de apertura y cierre, no como contenedor por defecto.
- **`ClipsDescendants` anidado** en muchas capas añade trabajo de recorte. Uno o dos niveles está bien; diez no.
- **`ViewportFrame`** renderiza una escena 3D aparte: es lo más caro que puedes poner en una UI. Uno visible a la vez, nunca uno por tarjeta en una lista.
- **Muchas transparencias apiladas** en la misma zona de pantalla (overlay + panel + tarjeta + gradiente + stroke, todos semitransparentes) encarecen el dibujado. En móvil se nota.

## 10. Cómo medirlo

- **MicroProfiler** en Studio (`Ctrl+F6`, o desde el menú de depuración): muestra el tiempo por frame y permite ver si el coste está en el layout de la GUI o en otra parte.
- **Test → Device** no simula el rendimiento del teléfono, solo la resolución. Para rendimiento real hace falta abrir el juego en un dispositivo real.
- Contar instancias es sencillo y sorprendentemente informativo:

```lua
print(#pantalla:GetDescendants())
```

Si ese número crece cada vez que el jugador filtra o abre y cierra un panel, tienes una fuga: algo se está creando y no se está reutilizando.
