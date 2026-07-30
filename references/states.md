# Estados de interfaz

Leer en la Fase 3. La mayoría de las UIs de Roblox solo implementan el estado normal. Los otros ocho son los que hacen que la interfaz parezca terminada.

## Los nueve estados

| Estado | Cuándo | Cómo se ve |
|---|---|---|
| Normal | reposo | color base de `Theme` |
| Hover | cursor encima (solo PC) | superficie un poco más clara, `UIScale` 1.03 |
| Presionado | mientras se mantiene el clic o el toque | superficie más oscura, `UIScale` 0.97 |
| Seleccionado | opción activa de un grupo | borde de acento con `UIStroke`, fondo elevado, texto primario |
| Deshabilitado | acción no disponible | transparencia 0.5, sin respuesta a input, cursor sin cambio |
| Cargando | esperando datos | esqueleto o spinner, contenido oculto, interacción bloqueada |
| Vacío | no hay datos que mostrar | icono grande atenuado + mensaje + acción sugerida |
| Error | la operación falló | color de peligro, mensaje concreto, botón de reintentar |
| Éxito | la operación funcionó | color de éxito, check, se desvanece en 2 s |

## Implementación de un botón con estados

Un patrón simple y suficiente: una función que aplica el estado, y un estado guardado en una variable local.

```lua
local estadoActual = "Normal"

local function aplicarEstado(nuevoEstado)
    estadoActual = nuevoEstado

    if nuevoEstado == "Deshabilitado" then
        boton.Active = false
        boton.AutoButtonColor = false
        animar(boton, Theme.Animation.Fast, {
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = 0.4
        })
        etiqueta.TextTransparency = 0.5
        return
    end

    boton.Active = true

    if nuevoEstado == "Normal" then
        animar(boton, Theme.Animation.Fast, {
            BackgroundColor3 = Theme.Colors.Primary,
            BackgroundTransparency = 0
        })
        etiqueta.TextTransparency = 0
        animar(escala, Theme.Animation.Fast, { Scale = 1 })
    elseif nuevoEstado == "Hover" then
        animar(boton, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.PrimaryHover })
        animar(escala, Theme.Animation.Fast, { Scale = 1.03 })
    elseif nuevoEstado == "Presionado" then
        animar(boton, 0.08, { BackgroundColor3 = Theme.Colors.PrimaryPressed })
        animar(escala, 0.08, { Scale = 0.97 })
    end
end
```

Detalle que se olvida siempre: cuando un botón está deshabilitado, hover y press **no deben** cambiar nada. Comprueba el estado antes de aplicar el hover.

## Estado cargando

Dos opciones, según cuánto tarde:

**Esqueleto** (mejor para listas y tarjetas): frames grises con la forma del contenido final y un `UIGradient` que se desplaza. Se siente más rápido que un spinner porque adelanta la estructura.

**Spinner** (mejor para acciones puntuales): un `ImageLabel` circular girando con `Rotation`.

```lua
local girando = true
task.spawn(function()
    while girando and spinner.Parent do
        spinner.Rotation = spinner.Rotation + 6
        task.wait(0.02)
    end
end)
```

Mientras se carga, bloquea la interacción del panel afectado. Un botón "Comprar" que se puede pulsar cinco veces mientras la compra está en curso es un bug de producto.

## Estado vacío

Tres elementos, siempre:

1. Un icono grande y atenuado (transparencia 0.6).
2. Un mensaje concreto: no "Sin resultados", sino "No hay autobuses que coincidan con 'expres'".
3. Una salida: "Limpiar filtros", "Ir a la tienda", "Añadir el primero".

Un panel vacío sin mensaje se interpreta como una UI rota, y el jugador se va.

## Estado error

- Mensaje en lenguaje humano. `HTTP 429` no le dice nada a un jugador; "El servidor está ocupado, inténtalo de nuevo" sí.
- Botón de reintentar visible.
- Color de peligro solo en el borde o en el icono, no en todo el panel. Un panel entero en rojo es agresivo.
- No borres lo que el jugador había escrito o seleccionado antes del error.

## Estado éxito

- Confirmación breve: un check con escala 0 → 1 y `Back`, o un toast que aparece arriba y se va solo en 2 segundos.
- Actualiza el resto de la UI inmediatamente (monedas, cantidad, inventario). El jugador debe ver la consecuencia, no solo el mensaje.
- No uses un modal para confirmar el éxito de una acción trivial: interrumpe sin aportar.
