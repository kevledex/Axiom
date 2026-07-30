# Modo auditoría

Leer solo cuando el usuario pide analizar, revisar, criticar o mejorar una UI existente en vez de crear una nueva. Frases típicas: "analiza esta interfaz", "¿por qué se ve mal?", "revisa mi UI", "dime qué mejorar", "esto se ve genérico".

## Qué necesitas para auditar

Pide lo que falte, en un solo mensaje:

- Una captura de la interfaz (lo más útil de todo).
- El código que la genera, o el árbol de instancias.
- En qué dispositivos se juega principalmente.

Si solo tienes una de las tres cosas, audita con eso y di explícitamente qué no pudiste evaluar. No inventes problemas que no puedes ver: si no tienes captura, no opines sobre la paleta.

## Cómo evaluar

Seis dimensiones, cada una de 1 a 10. Sé honesto: un 7 de cortesía a una UI de 4 no ayuda a nadie, y un 3 sin explicación desmotiva. Puntúa y justifica.

**1. Jerarquía visual** — ¿Se distingue en medio segundo qué es lo importante? ¿Hay un solo elemento dominante? ¿O todo tiene el mismo tamaño, color y peso?

**2. Sistema de diseño** — ¿Los colores, espaciados y radios son consistentes? ¿Hay un `Theme` central o valores mágicos repetidos por todo el código? ¿Cuántos tonos distintos de gris hay sin motivo?

**3. Espaciado y densidad** — ¿Hay padding en los paneles? ¿El espacio agrupa lo relacionado? ¿Está todo pegado al borde o hay huecos enormes sin razón?

**4. Responsividad** — ¿Usa Scale con constraints o offsets fijos? ¿El layout cambia en pantalla estrecha o solo se encoge? ¿Los objetivos táctiles llegan a 44 px?

**5. Estados y feedback** — ¿Hay hover, presionado, seleccionado, deshabilitado? ¿Existen los estados de vacío, cargando y error? ¿Cada toque responde en menos de 150 ms?

**6. Originalidad** — ¿Se reconocería este juego por su UI? ¿O es el frame gris con botón azul de cualquier tutorial?

Además, revisa el código si lo tienes: valores mágicos, bloques duplicados que deberían ser componentes, `Position` en hijos de layouts, `CanvasSize` fijo, eventos sin desconectar, lógica de UI en el servidor.

## Formato del informe

Usa esta estructura exacta:

```
## Puntuación

Jerarquía visual      6/10
Sistema de diseño     4/10
Espaciado             5/10
Responsividad         3/10
Estados y feedback    2/10
Originalidad          4/10
                      ─────
Global                4/10

## Lo que ya funciona

- (dos o tres cosas reales, no halagos de relleno)

## Problemas, por impacto

### 1. [El más grave]
Qué pasa: ...
Por qué importa: ...
Cómo se arregla: ...

### 2. ...

## Plan de mejora

Rápido (menos de 30 min):
- ...

Medio (1-2 h):
- ...

Rediseño (si quieres subir de nivel):
- ...
```

## Reglas del informe

- **Ordena por impacto, no por facilidad.** Si la UI no funciona en móvil, ese es el problema número uno aunque cueste más arreglarlo que cambiar un color.
- **Sé concreto.** "Falta jerarquía" no sirve. "El título del panel y las etiquetas de los datos usan los dos 16 px en Regular, así que el ojo no sabe dónde empezar; sube el título a 24 Bold" sí sirve.
- **Empieza por lo que funciona.** Casi siempre hay algo bien hecho, y reconocerlo hace que el resto del informe se escuche.
- **Máximo cinco problemas.** Una lista de veinte se ignora entera.
- **Ofrece el paso siguiente.** Termina preguntando si quiere que apliques las mejoras rápidas o que rediseñe la interfaz completa con el flujo normal de la skill (Fases 0 a 5).

## Ejemplo de un problema bien escrito

> ### 1. La interfaz no se adapta a móvil
> **Qué pasa:** el panel principal usa `UDim2.new(0, 800, 0, 500)`, es decir 800×500 píxeles fijos. En un teléfono de 640 px de ancho, 160 px del panel quedan fuera de la pantalla, incluido el botón de cerrar.
> **Por qué importa:** la mayor parte del tráfico de Roblox es móvil. Ahora mismo esos jugadores no pueden cerrar el panel.
> **Cómo se arregla:** `Size = UDim2.fromScale(0.7, 0.75)` con `AnchorPoint = Vector2.new(0.5, 0.5)`, `Position = UDim2.fromScale(0.5, 0.5)` y un `UISizeConstraint` con `MinSize = Vector2.new(320, 400)` y `MaxSize = Vector2.new(1000, 700)`.
