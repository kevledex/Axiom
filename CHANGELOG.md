# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y versionado según [SemVer](https://semver.org/lang/es/).

## [2.2.0] — 2026-08-05

Correcciones surgidas de dos proyectos reales: el pulido del selector de autobuses y la construcción de una pantalla de carga completa.

### Corregido

- **`ScaleType.Crop` aplicado a contenido real.** Las fotos y los logos se entregaban recortados. Ahora `Fit` es el valor para contenido que el jugador tiene que identificar, y `Crop` queda reservado a fondos decorativos y avatares, con una tabla por tipo de imagen.
- **Barras de proporción sin máximo.** Las barras de estadísticas se dimensionaban a ojo y salían casi llenas sin importar el dato. El máximo pasa a ser obligatorio.
- **Elementos añadidos que rompían el patrón del archivo.** Los botones creados fuera de la estructura original usaban texto plano mientras el resto usaba iconos. Añadida la regla de replicar el patrón de un elemento equivalente del mismo archivo antes de escribir nada.
- **Documentación incorrecta de `UIAspectRatioConstraint`.** `DominantAxis` solo aplica con `AspectType = ScaleWithParentSize`; con el valor por defecto el motor usa ambas dimensiones y toma la menor.
- **Detección de dispositivo táctil por ancho de pantalla.** No funciona: una tablet en horizontal reporta más ancho que un portátil pequeño. La señal correcta es `UserInputService.TouchEnabled`, y el ancho queda solo para decidir el layout.

### Añadido

- `references/overlays.md`: instalación apagada para no tapar el viewport de Studio, cierre con `CanvasGroup` y `GroupTransparency`, crossfade de dos capas sin fondo opaco propio, precarga con diagnóstico fiable y progreso real frente a simulado.
- `references/security.md`: validación obligatoria en servidor, reglas para remotos, entradas de texto con lista blanca y filtrado de Roblox, limitación de frecuencia y qué no enviar nunca al cliente.
- `templates/ProgressBar.lua`: componente que exige un máximo explícito al crearse y calcula siempre `valor / maximo` acotado.
- Regla de alcance de un arreglo: al corregir un fallo se toca solo lo que ese fallo involucra, para no introducir regresiones al ampliar el arreglo de más.
- Overlay a pantalla completa como tercer tipo de interfaz en la pregunta de propósito, junto a panel y HUD.
- Once entradas nuevas en el catálogo de errores conocidos, con dos secciones nuevas para componentes y datos, y para overlays y transiciones.

### Cambiado

- Checklist final agrupado por áreas para poder repasarlo por bloques.

## [2.1.0] — 2026-07-29

Correcciones surgidas de la primera prueba de la versión 2.

### Corregido

- **La skill no preguntaba por los sonidos.** La pregunta era condicional y su redacción ("por defecto sí, en volumen bajo") daba permiso para asumir en lugar de preguntar. Convertida en pregunta fija de la ronda técnica.
- **`IgnoreGuiInset` nunca se decidía.** La propiedad solo aparecía en las referencias y en la plantilla, nunca en `SKILL.md`, que es el único archivo que se carga siempre. Convertida en pregunta explícita con la explicación de qué hace y una recomendación por tipo de interfaz.

### Añadido

- `references/image-assets.md` con resoluciones por tipo de elemento, formatos, proporción, teñido de iconos monocromos, imágenes de nueve secciones, sprite sheets y proceso de subida.
- Obligación en la Fase 5 de entregar una tabla de especificaciones de assets, con una fila por cada icono del proyecto.
- Banderas `IGNORAR_INSET` y `MARGEN_SUPERIOR` en el instalador de referencia, con el margen superior aplicado automáticamente cuando el inset se ignora.

## [2.0.0] — 2026-07-29

Segunda versión. Corrección de los fallos encontrados en la primera prueba real, y ampliación de la skill más allá de los menús: HUD, widgets y superficies del mundo 3D.

### Corregido

