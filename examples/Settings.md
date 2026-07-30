# Ejemplo: configuración

**Petición típica:** "Necesito un menú de ajustes."

## Lo que define un buen menú de ajustes

Es la UI menos glamorosa y la que más delata a un desarrollador con criterio. Aquí lo que importa es la legibilidad, la agrupación y que los cambios se apliquen y se recuerden.

Tres reglas:

1. **Agrupa por secciones** con encabezado. Una lista plana de doce controles es imposible de escanear.
2. **Aplica al instante.** Nada de un botón "Guardar" al final; el jugador debe ver el efecto al mover el control.
3. **Persiste.** Un ajuste que se olvida al reconectar es peor que no tenerlo. Guarda en `DataStore` (o en atributos del jugador para lo que sea de sesión).

## Estructura

```
SettingsUI (ScreenGui)
├── Main
│   ├── Header (Title "Ajustes" + CloseButton)
│   ├── Sections (ScrollingFrame + UIListLayout vertical)
│   │   ├── SectionHeader "Audio"
│   │   ├── SettingRow (Música)          -> Slider
│   │   ├── SettingRow (Efectos)         -> Slider
│   │   ├── SectionHeader "Gráficos"
│   │   ├── SettingRow (Calidad)         -> Dropdown
│   │   ├── SettingRow (Sombras)         -> Toggle
│   │   ├── SectionHeader "Controles"
│   │   ├── SettingRow (Sensibilidad)    -> Slider
│   │   └── SettingRow (Vibración)       -> Toggle
│   └── Footer (Restablecer valores por defecto)
├── Configuration (Theme, Icons)
└── Controllers (SettingsController)
```

## SettingRow

Un único componente reutilizable para todas las filas, con el control como parámetro:

```
SettingRow (Frame, altura 52 en amplio / 60 en compacto)
├── TextBlock
│   ├── Label ("Volumen de música", 15 Medium)
│   └── Hint ("Afecta solo a la música de fondo", 12, TextSecondary)
└── Control (Toggle | Slider | Dropdown, alineado a la derecha)
```

La pista de texto secundaria es opcional pero convierte un ajuste críptico en uno comprensible. Úsala en todo lo que no se explique por su nombre.

## Los tres controles

**Toggle** — pista redondeada (`UICorner` píldora) con un círculo que se desplaza 0.15 s. El color de la pista cambia a acento al activarse. Área tocable mínima 44×44 aunque el interruptor visible mida 40×22.

**Slider** — riel de 4 px, relleno de acento, agarre circular de 20 px con un área tocable de 44 px. Escucha `InputBegan` / `InputChanged` / `InputEnded` en el riel para que funcione igual con ratón y con dedo, y muestra el valor numérico al lado; un slider sin número obliga a adivinar.

**Dropdown** — botón que abre una lista debajo con `ZIndex` alto y un `ScreenGui`-wide overlay invisible para cerrarlo al tocar fuera. En compacto, mejor un modal de opciones a pantalla casi completa que una lista diminuta.

## Responsive

| | Amplio | Compacto |
|---|---|---|
| Fila | etiqueta izquierda, control derecha | etiqueta arriba, control debajo a lo ancho |
| Altura de fila | 52 | 60 |
| Slider | 180 px de ancho | ancho completo |
| Dropdown | lista desplegable | modal de opciones |

Es el caso más claro de "rediseñar, no encoger": una fila de dos columnas en 380 px deja la etiqueta cortada y el control apretado. Apilar resuelve.

## Estados

- **Deshabilitado**: un ajuste no disponible (por ejemplo, vibración en PC) se muestra atenuado con la razón en la pista de texto, no se oculta. Ocultarlo hace que el jugador lo busque.
- **Guardando**: si la persistencia tarda, un punto de acento junto a la fila; nunca bloquees el menú entero.
- **Restablecer**: siempre con confirmación. Es una acción destructiva.

## Detalle final

Al cerrar los ajustes, aplica y guarda sin preguntar. El botón de cerrar de un menú de ajustes nunca debería abrir un diálogo de "¿guardar cambios?": eso es una fricción heredada del software de escritorio que en un juego no tiene sentido.
