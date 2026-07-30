# UI responsive en Roblox

Leer en las Fases 2 y 3. Más de la mitad de las sesiones de Roblox son en móvil: una UI que solo se ve bien en el monitor del desarrollador está mal hecha.

Contenido:
1. Scale vs Offset
2. Detectar el tamaño de pantalla
3. Breakpoints y escalado global
4. Rediseño móvil, no encogido
5. Zonas seguras
6. Cómo probarlo

---

## 1. Scale vs Offset

`UDim2.new(escalaX, offsetX, escalaY, offsetY)`. La escala es proporción del contenedor padre; el offset son píxeles fijos.

Usa **Scale** para:
- El tamaño del panel principal respecto a la pantalla.
- Anchos de columnas y proporciones del layout.
- Posiciones de contenedores.

Usa **Offset** para:
- Padding y separaciones (16 px son 16 px en cualquier pantalla).
- Grosor de bordes, altura de barras finas, tamaño de iconos pequeños.
- Límites de `UISizeConstraint`.

La combinación que funciona casi siempre:

```lua
panel.Size = UDim2.fromScale(0.7, 0.75)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)

local limites = Instance.new("UISizeConstraint")
limites.MinSize = Vector2.new(320, 400)
limites.MaxSize = Vector2.new(1100, 800)
limites.Parent = panel
```

Escala para adaptarse, constraint para no pasarse. Nunca dejes un panel importante con posición y tamaño 100 % en offsets fijos: es lo que produce UIs que se salen de la pantalla en un teléfono.

`AnchorPoint` es clave: para centrar algo, `Position = fromScale(0.5, 0.5)` + `AnchorPoint = (0.5, 0.5)`. Sin anchor, el centro se calcula desde la esquina superior izquierda del elemento.

## 2. Detectar el tamaño de pantalla

La fuente de verdad es `AbsoluteSize` del `ScreenGui`, no `UserInputService`. Un portátil con pantalla táctil tiene `TouchEnabled = true` y no es un móvil; una tablet grande no necesita el layout de un teléfono.

```lua
local pantalla = script.Parent  -- el ScreenGui

local function obtenerModo()
    local ancho = pantalla.AbsoluteSize.X
    if ancho < 600 then
        return "Compacto"
    elseif ancho < 1000 then
        return "Medio"
    else
        return "Amplio"
    end
end

local function aplicarModo()
    local modo = obtenerModo()
    -- reorganiza el layout según el modo
end

pantalla:GetPropertyChangedSignal("AbsoluteSize"):Connect(aplicarModo)
aplicarModo()
```

Escuchar el cambio de `AbsoluteSize` cubre también el redimensionado de la ventana en PC y la rotación del dispositivo en móvil, algo que una comprobación única al arrancar se pierde.

`UserInputService.TouchEnabled` sigue siendo útil, pero para otra cosa: decidir si mostrar pistas de teclado ("Presiona E") o de toque, y si vale la pena implementar hover.

## 3. Breakpoints y escalado global

Tres modos bastan:

| Modo | Ancho | Objetivo |
|---|---|---|
| Compacto | < 600 px | teléfonos |
| Medio | 600–1000 px | tablets, ventanas pequeñas |
| Amplio | > 1000 px | PC |

Además del cambio de layout, aplica un escalado global suave con un `UIScale` en el `Main`:

```lua
local escala = Instance.new("UIScale")
escala.Parent = main

local function actualizarEscala()
    local ancho = pantalla.AbsoluteSize.X
    -- referencia: 1280 px de ancho = escala 1
    local factor = math.clamp(ancho / 1280, 0.8, 1.25)
    escala.Scale = factor
end
```

El `clamp` evita los dos extremos malos: una UI ilegible en un teléfono viejo y una UI gigantesca en un monitor 4K. Ajusta los límites según lo denso que sea el diseño.

## 4. Rediseño móvil, no encogido

La versión compacta no es la de PC con menos píxeles. Cambia el diseño:

| Amplio (PC) | Compacto (móvil) |
|---|---|
| Sidebar vertical fija | barra inferior con iconos, o menú desplegable |
| 3–4 columnas de tarjetas | 1–2 columnas, o carrusel horizontal |
| Grid + panel de detalle al lado | grid a pantalla completa, detalle en modal |
| Metadatos siempre visibles | solo el dato principal; el resto al abrir el detalle |
| Botones de 36 px de alto | botones de 48 px o más |
| Tooltips en hover | nada, o toque largo |
| Texto de 15 px | texto de 16–18 px |

Decisiones concretas para el modo compacto:

- **Menos información a la vez.** Un teléfono con seis columnas de datos no se lee; se hace scroll y se lee una cosa cada vez.
- **La acción principal, abajo.** El pulgar llega cómodamente a la mitad inferior. Un botón "Comprar" arriba a la derecha en un teléfono grande es incómodo.
- **Cerrar con gesto además de botón.** Un modal que solo se cierra con una X de 20 px frustra.
- **Sin hover.** Si un dato solo aparece al pasar el ratón, en móvil no existe. Hazlo visible o quítalo.

Implementación limpia: crea todos los elementos una sola vez y en `aplicarModo()` cambia propiedades (`FillDirection`, `CellSize`, `Visible`, `Size`, `TextSize`, `LayoutOrder`). No destruyas y reconstruyas la UI en cada cambio de tamaño.

```lua
local function aplicarModo()
    local modo = obtenerModo()
    local compacto = (modo == "Compacto")

    barraLateral.Visible = not compacto
    barraInferior.Visible = compacto
    grid.CellSize = compacto and UDim2.new(0.48, 0, 0, 150) or UDim2.new(0.23, 0, 0, 180)
    panelDetalles.Visible = not compacto  -- en compacto se abre como modal
end
```

## 5. Zonas seguras

- Arriba a la izquierda está el botón de Roblox. Con `IgnoreGuiInset = true` tienes que reservar tú ese espacio: unos 36–48 px de margen superior.
- Arriba a la derecha suelen estar los botones de chat y lista de jugadores.
- En móvil, abajo a la izquierda está el joystick virtual y abajo a la derecha el botón de salto. No pongas nada interactivo ahí si la UI convive con el juego (un HUD). Para menús que ocupan toda la pantalla no importa, porque los controles se ocultan.
- Los teléfonos con notch recortan las esquinas: no pongas el botón de cerrar pegado al borde absoluto.

Si necesitas el inset real, `GuiService:GetGuiInset()` te devuelve el desplazamiento superior que aplica Roblox.

## 6. Cómo probarlo

Antes de entregar cualquier UI, en Studio:

1. **Test → Device**, y prueba al menos: un teléfono pequeño en vertical, un teléfono en horizontal, una tablet y la resolución de escritorio.
2. Redimensiona la ventana de Studio arrastrándola mientras la UI está visible, para verificar que el `AbsoluteSize` responde.
3. Comprueba que ningún texto se corta, ningún botón queda fuera de la pantalla y ninguna lista queda sin scroll.

Estas tres comprobaciones detectan la gran mayoría de los fallos responsive.
