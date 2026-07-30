# Instalador para la Command Bar

Leer en la Fase 4. Este es el entregable que convierte el diseño en una UI real dentro del proyecto del usuario.

Contenido:
1. Cómo funciona la Command Bar
2. Estructura del instalador
3. El helper `crear`
4. Escribir el código de los ModuleScripts
5. Protección del trabajo existente
6. Historial y deshacer
7. Si el script es demasiado grande
8. Errores frecuentes
9. Qué decirle al usuario al entregar

---

## 1. Cómo funciona la Command Bar

En Roblox Studio: pestaña **View → Command Bar**. Aparece una línea de comandos en la parte inferior. El usuario pega el script, presiona Enter y se ejecuta.

Dos cosas importantes:

- El código de la Command Bar se ejecuta en **modo edición** con permisos de plugin. Eso significa que puede crear instancias permanentes en el proyecto y, a diferencia de un script en tiempo de ejecución, puede **escribir la propiedad `Source` de un `Script` o `ModuleScript`**. Es lo que permite instalar módulos completos con su código dentro.
- Los cambios son reales y se guardan con el proyecto. No es una simulación de Play.

Por eso el instalador tiene que ser cuidadoso: está tocando el archivo del usuario.

## 2. Estructura del instalador

Ordena el script en secciones comentadas, en el mismo orden que el árbol diseñado en la Fase 2:

```
1. Configuración (nombre, destino)
2. Comprobación de existencia previa
3. Helpers (crear, crearModulo, aplicarEsquinas...)
4. Paleta y constantes locales (las mismas que irán en Theme)
5. ScreenGui + Main
6. Configuration (Theme, Icons)
7. Components (Button, Card, Icon...)
8. Estructura visual (Header, SearchBar, Filters, Cards, DetailsPanel)
9. Controllers (UIController, AnimationController)
10. Selección en el explorador + mensaje de éxito
```

La sección 4 existe porque el instalador necesita los colores para crear las instancias, y el `Theme` los necesita en tiempo de ejecución. Duplicar la paleta en dos formatos es aceptable; lo que no es aceptable es escribir `Color3.fromRGB(255, 176, 32)` cuarenta veces sueltas.

## 3. El helper `crear`

Sin él, un instalador de 1500 líneas serían 4000.

```lua
local function crear(clase, propiedades, padre)
    local objeto = Instance.new(clase)
    for nombre, valor in pairs(propiedades or {}) do
        objeto[nombre] = valor
    end
    objeto.Parent = padre
    return objeto
end
```

`Parent` se asigna al final a propósito: cada propiedad que se cambia con el objeto ya dentro del árbol dispara un recálculo de layout. Por la misma razón, nunca uses `Instance.new("Frame", padre)`.

Helpers que conviene añadir según la UI:

```lua
local function esquinas(objeto, radio)
    crear("UICorner", { CornerRadius = UDim.new(0, radio) }, objeto)
end

local function relleno(objeto, arriba, abajo, izq, der)
    crear("UIPadding", {
        PaddingTop = UDim.new(0, arriba),
        PaddingBottom = UDim.new(0, abajo or arriba),
        PaddingLeft = UDim.new(0, izq or arriba),
        PaddingRight = UDim.new(0, der or izq or arriba),
    }, objeto)
end

local function lista(objeto, direccion, separacion, alineacion)
    return crear("UIListLayout", {
        FillDirection = direccion,
        Padding = UDim.new(0, separacion),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = alineacion or Enum.HorizontalAlignment.Left,
    }, objeto)
end
```

## 4. Escribir el código de los ModuleScripts

El `Source` se pasa como cadena larga. Usa delimitadores con signos igual (`[==[ ... ]==]`) porque el código de dentro casi siempre contiene `]]` de comentarios de bloque o de tablas anidadas, y eso cerraría un `[[ ... ]]` a mitad de camino.

```lua
local function crearModulo(nombre, fuente, padre)
    local modulo = Instance.new("ModuleScript")
    modulo.Name = nombre
    modulo.Source = fuente
    modulo.Parent = padre
    return modulo
end

crearModulo("Theme", [==[
local Theme = {}

Theme.Colors = {
    Background = Color3.fromRGB(16, 18, 21),
    Surface = Color3.fromRGB(26, 29, 34),
    Primary = Color3.fromRGB(255, 176, 32),
    TextPrimary = Color3.fromRGB(240, 242, 245),
    TextSecondary = Color3.fromRGB(150, 158, 170),
}

Theme.Spacing = {
    Small = 8,
    Medium = 16,
    Large = 24,
}

Theme.Animation = {
    Fast = 0.12,
    Normal = 0.25,
}

return Theme
]==], configuracion)
```

Para un `LocalScript` es exactamente igual, cambiando la clase:

```lua
local function crearLocal(nombre, fuente, padre)
    local script = Instance.new("LocalScript")
    script.Name = nombre
    script.Source = fuente
    script.Parent = padre
    return script
end
```

