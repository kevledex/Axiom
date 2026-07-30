# Ejemplo completo: selector de autobuses

Este es el flujo entero de la skill, de principio a fin. Sirve de modelo para cualquier otra UI.

**Petición del usuario:** "Crea un selector premium de buses para mi juego."

---

## Fase 0 — Preguntas

> Antes de diseñarlo necesito tres cosas:
>
> 1. **¿Dónde lo guardo?** `StarterGui` (por defecto, aparece al entrar al juego) o `ReplicatedStorage` (si lo clonas tú con un script).
> 2. **¿Nombre?** Si no tienes preferencia, uso `BusSelectorUI`.
> 3. **¿Iconos con emojis o con imágenes propias?** Recomiendo imágenes: te dejo un módulo `Icons` con los IDs listos para que solo pegues los tuyos.

Respuesta del usuario: "StarterGui, el nombre que dijiste, e imágenes."

## Fase 1 — Dirección visual

- **Concepto**: industrial y funcional. El jugador es un conductor eligiendo su vehículo de trabajo, no un héroe abriendo un cofre.
- **Paleta**: fondo `(16,18,21)`, superficie `(26,29,34)`, elevada `(38,42,49)`, acento ámbar `(255,176,32)`, texto `(240,242,245)` y `(150,158,170)`. El ámbar remite a señalización de transporte.
- **Tipografía**: `GothamSSm`. Título 30 Bold, nombre de bus 16 SemiBold, especificaciones 12 Regular.
- **Forma**: radio 8 en tarjetas y botones, 12 en el panel raíz. Registro medio-técnico, nada infantil.
- **Navegación**: grid de tarjetas a la izquierda + panel de detalle a la derecha, con búsqueda y chips de filtro arriba.

## Fase 2 — Arquitectura

```
BusSelectorUI (ScreenGui)
├── Main (Frame, 0.78x0.8 escala, UISizeConstraint 320x420 a 1100x780)
│   ├── Header
│   │   ├── TitleBlock (Title + Subtitle)
│   │   └── CloseButton (44x44)
│   ├── SearchBar (TextBox)
│   ├── Filters (chips: Todos, Urbano, Interprovincial, Escolar)
│   └── Body
│       ├── ListWrapper
│       │   ├── BusCards (ScrollingFrame + UIGridLayout)
│       │   └── EmptyState
│       └── DetailsPanel (Titulo, Descripcion, Stats, ConfirmButton)
├── Configuration (Theme, Icons)
└── Controllers (UIController)
```

Breakpoints:

| | Amplio (>1000) | Medio (600–1000) | Compacto (<600) |
|---|---|---|---|
| Body | horizontal | horizontal | vertical |
| Tarjetas | 2 columnas, 96 px alto | 2 columnas | 1 columna, 84 px alto |
| DetailsPanel | 34 % del ancho | 34 % | 40 % de la altura, abajo |
| Filtros | todos visibles | todos visibles | scroll horizontal |

Nota de diseño: `EmptyState` va en un wrapper, no dentro del `ScrollingFrame`, porque el `UIGridLayout` lo trataría como una celda más.

## Fase 3 — Código

`Configuration/Theme` y `Configuration/Icons` primero, con los valores de la Fase 1. Después `Controllers/UIController` con: selección de tarjeta (estados normal/hover/press/seleccionada), búsqueda con estado vacío, cierre animado y la función `aplicarModo()` conectada a `AbsoluteSize`.

## Fase 4 — Instalador

Ver `templates/Installer.lua`: es exactamente este ejemplo, listo para pegar en la Command Bar. Comprueba si `BusSelectorUI` ya existe, registra la instalación en el historial para poder deshacerla, crea todo y selecciona el `ScreenGui` al terminar.

## Fase 5 — Entrega

> Listo. Para instalarlo:
>
> 1. Roblox Studio → pestaña **View** → **Command Bar**.
> 2. Pega el script completo y presiona Enter.
> 3. Verás `✅ BusSelectorUI instalada en StarterGui` en la Output.
>
> Qué editar después:
> - `BusSelectorUI/Configuration/Icons` → cambia los `rbxassetid://0` por tus IDs.
> - `Configuration/Theme` → si quieres otro color de acento, cambia solo `Primary`, `PrimaryHover` y `PrimaryPressed`; toda la UI se actualiza.
> - En `Controllers/UIController`, la tabla `EJEMPLOS` del instalador es de prueba: conéctala a tus datos reales de autobuses.
>
> Pruébalo en **Test → Device** con un teléfono pequeño y una tablet: en pantalla estrecha el panel de detalle pasa debajo de la lista y las tarjetas se ponen en una columna.

## Extensiones naturales

- Precio y estado bloqueado por tarjeta, con icono de candado y botón "Comprar por N" en lugar de "Seleccionar".
- `ViewportFrame` en el panel de detalle para ver el modelo 3D del autobús girando.
- Filtros funcionales conectados a una propiedad `Tipo` de cada dato.
- Persistencia de la última selección con `DataStore`, mostrando un badge "Actual" en la tarjeta elegida.
