# Diseño premium para Roblox

Leer en la Fase 1, antes de escribir código.

Contenido:
1. Qué separa una UI AAA de una UI de tutorial
2. Jerarquía visual
3. Paleta: cómo construirla
4. Tipografía en Roblox
5. Espaciado y ritmo
6. Profundidad sin exagerar
7. Antipatrones que delatan una UI genérica
8. Cuatro direcciones visuales de ejemplo

---

## 1. Qué separa una UI AAA de una UI de tutorial

No es la cantidad de efectos. Una UI de Valorant o Clash Royale usa menos brillo del que la gente cree; lo que tiene es:

- **Jerarquía**: en medio segundo sabes dónde mirar.
- **Consistencia**: el mismo espaciado y el mismo radio en toda la pantalla.
- **Densidad correcta**: aire alrededor de lo importante, no relleno vacío.
- **Feedback**: cada toque responde en menos de un cuarto de segundo.
- **Identidad**: se reconoce el juego por su UI aunque le borres el logo.

Las UIs genéricas fallan porque todos los elementos tienen el mismo peso visual. Todo mide lo mismo, todo pesa lo mismo, todo grita lo mismo.

## 2. Jerarquía visual

Cada pantalla necesita exactamente **un** elemento dominante. Después uno o dos secundarios. Después el resto.

Herramientas para crear jerarquía, en orden de fuerza:

1. **Tamaño** — el título mide el doble que la etiqueta, no un 10 % más.
2. **Peso tipográfico** — Bold contra Medium contra Regular.
3. **Color** — el acento se reserva para la acción principal. Uno por pantalla.
4. **Contraste con el fondo** — la superficie elevada es más clara que el fondo, la seleccionada más aún.
5. **Espacio** — lo importante tiene aire alrededor.
6. **Posición** — arriba a la izquierda y el centro se leen primero.

Prueba rápida: entrecierra los ojos mirando tu diseño. Si todo se convierte en una mancha uniforme, no hay jerarquía.

## 3. Paleta: cómo construirla

Estructura mínima de seis roles. Nada de "y aquí pongo otro azul distinto".

| Rol | Uso | Rango típico oscuro |
|---|---|---|
| `Background` | el lienzo, detrás de todo | RGB 12–22 |
| `Surface` | paneles, tarjetas | RGB 24–34 |
| `SurfaceElevated` | tarjeta seleccionada, modal, dropdown | RGB 38–48 |
| `Primary` | acento: acción principal, selección, progreso | saturado |
| `TextPrimary` | títulos y datos importantes | RGB 235–255 |
| `TextSecondary` | etiquetas, descripciones, metadatos | RGB 140–175 |

Más `Success`, `Warning` y `Danger` solo si la UI los necesita.

Reglas prácticas:

- **No uses negro puro ni blanco puro.** `Color3.fromRGB(15, 16, 20)` respira; `(0,0,0)` se ve muerto y aplasta las sombras.
- **Tiñe los grises.** Un fondo con un poco de azul o de cálido (`(18, 19, 24)` en vez de `(18, 18, 18)`) da identidad de inmediato.
- **El acento aparece poco.** Si el 40 % de la pantalla es del color de acento, ya no es un acento.
- Para tarjetas usa `Surface` y para la seleccionada `SurfaceElevated` + borde de acento con `UIStroke`. Cambiar el color entero de la tarjeta a acento suele ser demasiado.

Las paletas claras funcionan, pero necesitan más cuidado: la separación entre superficies es más sutil y hace falta apoyarse en `UIStroke` fino y en sombras suaves.

## 4. Tipografía en Roblox

Usa `FontFace` en lugar de la propiedad `Font` heredada, porque te da pesos reales de la misma familia:

```lua
etiqueta.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
```

Familias sólidas y neutras para UI de juego: `GothamSSm`, `Montserrat`, `SourceSansPro`, `Inter`, `Arimo`. Para juegos con más carácter: `FredokaOne`, `LuckiestGuy`, `Bangers` — pero solo en títulos, nunca en cuerpo de texto.

Escala tipográfica, guardada en `Theme.Text`:

| Rol | Tamaño base (PC) | Peso |
|---|---|---|
| Título de pantalla | 28–34 | Bold |
| Título de sección | 20–22 | SemiBold |
| Cuerpo | 15–16 | Regular / Medium |
| Etiqueta / metadato | 12–13 | Medium |

Detalles que importan:

