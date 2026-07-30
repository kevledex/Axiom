# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y versionado según [SemVer](https://semver.org/lang/es/).

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
