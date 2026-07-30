# Emojis y glifos: qué renderiza de verdad en Roblox

Leer en la Fase 0 (al decidir el sistema de iconos) y en la Fase 3 (antes de escribir cualquier carácter que no sea texto normal).

Un cuadro vacío en lugar de un icono es uno de los fallos que más barata hace ver una interfaz, y ocurre en silencio: en el Studio del desarrollador se ve bien y en el teléfono del jugador aparece el rectángulo.

## Por qué falla

Un emoji no es una imagen: es un carácter que la fuente tiene que saber dibujar. Las familias de fuentes de Roblox (`GothamSSm`, `SourceSansPro`, `Montserrat`...) cubren letras, números y símbolos básicos, pero **no incluyen el set de emoji en color**. Cuando el carácter no existe en la fuente, el motor intenta un respaldo del sistema, y ahí es donde aparecen las diferencias:

- En algunos dispositivos móviles el sistema aporta el emoji en color y se ve.
- En Windows suele salir en monocromo, con otra forma y otra alineación.
- En bastantes casos no hay respaldo y aparece el rectángulo vacío (el "tofu").

Resultado: el mismo código produce tres resultados distintos, y ninguno se puede controlar desde el diseño.

## Limitaciones adicionales, incluso cuando sí se ve

- **No se pueden teñir.** `ImageColor3` no aplica a texto; un emoji ignora tu paleta y aporta sus propios colores. Rompe la identidad visual de golpe.
- **No se alinean bien.** La línea base y el alto de un emoji no coinciden con los del texto de al lado, así que un "🚌 MetroLine 200" queda descuadrado.
- **No escalan igual.** Con `TextScaled` el emoji crece de forma distinta al texto.
- **No tienen estados.** No puedes atenuar un emoji para un estado deshabilitado como harías con `ImageTransparency`.

## Clasificación práctica

**Nivel A — Símbolos de texto, fiables**

Caracteres de los bloques básicos de símbolos, presentes en prácticamente cualquier fuente. Se comportan como texto: heredan `TextColor3`, se alinean con la línea base y se pueden animar.

```
✕  ✓  ×  •  ●  ○  ★  ☆  ▸  ▾  ◂  ▴  →  ←  ↑  ↓  ⚙  ⌂  ♦  §  ¶  …  —
```

Estos son la opción correcta cuando no quieres subir assets: son monocromos, se tiñen con el color del tema y no dependen de un respaldo del sistema.

**Nivel B — Emoji en color, no fiables**

Todo el rango de pictogramas en color: 🚌 💰 👑 ⚙️ (con selector de variación) 🔍 📦 ❤️ ⭐ y similares. Pueden verse perfectos en tu equipo y como un cuadro en el del jugador.

Nota sobre un caso traicionero: `⚙` (símbolo) y `⚙️` (el mismo carácter con selector de variación de emoji) **no son lo mismo**. El primero es Nivel A y el segundo Nivel B. Copiar y pegar desde una web suele traer el selector invisible pegado.

## Reglas

1. **Nunca uses Nivel B en elementos críticos.** Crítico = precio, símbolo de moneda, cantidad, botón de cerrar, confirmar, cancelar, indicador de bloqueado, contador de vida. Si el jugador necesita ese elemento para entender o para actuar, va como `ImageLabel` o como símbolo de Nivel A. Un precio que muestra "☐ 1200" no es un detalle estético: es información perdida.

2. **Si el usuario elige emojis, explícale el límite y ofrécele Nivel A.** No es "emojis o imágenes": es "símbolos monocromos que siempre funcionan, o imágenes propias con acabado AAA". El emoji en color es la tercera opción, y solo para decoración prescindible.

3. **Centraliza los glifos igual que los iconos.** Aunque el usuario elija emojis, no escribas el carácter suelto por todo el código. Crea un módulo `Glyphs` con la misma forma que `Icons`, para que cambiar a imágenes más adelante sea una sola edición y no una cacería por 40 archivos.

```lua
-- Configuration/Glyphs
-- Solo símbolos de Nivel A: se tiñen con el color del tema y no dependen
-- de que el sistema del jugador aporte una fuente de emoji.
local Glyphs = {
    Close = "✕",
    Check = "✓",
    Star = "★",
    ChevronDown = "▾",
    ChevronRight = "▸",
    Bullet = "•",
    Settings = "⚙",
}

return Glyphs
```

4. **Para un símbolo de moneda, usa texto o imagen, nunca emoji.** Lo más robusto es el nombre corto de tu moneda ("1200 cr", "1200 monedas") o un `ImageLabel` con tu propio icono. Es también mejor diseño: una moneda propia refuerza la identidad del juego.

5. **Si un icono es imprescindible y aún no hay asset**, deja `rbxassetid://0` con el relleno de placeholder visible (ver `Icons.lua`). Un cuadro tenue y deliberado se lee como "pendiente"; un tofu se lee como "roto".

## Cómo comprobarlo

En Studio, un solo `TextLabel` de prueba con todos los glifos que piensas usar, y revisarlo en:

1. La ventana de Studio (Windows o macOS, según tu equipo).
2. **Test → Device**, con un perfil de teléfono.
3. Si es posible, un teléfono real. Es el único sitio donde se ve el respaldo real del sistema móvil.

Si un glifo falla en cualquiera de los tres, no entra en la interfaz.
