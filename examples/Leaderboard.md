# Ejemplo: leaderboard

**Petición típica:** "Una tabla de clasificación para mi juego."

Puede ser panel o HUD según el caso, y conviene aclararlo en la Fase 0: un ranking global que se abre desde un menú es un panel; una lista de los cinco primeros siempre visible en pantalla es un HUD.

## Lo que define un buen leaderboard

Tres cosas, en este orden:

1. **El jugador se encuentra a sí mismo al instante.** Si tiene que buscar su nombre entre cien filas, la tabla ha fallado.
2. **Los números se comparan de un vistazo.** Alineación a la derecha, mismo formato, sin decimales inconsistentes.
3. **El cambio se ve.** Subir de puesto es el momento de recompensa de toda la pantalla; si pasa sin animación, se desperdicia.

## Estructura

```
LeaderboardUI (ScreenGui)
└── Main
    ├── Header (Title + Tabs: Global | Amigos | Semanal)
    ├── ColumnHeaders (Puesto | Jugador | Puntuación)
    ├── List (ScrollingFrame)
    │   └── Row x N (lote reutilizable)
    │       ├── Rank (TextLabel, ancho fijo)
    │       ├── Avatar (ImageLabel, circular)
    │       ├── Name (TextLabel, TextTruncate)
    │       ├── Score (TextLabel, alineado a la derecha)
    │       └── Medal (solo puestos 1-3)
    └── SelfRow (fila fija abajo, siempre visible)
```

`SelfRow` fuera del `ScrollingFrame` es la decisión clave: la fila del propio jugador queda anclada abajo, visible sin importar dónde esté el scroll. Resuelve el problema número uno.

## Estrategia de lista: aquí sí hace falta virtualizar

Un ranking global puede tener cientos o miles de entradas. Es el caso de uso donde el pooling simple no basta.

- **Hasta ~40 filas**: lote fijo reutilizable.
- **Más de 40**: virtualización, renderizando solo la ventana visible más un margen.

El código completo de virtualización está en `references/performance.md`. El recordatorio importante: cuando virtualizas, **no** se usa `UIListLayout` en ese contenedor, porque el layout automático y el posicionamiento manual se pelean. Es la única excepción a la regla general de la skill.

## Formato de los números

```lua
local function formatearPuntuacion(numero)
    local texto = tostring(math.floor(numero))
    local resultado = texto:reverse():gsub("(%d%d%d)", "%1."):reverse()
    return (resultado:gsub("^%.", ""))
end
```

`1.284.500` se lee; `1284500` no. Y una vez elegido el separador, se usa igual en toda la UI.

Para números muy grandes, abreviar: `1.2 M`, `450 K`. Pero solo en la lista; en el detalle del jugador, el número exacto.

Alineación a la derecha, **siempre**, y con ancho fijo. Es lo que permite comparar sin leer.

## Los tres primeros

Merecen tratamiento distinto, pero con moderación:

- **Medalla o color** en el número de puesto: oro, plata, bronce. Un `ImageLabel` o el número teñido.
- **Fondo ligeramente elevado** en las tres primeras filas (`SurfaceElevated` en vez de `Surface`).
- Nada más. Si el primer puesto tiene borde brillante, gradiente, animación y tamaño doble, el resto de la tabla deja de existir visualmente.

## La fila del propio jugador

Se distingue con borde de acento, no con un color de fondo llamativo. Y aparece dos veces: en su posición real dentro de la lista, y anclada en `SelfRow`. Si el jugador está entre los visibles, `SelfRow` puede ocultarse para no duplicar información — o mantenerse siempre, que es más simple y más predecible.

Si el jugador no está clasificado: `SelfRow` muestra "Sin clasificar" y su puntuación actual, nunca queda vacía.

## Actualización sin reconstruir

```lua
local function refrescar(datos)
    for indice, fila in ipairs(lote) do
        local entrada = datos[indice]
        if entrada then
            fila.Rank.Text = "#" .. entrada.Puesto
            fila.Name.Text = entrada.Nombre
            fila.Score.Text = formatearPuntuacion(entrada.Puntuacion)
            fila.Visible = true
        else
            fila.Visible = false
        end
    end
end
```

Y para el cambio de puesto, un destello corto en la fila afectada más un tween del color de fondo. Nada de reordenar con animación de movimiento: con un `UIListLayout` los elementos se recolocan de golpe y animar sus posiciones produce parpadeo (ver `known-pitfalls.md`).

## Avatares

Los avatares son la parte más costosa de un leaderboard:

- Usa `Players:GetUserThumbnailAsync(userId, tipo, tamano)` para obtener la URL, y **cachea el resultado**: es una llamada de red por jugador.
- Envuélvelo en `pcall`: falla si el usuario no existe o si el servicio no responde, y una excepción no debe tumbar la tabla.
- Pide el tamaño más pequeño que se vea bien (48×48 suele bastar).
- Mientras carga, un círculo con la inicial del nombre. Nunca un hueco vacío.
- Con virtualización, pide el avatar solo de las filas visibles. Cien avatares de golpe es una tormenta de peticiones.

## Datos del servidor

- La puntuación **se calcula y valida en el servidor**. Un leaderboard alimentado por el cliente es un leaderboard falsificable.
- Con `OrderedDataStore` para rankings persistentes, y un intervalo de refresco razonable: cada 30–60 segundos, no cada segundo. Los límites de peticiones existen.
- Guarda lo recibido y muéstralo mientras llega la siguiente actualización. Una tabla que se queda en blanco entre refrescos parece rota.

## Estados

- **Cargando**: filas esqueleto con el gradiente desplazándose. Se percibe más rápido que un spinner porque ya muestra la estructura.
- **Vacío**: "Todavía nadie ha puntuado. Sé el primero." con la acción que lleva a jugar.
- **Error**: "No se pudo cargar la clasificación" y botón de reintentar, manteniendo los datos anteriores si los había.
- **Sin conexión con el DataStore**: mensaje distinto al de error genérico, porque el jugador no puede hacer nada al respecto y conviene decírselo.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Columnas | puesto, avatar, nombre, puntuación, extra | puesto, nombre, puntuación |
| Avatar | 48 px | oculto, o 32 px |
| Alto de fila | 52 px | 44 px |
| Pestañas | visibles en fila | desplegable |
| SelfRow | anclada abajo | anclada abajo, prioritaria |

En compacto, el avatar es lo primero que se sacrifica: ocupa espacio horizontal que el nombre y la puntuación necesitan más. Y las columnas extra (partidas jugadas, nivel) desaparecen: van en el detalle al tocar la fila.
