# Axiom

Skill para [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) — UI design system y arquitecto de interfaces para Roblox Studio. Convierte a Claude en un equipo completo: diseñador de producto, diseñador visual, programador Luau y arquitecto de sistemas de interfaz.

No es una guía de estilo. Es un flujo de trabajo: Claude pregunta lo necesario, define una dirección visual, diseña la arquitectura, escribe el código Luau y genera un **instalador para la Command Bar** que crea la interfaz completa dentro de tu proyecto en segundos.

## Qué hace distinto

- **Diseño antes de código.** Ninguna línea de Luau se escribe hasta que existan paleta, jerarquía tipográfica y plan responsive.
- **Sistema, no piezas.** `Theme` central, componentes reutilizables, cero valores mágicos repetidos.
- **Responsive de verdad.** La versión móvil se rediseña, no se encoge. Breakpoints sobre `AbsoluteSize`, `UISizeConstraint`, objetivos táctiles de 44 px.
- **Los nueve estados.** Normal, hover, presionado, seleccionado, deshabilitado, cargando, vacío, error y éxito. No solo el normal.
- **Instalador seguro.** Comprueba si la UI ya existe, avisa y **no borra nada**. Registra la instalación en el historial de Studio para poder deshacerla con `Ctrl+Z`.
- **Sin asset IDs inventados.** Los iconos pendientes quedan como `rbxassetid://0` en un módulo editable.
- **Modo auditoría.** Analiza una UI existente y devuelve puntuación por dimensiones, problemas ordenados por impacto y un plan de mejora.

## Instalación

### Opción 1 — script (recomendada)

```bash
git clone https://github.com/kevledex/Axiom.git
cd axiom
./scripts/install.sh
```

O en una línea, sin clonar a mano:

```bash
curl -fsSL https://raw.githubusercontent.com/kevledex/Axiom/main/scripts/install.sh | bash
```

### Opción 2 — clonar directamente en la carpeta de skills

Para tu usuario, disponible en todos los proyectos:

```bash
git clone https://github.com/kevledex/Axiom.git ~/.claude/skills/axiom
```

Solo para un proyecto:

```bash
git clone https://github.com/kevledex/Axiom.git .claude/skills/axiom
```

Claude Code busca las skills en `~/.claude/skills/` (personales) y `.claude/skills/` (del proyecto). La ruta final tiene que ser `.../skills/axiom/SKILL.md`, sin una carpeta extra en medio. Abre una sesión nueva para que la detecte.

### Actualizar

```bash
cd ~/.claude/skills/axiom && git pull
```

### Desinstalar

```bash
rm -rf ~/.claude/skills/axiom
```

## Cómo se usa

Solo habla normal. La skill se activa sola con peticiones como:

- "Crea un selector premium de buses para mi juego"
- "Necesito una tienda con saldo y confirmación de compra"
- "Hazme un inventario que funcione bien en móvil"
- "Un velocímetro para mi juego de conducción"
- "Esta UI se ve genérica, mejórala"

También se puede invocar por nombre:

| Comando | Qué hace |
|---|---|
| `/axiom` | Flujo completo de creación |
| `/axiom audit` | Audita una interfaz que ya existe, sin preguntas de configuración |
| `/axiom <lo que quieras>` | Interpreta la intención y elige entre crear o auditar |

### Qué te va a preguntar

Dos rondas cortas, y solo lo que de verdad cambia el diseño:

1. **Propósito** — qué tiene que conseguir el jugador con la interfaz, y si es un panel que se abre o algo permanente en pantalla.
2. **Técnica** — dónde guardarla, cómo llamarla, y cómo manejar los iconos.

Más preguntas condicionales solo cuando aplican (cuántos elementos puede mostrar la lista, si hace falta búsqueda, si se juega con mando, si hay compras). Si respondes "elige tú", aplica los valores por defecto y arranca sin insistir.

Al final te devuelve un script para pegar en la Command Bar de Roblox Studio.

### Modo auditoría

`/axiom audit` trabaja sobre el código o el árbol de instancias de una UI que ya tienes. Devuelve puntuación en seis dimensiones (jerarquía, sistema de diseño, espaciado, responsividad, estados y originalidad), los problemas ordenados por impacto con el arreglo concreto de cada uno, y un plan de mejora dividido por esfuerzo. No necesita capturas.

## Instalar la interfaz generada

1. Abre tu proyecto en Roblox Studio.
2. Pestaña **View** → **Command Bar**.
3. Pega el script completo.
4. Enter.

Verás en la Output algo como `✅ BusSelectorUI instalada en StarterGui`, y el `ScreenGui` quedará seleccionado en el Explorer.

Si la UI ya existe, el instalador avisa y no toca nada.

## Estructura del repositorio

```
axiom/
├── SKILL.md                  Flujo principal: las 6 fases y el checklist
├── README.md
├── references/
│   ├── premium-design.md     Dirección visual, paletas, tipografía, antipatrones
│   ├── genre-patterns.md     Patrones por género y números grandes
│   ├── roblox-gui-patterns.md Equivalencias CSS, layouts, constraints, errores
│   ├── responsive-ui.md      Scale vs Offset, breakpoints, rediseño móvil
│   ├── animations.md         TweenService, duraciones, easing, patrones
│   ├── states.md             Los nueve estados de interfaz
│   ├── command-bar-installer.md  Cómo generar un instalador que funcione
│   ├── performance.md        Pooling, virtualización, presupuesto de instancias
│   ├── sound-design.md       Los siete sonidos de UI, volúmenes, throttle
│   ├── hud-vs-menu.md        Reglas propias de un HUD permanente
│   ├── known-pitfalls.md     Catálogo de fallos con causa y arreglo
│   ├── emoji-safety.md       Qué glifos renderizan de verdad en Roblox
│   ├── accessibility.md      Contraste, tamaños táctiles, gamepad
│   └── audit-mode.md         Formato del informe de auditoría
├── templates/
│   ├── Theme.lua             Sistema de diseño central
│   ├── Icons.lua             IDs editables con detección de placeholder
│   ├── Sounds.lua            SoundGroup, throttle y silencio
│   ├── Component.lua         Botón completo con variantes y estados
│   └── Installer.lua         Instalador funcional de referencia
├── examples/
│   ├── BusSelector.md        Flujo completo, de la pregunta a la entrega
│   ├── Shop.md               Tienda: saldo, confirmación, estados de compra
│   ├── Inventory.md          Rejilla, rareza, rendimiento en móvil
│   └── Settings.md           Toggles, sliders, dropdowns, persistencia
└── scripts/
    └── install.sh
```

Las plantillas `.lua` tienen la sintaxis validada. `Installer.lua` es un instalador real y funcional: puedes pegarlo en la Command Bar tal cual para ver el resultado antes de pedir el tuyo.

## Requisitos

- Claude Code.
- Roblox Studio (la Command Bar solo existe en Studio; el instalador necesita modo edición para escribir el código de los módulos).
- `git` para instalar.

## Notas

Los nombres de instancias, módulos y propiedades van en inglés PascalCase porque es el estándar de Roblox y encaja con cualquier tutorial o plugin. Las variables locales y los comentarios van en español.

## Licencia

MIT. Ver `LICENSE`.
