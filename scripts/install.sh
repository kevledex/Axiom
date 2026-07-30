#!/usr/bin/env bash
# Instalador de la skill Roblox UI Architect para Claude Code.
#
# Uso:
#   ./scripts/install.sh              # instala para tu usuario (~/.claude/skills)
#   ./scripts/install.sh --project    # instala solo en el proyecto actual (./.claude/skills)
#
# También funciona directamente desde GitHub:
#   curl -fsSL https://raw.githubusercontent.com/kevledex/Axiom/main/scripts/install.sh | bash

set -euo pipefail

NOMBRE_SKILL="axiom"
REPO="https://github.com/kevledex/Axiom.git"
RAMA="main"

ALCANCE="usuario"
if [ "${1:-}" = "--project" ]; then
    ALCANCE="proyecto"
fi

if [ "$ALCANCE" = "proyecto" ]; then
    BASE=".claude/skills"
else
    BASE="$HOME/.claude/skills"
fi

DESTINO="$BASE/$NOMBRE_SKILL"

if ! command -v git >/dev/null 2>&1; then
    echo "Error: se necesita git para instalar la skill." >&2
    exit 1
fi

mkdir -p "$BASE"

if [ -d "$DESTINO/.git" ]; then
    echo "La skill ya está instalada en $DESTINO. Actualizando..."
    git -C "$DESTINO" pull --ff-only origin "$RAMA"
elif [ -d "$DESTINO" ]; then
    echo "Error: $DESTINO existe y no es un repositorio git." >&2
    echo "Muévelo o bórralo tú antes de reinstalar." >&2
    exit 1
else
    echo "Instalando $NOMBRE_SKILL en $DESTINO..."
    git clone --depth 1 --branch "$RAMA" "$REPO" "$DESTINO"
fi

if [ ! -f "$DESTINO/SKILL.md" ]; then
    echo "Error: no se encontró SKILL.md en $DESTINO. La instalación no es válida." >&2
    exit 1
fi

echo ""
echo "Listo. Skill instalada en: $DESTINO"
echo ""
echo "Siguiente paso: abre una sesión nueva de Claude Code y prueba con algo como"
echo "  \"crea un selector premium de buses para mi juego de Roblox\""
