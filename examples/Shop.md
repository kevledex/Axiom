# Ejemplo: tienda premium

**Petición típica:** "Crea una tienda premium para mi juego."

## Lo que hace especial a una tienda

Una tienda es la UI donde el jugador decide gastar. Todo lo que confunda o genere desconfianza cuesta ventas. Prioridades, en orden:

1. El **saldo** siempre visible, arriba, y actualizado al instante después de comprar.
2. El **precio** legible sin esfuerzo, con el icono de moneda al lado del número.
3. La diferencia entre "puedo comprarlo", "no me alcanza" y "ya lo tengo" clara de un vistazo, sin leer.
4. Confirmación antes de gastar. Una compra accidental es la peor experiencia posible.

## Estructura

```
ShopUI (ScreenGui)
├── Main
│   ├── TopBar
│   │   ├── Title ("Tienda")
│   │   ├── BalanceChip (icono moneda + cantidad)  <- se actualiza tras cada compra
│   │   └── CloseButton (44x44)
│   ├── Tabs (Destacados | Vehículos | Skins | Mejoras)
│   │   └── Indicator (Frame de 2 px que se desliza con Tween)
│   └── Content (ScrollingFrame + UIGridLayout)
│       └── ItemCard x N
├── ConfirmModal (Overlay + Dialog)
├── Toast (confirmación de éxito, se va sola en 2 s)
├── Configuration (Theme, Icons)
└── Controllers (UIController, ShopController)
```

## Estados de una ItemCard

| Estado | Aspecto |
|---|---|
| Comprable | superficie normal, precio en texto primario, botón de acento |
| Sin saldo | precio en color de peligro, botón deshabilitado con texto "Te faltan 120" |
| Ya comprado | check verde en la esquina, botón "Equipar" en variante secundaria |
| Equipado | borde de acento + badge "En uso", sin botón |
| Destacado | badge "-30 %" y borde sutil, nada más: si todo destaca, nada destaca |

El caso "sin saldo" no se resuelve escondiendo el ítem. Se muestra con el precio marcado y cuánto falta: eso informa en vez de frustrar.

## Modal de confirmación

```
Overlay (negro, transparencia 0.5, cubre la pantalla y captura los clics)
└── Dialog (centrado, UISizeConstraint 280-420 px de ancho)
    ├── Preview del ítem
    ├── "¿Comprar Autobús Doble Piso por 1.200?"
    ├── Saldo después: 340
    └── Actions: [Cancelar (Ghost)] [Comprar (Primary)]
```

Detalles que importan: el overlay debe capturar los clics para que no se pueda pulsar detrás; el botón de cancelar va a la izquierda y en variante discreta; mostrar el saldo resultante evita arrepentimientos.

## Flujo de compra, con todos los estados

1. Toque en "Comprar" → el botón pasa a **cargando** y se bloquea.
2. `RemoteFunction` al servidor. **El servidor valida el precio y el saldo.** Nunca confíes en el cliente para una transacción.
3. Éxito → toast verde "¡Comprado!", el saldo se anima al nuevo valor, la tarjeta pasa a "Ya comprado".
4. Error → mensaje concreto ("No tienes saldo suficiente", "Ese objeto ya no está disponible") y botón de reintentar. El modal no se cierra solo.

## Detalles de acabado

- El saldo cambia con un tween numérico corto (0.3 s) en lugar de saltar: se percibe la consecuencia.
- El indicador de pestaña deslizante cuesta diez líneas y sube mucho la sensación de calidad.
- En compacto: 1–2 columnas, la barra de saldo se queda fija arriba, y el modal ocupa casi toda la pantalla con el botón de comprar abajo, donde llega el pulgar.
- Nada de temporizadores falsos de "oferta termina en 00:59" que se reinician. Rompen la confianza.
