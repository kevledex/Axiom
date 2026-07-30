# Instalador de la skill Axiom para Claude Code (Windows PowerShell).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Project
#
# -Project instala la skill solo en el proyecto actual (.claude\skills)
# en lugar de para todo el usuario (%USERPROFILE%\.claude\skills).

#Requires -Version 5.1

param(
    [switch]$Project
)

$ErrorActionPreference = "Stop"

$NombreSkill = "axiom"
$Repo = "https://github.com/kevledex/Axiom.git"
$Rama = "main"

if ($Project) {
    $Base = Join-Path (Get-Location) ".claude\skills"
} else {
    $Base = Join-Path $env:USERPROFILE ".claude\skills"
}

$Destino = Join-Path $Base $NombreSkill

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Se necesita git para instalar la skill. Instalalo con: winget install --id Git.Git -e"
    exit 1
}

New-Item -ItemType Directory -Force -Path $Base | Out-Null

if (Test-Path (Join-Path $Destino ".git")) {
    Write-Host "La skill ya esta instalada en $Destino. Actualizando..."
    git -C $Destino pull --ff-only origin $Rama
} elseif (Test-Path $Destino) {
    Write-Error "$Destino existe y no es un repositorio git. Muevelo o borralo tu antes de reinstalar."
    exit 1
} else {
    Write-Host "Instalando $NombreSkill en $Destino..."
    git clone --depth 1 --branch $Rama $Repo $Destino
}

if (-not (Test-Path (Join-Path $Destino "SKILL.md"))) {
    Write-Error "No se encontro SKILL.md en $Destino. La instalacion no es valida."
    exit 1
}

Write-Host ""
Write-Host "Listo. Skill instalada en: $Destino"
Write-Host ""
Write-Host "Siguiente paso: abre una sesion NUEVA de Claude Code y prueba con algo como"
Write-Host "  'crea un selector premium de buses para mi juego de Roblox'"
