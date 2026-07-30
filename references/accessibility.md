# Accesibilidad y legibilidad

Leer en la Fase 3 y al repasar el checklist. Buena parte de los jugadores de Roblox son niños, juegan en teléfonos pequeños, con brillo bajo o en movimiento. La accesibilidad aquí no es un extra ético abstracto: es lo que hace que la UI funcione para la mayoría del público real.

## Contraste

- Texto principal sobre su fondo: apunta a una relación de contraste de al menos 4.5:1. En términos prácticos, con fondos oscuros (RGB por debajo de 40) el texto debe estar por encima de RGB 220.
- Texto secundario: puede bajar hasta 3:1, pero nunca uses gris medio sobre gris medio (`(120,120,120)` sobre `(90,90,90)` es ilegible).
- Nunca comuniques información **solo** con color. Un ítem "bloqueado" en rojo y "disponible" en verde deja fuera a los jugadores con daltonismo: añade un icono de candado, un texto o un patrón.
- Texto sobre imagen o gradiente: pon una capa de oscurecimiento detrás (`Frame` negro con transparencia 0.4) o un `UIStroke` sutil en el texto. Sin eso, el texto desaparece en las zonas claras.

## Tamaños táctiles

- Objetivo mínimo cómodo: **44×44 px** de área tocable. En pantallas pequeñas, 48×48.
- El área tocable puede ser mayor que el elemento visible: un icono de 24 px dentro de un `ImageButton` de 48 px transparente.
- Separación mínima entre dos objetivos táctiles: 8 px. Botones pegados producen toques equivocados.
- El botón de cerrar es el que más se falla. Nunca menos de 40 px en móvil, y nunca pegado al borde absoluto de la pantalla (los notch y las esquinas redondeadas recortan).

## Texto legible

- Tamaño mínimo de texto que el jugador debe leer: 14 px. Para etiquetas decorativas puedes bajar a 12, nunca menos.
- Con `TextScaled = true`, añade siempre `UITextSizeConstraint` con `MinTextSize = 14`.
- Evita mayúsculas completas en textos largos: se leen peor. Sirven para etiquetas de dos o tres palabras.
- Alineación a la izquierda para textos de más de una línea. El texto centrado de varias líneas cansa.
- `TextTruncate = Enum.TextTruncate.AtEnd` en vez de dejar que un nombre largo desborde el contenedor.
- Si el juego apunta a público internacional, deja margen: la misma frase en alemán o en español puede ocupar un 30 % más que en inglés. Un botón dimensionado justo para "Buy" se rompe con "Comprar ahora".

## Soporte de gamepad y teclado

Si el juego se puede jugar con mando o el usuario lo pide:

- `Selectable = true` en los elementos navegables y `SelectionOrder` para definir el recorrido.
- `GuiService.SelectedObject` para fijar el foco inicial al abrir un panel.
- `SelectionImageObject` para personalizar el resaltado en vez del cuadro azul por defecto.
- El estado **seleccionado** tiene que ser claramente visible: con mando no hay cursor, el foco es la única referencia.
- Escape / botón B debe cerrar el panel abierto. Se implementa con `UserInputService.InputBegan` y `Enum.KeyCode.Escape` / `ButtonB`, o con `ContextActionService` si hay que sobreescribir el comportamiento por defecto.

## Movimiento y sonido

- Nada de parpadeos rápidos ni destellos de pantalla completa: pueden provocar molestias reales.
- Si añades sonidos de UI, volumen bajo y clips muy cortos, con un interruptor para silenciarlos en los ajustes. Ver `sound-design.md`.
- Ninguna información crítica solo por sonido: mucha gente juega en silencio.

## Claridad del lenguaje

- Etiquetas concretas: "Comprar por 250" en lugar de "Aceptar".
- Errores en lenguaje humano, no códigos.
- Un panel vacío siempre lleva mensaje y salida (ver `states.md`).
- Evita jerga interna del desarrollador en la UI ("respawn del handler falló"). El jugador no debería leer nunca el nombre de una variable.
