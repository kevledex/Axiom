# Assets de imagen: qué decirle al usuario

Leer en la Fase 5, antes de entregar, siempre que el usuario haya elegido imágenes personalizadas.

El problema que resuelve este documento: se le entrega un `Icons.lua` con `rbxassetid://0` y se le dice "pega aquí tus IDs", pero nadie le dice **a qué tamaño exportar** ni **en qué formato**. Sube lo que tenga a mano, y el resultado es un icono borroso, uno deformado o uno de 1024×1024 para mostrarse a 24 px.

La entrega tiene que incluir una tabla con una fila por cada entrada de `Icons`.

Contenido:
1. La regla del tamaño
2. Formatos
3. Tabla de referencia por tipo de elemento
4. Proporción y deformación
5. Iconos monocromos y teñido
6. Imágenes de 9 secciones
7. Sprite sheets
8. Cómo se sube
9. Formato de la tabla de entrega

---

## 1. La regla del tamaño

**Exporta a 2× o 3× el tamaño máximo al que se va a ver, redondeado a una potencia de dos.** Ni más, ni menos.

- **Menos** produce una imagen borrosa en pantallas de alta densidad. Un icono de 48 px exportado a 48 px se ve blando en cualquier móvil moderno.
- **Más** no aporta nada visible y gasta memoria de textura. Y la memoria de textura es lo que se agota primero en los móviles de gama baja.

Potencias de dos: 32, 64, 128, 256, 512, 1024. No son obligatorias en Roblox, pero encajan mejor con cómo se gestionan las texturas y evitan redondeos raros al escalar.

**1024×1024 es el máximo de la plataforma**, no el valor recomendado por defecto. Es el tamaño correcto para arte grande —el fondo de un panel, la ilustración de un vehículo, un banner de evento— y es desperdicio para un icono de barra de herramientas. Un icono de 24 px no gana absolutamente nada por encima de 128×128.

Cálculo rápido:

```
tamaño de exportación = tamaño máximo en pantalla x 3, redondeado hacia arriba a potencia de dos
```

Un icono que se ve a 48 px en escritorio y a 56 px en móvil: 56 × 3 = 168 → **256×256**.

## 2. Formatos

| Formato | Cuándo |
|---|---|
| **PNG** | por defecto para todo lo que tenga transparencia: iconos, logos, marcos, sombras |
| **JPG** | solo para fotografías o arte grande sin transparencia; pesa menos |
| Otros | Roblox también acepta algunos formatos más, pero PNG y JPG cubren todos los casos reales |

Para iconos, **siempre PNG con canal alfa**. Un icono en JPG llega con fondo blanco o negro y no hay forma de arreglarlo después.

Exporta con el fondo **realmente transparente**, no blanco. Es un error frecuente al exportar desde algunas herramientas de diseño.

## 3. Tabla de referencia por tipo de elemento

Punto de partida; ajústalo al tamaño real de tu diseño.

| Elemento | Se ve a | Exportar a | Formato |
|---|---|---|---|
| Icono pequeño (dentro de un botón, chip) | 16–24 px | 64×64 | PNG |
| Icono estándar (navegación, acciones) | 32–48 px | 128×128 | PNG |
| Icono grande (tarjeta, categoría) | 64–96 px | 256×256 | PNG |
| Avatar o miniatura circular | 48–64 px | 128×128 | PNG |
| Ilustración de tarjeta | 200–300 px | 512×512 | PNG o JPG |
| Fondo de panel | pantalla completa | 1024×1024 | JPG si no hay transparencia |
| Arte destacado, banner de evento | pantalla completa | 1024×1024 | PNG o JPG |
| Marco de 9 secciones | variable | 128×128 | PNG |
| Sombra de 9 secciones | variable | 128×128 | PNG |
| Icono de moneda | 16–20 px | 64×64 | PNG, monocromo blanco |

## 4. Proporción y deformación

Si la imagen es cuadrada, el contenedor tiene que ser cuadrado. Roblox estira la imagen para llenar el `ImageLabel` y una proporción distinta la deforma sin avisar.

```lua
local proporcion = Instance.new("UIAspectRatioConstraint")
proporcion.AspectRatio = 1
proporcion.Parent = icono
```

Para imágenes no cuadradas (un banner 16:9), o pones el `AspectRatio` correspondiente (`16/9`), o usas `ScaleType`:

