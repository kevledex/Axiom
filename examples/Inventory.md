# Ejemplo: inventario

**Petición típica:** "Hazme un inventario para mi juego."

## Lo que define un buen inventario

Es la UI que más se abre en la sesión, así que gana la velocidad: abrir, encontrar, equipar, cerrar. Cualquier animación larga o navegación en capas estorba.

Decisiones clave antes de diseñar: ¿cuántas ranuras hay? ¿son fijas o crece la lista? ¿se puede arrastrar? ¿hay categorías?

## Estructura

```
InventoryUI (ScreenGui)
├── Main
│   ├── Header (Title + contador "34/60" + CloseButton)
│   ├── Categories (Todos | Armas | Consumibles | Materiales)
│   ├── Grid (ScrollingFrame + UIGridLayout)
│   │   ├── SlotCard x N
│   │   └── (ranuras vacías con borde punteado si el número es fijo)
│   └── ItemDetail (panel lateral, o modal en compacto)
├── Configuration (Theme, Icons)
└── Controllers (UIController, InventoryController)
```

## SlotCard

```
SlotCard (TextButton, cuadrado con UIAspectRatioConstraint = 1)
├── Icon (ImageLabel, centrado, 60 % del slot)
├── Quantity (TextLabel abajo a la derecha, "x12")
├── RarityBorder (UIStroke con el color de la rareza)
└── EquippedBadge (esquina superior derecha)
```

El `UIAspectRatioConstraint` es obligatorio aquí: sin él, las ranuras se deforman en cuanto cambia la resolución y el inventario deja de leerse como una cuadrícula.

La rareza se comunica con el color del borde **y** con algo más (el nombre coloreado, un fondo con gradiente suave). Solo color deja fuera a los jugadores con daltonismo.

## Rejilla responsive

| Modo | Columnas | Tamaño de celda |
|---|---|---|
| Amplio | 6 | `UDim2.new(0.15, 0, 0, 0)` + aspect 1 |
| Medio | 5 | `UDim2.new(0.18, 0, 0, 0)` |
| Compacto | 4 | `UDim2.new(0.23, 0, 0, 0)` |

Cuatro columnas en un teléfono da ranuras de unos 70 px: suficiente para tocar sin fallar. Seis columnas en móvil produce ranuras de 45 px y toques equivocados constantes.

## Estados

- **Vacío total**: icono de mochila atenuado + "Tu inventario está vacío" + botón "Ir a la tienda". Nunca una cuadrícula gris silenciosa.
- **Vacío por filtro**: "No tienes objetos en Materiales" + "Ver todos".
- **Cargando**: ranuras esqueleto con el gradiente desplazándose. Se percibe más rápido que un spinner porque ya muestra la estructura.
- **Ranura vacía** (si el número es fijo): fondo más oscuro que la superficie y `UIStroke` tenue. Debe leerse como "espacio disponible", no como "objeto que no cargó".
- **Lleno**: el contador `60/60` en color de advertencia y un mensaje al intentar recoger algo.

## Rendimiento

Un inventario grande es el sitio donde más fácil se rompe el rendimiento en móvil:

- Con más de 60 ranuras, reutiliza instancias en vez de destruir y crear en cada filtro: cambia `Visible`, `Icon` y `Quantity` de las que ya existen.
- No animes 60 tarjetas en cascada. Anima solo lo que está visible, con un tope de 10–12 elementos.
- `AutomaticCanvasSize = Enum.AutomaticSize.Y` en el `ScrollingFrame` y olvídate de recalcular `CanvasSize`: si no lo pones, la lista crece y el jugador no puede desplazarse, que es el bug clásico del inventario.

## Interacción

- Toque simple selecciona y muestra el detalle. Doble toque equipa. Toque largo abre acciones (soltar, dividir).
- En PC, la tecla del inventario (normalmente `Tab` o `E`) abre y cierra. `Escape` siempre cierra.
- El detalle en compacto es un modal, no un panel estrecho al lado: en 380 px de ancho no caben dos columnas legibles.