Usa `LocalScript` cuando la UI vive en `StarterGui`: Roblox la clona al `PlayerGui` del jugador y el script arranca solo. Si la UI vive en `ReplicatedStorage` para clonarse a mano, deja el script como `LocalScript` también: se activará cuando el clon llegue al `PlayerGui`, que es justo lo que se quiere.

Si dentro de una fuente necesitas escribir `]==]`, sube el nivel a `[===[ ... ]===]`.

## 5. Protección del trabajo existente

Esto no es negociable: el instalador **nunca** borra ni sobrescribe.

```lua
local NOMBRE_UI = "BusSelectorUI"
local destino = game:GetService("StarterGui")

if destino:FindFirstChild(NOMBRE_UI) then
    warn("Ya existe " .. NOMBRE_UI .. " en " .. destino.Name .. ". No se reemplazó. Renómbralo o bórralo tú si quieres reinstalar.")
    return
end
```

`return` corta la ejecución del chunk ahí mismo. Ponlo antes de crear cualquier instancia, para no dejar basura a medias.

Si el usuario pide explícitamente reinstalar, dale la opción de forma consciente, con una bandera al principio del script que él tiene que cambiar a mano:

```lua
local REEMPLAZAR_SI_EXISTE = false  -- ponlo en true solo si quieres borrar la versión anterior
```

Nunca la dejes en `true` por defecto.

## 6. Historial y deshacer

Un detalle profesional: registrar la instalación en el historial de Studio para que `Ctrl+Z` la deshaga de una vez.

```lua
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local registro = ChangeHistoryService:TryBeginRecording("Instalar " .. NOMBRE_UI)

-- ... aquí se crea toda la UI ...

if registro then
    ChangeHistoryService:FinishRecording(registro, Enum.FinishRecordingOperation.Commit)
end
```

Comprueba siempre que `registro` no sea `nil` (puede fallar si ya hay una grabación abierta). Si la API no está disponible en la versión de Studio del usuario, envuélvela en `pcall` y sigue: el instalador debe funcionar igual sin el historial.

Al terminar, selecciona lo creado para que el usuario lo vea en el explorador:

```lua
game:GetService("Selection"):Set({ pantalla })
print("✅ " .. NOMBRE_UI .. " instalada en " .. destino.Name)
print("👉 Edita Configuration/Icons y cambia los rbxassetid://0 por tus IDs")
```

## 7. Si el script es demasiado grande

La Command Bar acepta texto pegado de varias líneas, pero con scripts muy largos puede haber problemas de pegado o de límite de entrada. La solución no es recortar la calidad, es partir el instalador en partes numeradas donde cada parte comprueba la anterior:

**Parte 1** — crea el `ScreenGui`, `Main` y la estructura visual.
**Parte 2** — crea `Configuration` y `Components` con su `Source`.
**Parte 3** — crea `Controllers`.

Cada parte empieza así:

```lua
local destino = game:GetService("StarterGui")
local pantalla = destino:FindFirstChild("BusSelectorUI")
if not pantalla then
    warn("Ejecuta primero la Parte 1.")
    return
end
```

Y termina con `print("✅ Parte 2 de 3 completada")`. Numera siempre las partes en el mensaje al usuario para que no pierda el hilo.

## 8. Errores frecuentes

- **Olvidar `BorderSizePixel = 0`** en frames: aparece el borde negro por defecto y todo el diseño se ve barato.
- **`AutoButtonColor` activo** en botones: Roblox oscurece el botón al pulsarlo y arruina la animación propia.
- **Asignar `Position` a hijos de un `UIListLayout`**: no hace nada.
- **Crear los layouts después de los hijos** sin `LayoutOrder`: el orden queda alfabético y "Item10" va antes de "Item2".
- **Usar `script.Parent` en el instalador**: el código de la Command Bar no está dentro de ningún script; usa referencias explícitas (`game:GetService("StarterGui")`).
- **Dejar `rbxassetid://` con un número inventado**: o falla, o carga la imagen de un desconocido.
- **Un `UICorner` con `UDim.new(0.5, 0)`** en un frame rectangular: sale una cápsula deformada.
- **No comprobar la existencia previa**: el usuario acaba con dos UIs iguales o pierde su versión editada.

## 9. Qué decirle al usuario al entregar

Cierra siempre con estas cuatro cosas, cortas:

1. **Instalación**: abre Roblox Studio → pestaña View → Command Bar → pega el script → Enter.
2. **Qué editar**: `Configuration/Icons` (los IDs) y `Configuration/Theme` (colores, si quiere otra identidad).
3. **Cómo probarlo**: Test → Device, con un teléfono pequeño y una tablet, además del escritorio.
4. **Si algo falla**: el mensaje exacto que apareció en la Output, para poder corregirlo.