- `Stretch` (por defecto) — deforma para llenar. Casi nunca es lo que quieres.
- `Fit` — la imagen entera cabe, con espacio sobrante. **Es el valor correcto para contenido real**: fotos de vehículos u objetos, renders y logos. Recortar ahí corta justo lo que el jugador está evaluando.
- `Crop` — llena el contenedor recortando lo que sobra. Solo para fondos decorativos y para lo que se encuadra por convención, como avatares.
- `Slice` — 9 secciones, ver más abajo.

Si eliges `Fit`, va a sobrar espacio a los lados en algunas proporciones. Eso se resuelve con el color de fondo del contenedor o con un `UIAspectRatioConstraint` que le dé la proporción real de la imagen, **nunca cambiando a `Crop` para que "llene mejor"**: eso recorta información.

## 5. Iconos monocromos y teñido

La mejor decisión que puede tomar el usuario al preparar sus assets: **exportar los iconos en blanco puro sobre transparente**.

Con eso, un solo archivo sirve para todos los estados y todos los temas:

```lua
icono.Image = Icons.obtener("Search")
icono.ImageColor3 = Theme.Colors.TextSecondary   -- normal
icono.ImageColor3 = Theme.Colors.Primary          -- activo
icono.ImageTransparency = 0.5                     -- deshabilitado
```

Sin esto, hacen falta tres versiones de cada icono y cambiar el color de acento del juego obliga a reexportarlas todas.

Dilo explícitamente en la entrega: es el consejo que más trabajo le ahorra al usuario y casi nadie lo sabe de antemano.

Los iconos con color propio (una moneda dorada, una bandera, un logo) son la excepción y no se tiñen.

## 6. Imágenes de 9 secciones

Para marcos, bordes y sombras que tienen que estirarse a distintos tamaños sin deformar las esquinas.

```lua
marco.ScaleType = Enum.ScaleType.Slice
marco.SliceCenter = Rect.new(20, 20, 108, 108)
```

Los cuatro números son los píxeles donde empieza y acaba la zona estirable, en coordenadas de la imagen original. Para una imagen de 128×128 con esquinas de 20 px: `Rect.new(20, 20, 108, 108)`.

Lo que hay que decirle al usuario: exporta el marco con las esquinas dibujadas dentro de los primeros N píxeles, y dile qué valor de N usaste en el código.

## 7. Sprite sheets

Cuando hay muchos iconos pequeños, una sola imagen con todos en cuadrícula reduce las peticiones y las texturas en memoria.

```lua
icono.Image = "rbxassetid://TU_SPRITESHEET"
icono.ImageRectSize = Vector2.new(64, 64)
icono.ImageRectOffset = Vector2.new(128, 0)   -- tercer icono de la primera fila
```

Merece la pena a partir de unos 10–12 iconos. Por debajo, la comodidad de tener archivos sueltos gana.

Si lo usas, la entrega tiene que incluir la rejilla: tamaño de celda y qué icono está en cada posición.

## 8. Cómo se sube

En el sitio web de Roblox: **Create → Manage my Assets → Images → Add Image**. También desde Studio, con el Asset Manager.

Tres cosas que conviene advertir:

- Cada imagen pasa por **moderación** antes de estar disponible. Puede tardar desde segundos hasta bastante más, y hasta que se aprueba se ve en blanco. No es un fallo del código.
- El ID que aparece tras subirla es el que va en `Icons.lua`, con el prefijo `rbxassetid://`.
- Solo puedes usar assets **de tu propia cuenta** o los que tengan permisos para ello. Un ID copiado de otro juego puede dejar de funcionar en cualquier momento.

## 9. Formato de la tabla de entrega

Una fila por cada entrada real de `Icons.lua` del proyecto, no una tabla genérica:

```
| Icono      | Resolución | Formato | Notas                                          |
|------------|------------|---------|------------------------------------------------|
| Bus        | 256×256    | PNG     | cuadrado, se ve a 64 px en la tarjeta          |
| Search     | 128×128    | PNG     | monocromo blanco, se tiñe desde Theme          |
| Settings   | 128×128    | PNG     | monocromo blanco                                |
| Close      | 64×64      | PNG     | monocromo blanco, se ve a 20 px                |
| Coin       | 64×64      | PNG     | color propio, NO se tiñe                       |
| Shadow     | 128×128    | PNG     | 9 secciones, SliceCenter Rect.new(10,10,118,118) |
```

Y una línea de cierre con lo esencial: exportar en PNG con transparencia real, los monocromos en blanco puro, y que la moderación de Roblox puede tardar en aprobarlos.