- `TextScaled = true` sirve para que el texto se ajuste al contenedor, pero úsalo **con** `UITextSizeConstraint` (`MinTextSize`, `MaxTextSize`). Sin límites, en móvil aparecen textos de 8 px ilegibles o títulos gigantes.
- Máximo dos familias por interfaz. Tres ya es ruido.
- Los números que cambian (precio, velocidad, cantidad) merecen peso Bold: son datos, no decoración.
- `RichText = true` permite resaltar una palabra sin partir el label en tres.

## 5. Espaciado y ritmo

Elige una unidad base — 4 u 8 — y usa solo múltiplos. Escala recomendada:

```
XSmall = 4    Small = 8    Medium = 16    Large = 24    XLarge = 32
```

- Elementos relacionados: separación pequeña. Grupos distintos: separación grande. Es la ley de proximidad: el espacio agrupa mejor que las líneas divisorias.
- El padding interno de un panel nunca debe ser menor que el espacio entre sus hijos. Si lo es, el contenido parece pegado al borde.
- Un panel con `UIPadding` de 16–24 se lee como diseñado. Con padding 0, como generado.
- La separación no se hace moviendo posiciones a mano: `UIListLayout.Padding` + `UIPadding`.

## 6. Profundidad sin exagerar

Roblox no tiene `box-shadow`. Cómo se resuelve:

- **Bordes finos**: `UIStroke` con `Thickness = 1` y `Transparency = 0.7` separa superficies con elegancia.
- **Sombra por imagen**: un `ImageLabel` con la imagen de sombra estándar de Roblox (`rbxassetid://1316045217`, `ScaleType = Slice`, `SliceCenter = Rect.new(10,10,118,118)`), `ZIndex` por debajo del panel, `ImageTransparency` alta.
- **Gradientes sutiles**: `UIGradient` de arriba oscuro a abajo un poco más claro dentro de una tarjeta añade volumen. Mantén la diferencia pequeña.
- **Escala en hover/press**: `UIScale` de 1 → 1.03 hace que un botón se sienta físico. Más de 1.06 se siente de juguete.
- **Transparencia de grupo**: envuelve un panel en `CanvasGroup` y anima `GroupTransparency` para desvanecer todo el conjunto de una vez (el equivalente a `opacity` en CSS).

Radios: elige uno de estos tres registros y sé coherente.

- Casi recto (`UICorner` 4–6): técnico, militar, competitivo.
- Medio (8–12): moderno neutro, funciona casi siempre.
- Muy redondo (16–24 o pill): casual, infantil, arcade.

Mezclar radios sin criterio en la misma pantalla es uno de los errores más visibles.

## 7. Antipatrones que delatan una UI genérica

Evita esto siempre:

- Frame gris `(128,128,128)` o `(200,200,200)` sin tocar.
- El botón azul por defecto de Roblox.
- `UICorner` de 0.5 escalar (píldora total) en absolutamente todo.
- Todos los botones del mismo tamaño, color y peso.
- Texto blanco puro sobre fondo negro puro.
- Rellenar cada hueco con más texto o más iconos.
- Neón por todos lados: brillo en cada borde, gradientes saturados en cada tarjeta.
- Sombras negras duras y grandes (el efecto "recortado con tijeras").
- Un solo tamaño de fuente para toda la pantalla.
- Botón "X" de cerrar de 20×20 px en móvil.
- Animaciones de 1 segundo para abrir un panel.
- Copiar el layout exacto de un tutorial de YouTube: header + tres tarjetas + botón azul abajo.

## 8. Cuatro direcciones visuales de ejemplo

Para patrones ligados a un género concreto (simulador, tycoon, roleplay, obby, tower defense, combate, horror, conducción), ver `genre-patterns.md`.

Sirven de punto de partida; adáptalas al juego, no las copies literalmente.

**Industrial / transporte / simulador**
Fondo `(16, 18, 21)`, superficies `(26, 29, 34)`, acento ámbar `(255, 176, 32)`, radio 6, tipografía `GothamSSm`, muchos datos tabulados, separadores finos.

**Arcade / casual / obby**
Fondo `(28, 22, 46)`, superficies `(44, 36, 70)`, acento verde lima `(140, 230, 80)`, radio 18, `FredokaOne` en títulos, tarjetas con gradiente y escala generosa en hover.

**Lujoso / tienda premium / battle pass**
Fondo `(14, 14, 16)`, superficies `(24, 24, 28)`, acento dorado `(212, 175, 100)`, radio 4, `Montserrat`, mucho espacio negativo, bordes finos dorados, animaciones lentas y suaves.

**Militar / táctico / shooter**
Fondo `(18, 20, 18)`, superficies `(28, 32, 28)`, acento cian `(80, 220, 200)`, radio 2, `Inter` o `SourceSansPro`, etiquetas en mayúsculas con `LetterSpacing`, líneas de esquina en vez de bordes completos.