- **Desborde del contenedor principal.** El alto del cuerpo se calculaba a mano (`UDim2.new(1, 0, 1, -160)`) y el número no cuadraba con la suma de las filas, sus separaciones y el padding: sobraban 68 px. El contenido desbordaba y tapaba la fila de filtros en pantallas de poca altura. Sustituido por reparto con `UIFlexItem`, con respaldo medido mediante `AbsoluteSize` para versiones de Studio sin esa clase.
- **Glifos no soportados.** Los emoji en color aparecían como cuadro vacío en el dispositivo del jugador aunque se vieran bien en Studio. Sustituidos por símbolos monocromos en los elementos críticos.
- **Recorte de la fila de filtros.** Los chips se cortaban cuando no cabían en una línea. Ahora la fila crece con `AutomaticSize.Y` y `Wraps`.
- **Desborde invisible.** Activado `ClipsDescendants` en el contenedor raíz, para que un error de tamaño se vea recortado en lugar de pintarse sobre las filas hermanas.
- **Filtros innecesarios.** La skill añadía búsqueda y filtros por defecto. Ahora solo se proponen por encima de unos doce elementos.

### Añadido

- Modos de invocación `/axiom` y `/axiom audit`, con regla de detección de intención entre creación y auditoría.
- Ronda de preguntas de propósito en la Fase 0: qué debe conseguir el jugador y si es panel o HUD permanente. El concepto visual de la Fase 1 deriva de esa respuesta.
- Preguntas condicionales con umbrales explícitos, y sección sobre qué no preguntar cuando la respuesta ya es deducible.
- Reutilización de instancias en listas: lote fijo en lugar de creación por dato, con aviso explícito al superar el lote.
- Módulo `Configuration/Data` para separar los datos del código de la interfaz.
- Sistema de sonido: `templates/Sounds.lua` con `SoundGroup` único, reutilización de instancias, throttle de 60 ms y omisión silenciosa cuando el ID no está configurado.
- Módulo `Glyphs` con símbolos monocromos.
- Siete ejemplos nuevos: `Speedometer`, `HealthBar`, `Minimap`, `Notifications`, `Leaderboard`, `RadialMenu` y `DamageNumbers`.
- Cinco referencias nuevas: `performance.md`, `emoji-safety.md`, `sound-design.md`, `known-pitfalls.md`, `hud-vs-menu.md` y `genre-patterns.md`.
- Guía de instalación por sistema operativo (`INSTALL.md`) para Windows, macOS y Linux.
- Script de instalación para Windows (`scripts/install.ps1`).
- Guía de contribución (`CONTRIBUTING.md`).

### Cambiado

- La `description` de la skill incluye términos de HUD y widgets, para que se active con pedidos que no son menús ("velocímetro", "barra de vida", "números de daño").
- El modo auditoría usa el código como fuente principal en lugar de las capturas, y exige citar la causa concreta del catálogo de errores en lugar de dar diagnósticos genéricos.
- Los eventos se conectan una sola vez por instancia, nunca dentro de una función de refresco.
- Checklist final ampliado de 11 a 20 puntos.
- Script de instalación apuntando al repositorio real en lugar de un placeholder.

## [1.0.0] — 2026-07-29

Primera versión.

### Añadido

- Flujo de seis fases: preguntas, dirección visual, arquitectura, código Luau, instalador y entrega.
- Generación de instaladores para la Command Bar de Roblox Studio, con comprobación de existencia previa, registro en el historial de Studio y sin borrado automático.
- Sistema de diseño central (`Theme.lua`) y módulo de iconos con IDs editables (`Icons.lua`).
- Plantilla de componente reutilizable con variantes y estados (`Component.lua`).
- Instalador funcional de referencia (`Installer.lua`).
- Referencias de diseño premium, patrones de GUI de Roblox, diseño responsive, animaciones, estados, instalador de Command Bar, accesibilidad y modo auditoría.
- Cuatro ejemplos de panel: `BusSelector`, `Shop`, `Inventory` y `Settings`.
- Script de instalación para sistemas Unix (`scripts/install.sh`).
