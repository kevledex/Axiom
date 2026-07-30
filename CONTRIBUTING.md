# Contribuir a Axiom

Las aportaciones son bienvenidas, sobre todo las que vienen de haber usado la skill en un proyecto real y haber encontrado algo que no funciona.

## Lo más útil que puedes aportar

En orden de valor:

1. **Un fallo encontrado usándola.** Si la skill generó una interfaz con un problema, abre un issue con: el pedido que hiciste, qué salió mal y, si puedes, el fragmento de código problemático. Los fallos reales son lo que más mejora la skill; el del desborde del contenedor principal salió justo así.
2. **Una entrada nueva para `references/known-pitfalls.md`.** Mismo formato que las demás: síntoma, causa y arreglo.
3. **Un ejemplo nuevo** en `examples/` para un tipo de interfaz que no esté cubierto.
4. **Una corrección técnica.** Si algo de las referencias es inexacto para la versión actual de Roblox Studio, dilo con la propiedad o API concreta.

## Cómo está organizado el repositorio

| Carpeta | Qué contiene | Cuándo se lee |
|---|---|---|
| `SKILL.md` | el flujo de fases y el checklist | siempre que la skill se activa |
| `references/` | documentación técnica y de diseño | solo la que hace falta en cada fase |
| `templates/` | código Luau para adaptar | Fases 3 y 4 |
| `examples/` | flujos resueltos por tipo de interfaz | cuando el pedido coincide con uno |
| `scripts/` | instaladores de la skill | fuera del uso normal |

El `SKILL.md` se carga entero cada vez que la skill se activa, así que **tiene que quedarse corto**: si algo se puede mover a una referencia, se mueve. Las referencias solo se leen cuando hacen falta, y ahí sí puede haber detalle.

## Estilo

- **Todo en español**, salvo los nombres de instancias, propiedades y módulos de Roblox, que van en inglés PascalCase (`DetailsPanel`, `Theme.Colors.Primary`) porque es el estándar de la plataforma.
- **Variables locales y comentarios en español** (`local tarjetaSeleccionada`, `-- Anima la entrada del panel`).
- **Sin punto y coma** al final de línea en Lua.
- **Código simple antes que código listo.** Sin metatablas rebuscadas ni abstracciones de tres niveles. Si un bucle claro resuelve, no metas una fábrica genérica.
- **Explica el por qué, no solo el qué.** Una regla sin razón se ignora o se aplica mal. Casi todas las secciones de este repositorio dicen qué problema resuelve lo que proponen.
- **Nada de IDs de asset o de audio inventados.** Los pendientes van como `rbxassetid://0` con detección de placeholder.

## Antes de abrir un pull request

Si tocas cualquier archivo `.lua`, comprueba la sintaxis. No hace falta Roblox Studio para eso:

```bash
luac -p templates/Installer.lua
```

Y si el archivo contiene módulos embebidos como cadenas largas (`[==[ ... ]==]`), como hace `Installer.lua`, comprueba también el contenido de esas cadenas: una cadena bien formada puede contener Lua roto, y el error solo aparecería al ejecutar el instalador en Studio.

Si tocas `scripts/install.sh`:

```bash
bash -n scripts/install.sh
```

## Mensajes de commit

Formato [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/), con el asunto redactado en **tercera persona o sustantivo**, no en imperativo:

```
fix(layout): correccion de desborde del cuerpo y glifos no soportados
feat(audio): adicion del sistema de sonido de interfaz
docs(references): adicion del catalogo de errores conocidos
perf(list): reutilizacion de instancias en listas
```

Prefijos en uso: `feat`, `fix`, `perf`, `docs`, `refactor`, `chore`.

En el cuerpo, una línea por cambio, también en sustantivo ("Adición de...", "Sustitución de...", "Ampliación de...").

Un commit por cambio coherente. Un commit que corrige un bug, añade tres referencias y renombra el proyecto no se puede revisar ni revertir.

## Versionado

`CHANGELOG.md` sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y [SemVer](https://semver.org/lang/es/):

- **Mayor**: cambia el flujo de la skill o la estructura de lo que genera.
- **Menor**: referencias, ejemplos o plantillas nuevas sin romper nada.
- **Parche**: correcciones y precisiones.
