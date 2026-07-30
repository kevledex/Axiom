# Instalación

Axiom es una skill de Claude Code. Instalarla consiste en dejar la carpeta del repositorio dentro del directorio de skills que Claude Code lee al arrancar.

Claude Code busca skills en dos sitios:

| Alcance | Ruta | Cuándo usarlo |
|---|---|---|
| Personal | `~/.claude/skills/` | disponible en todos tus proyectos. Es lo normal. |
| Del proyecto | `.claude/skills/` | solo en ese repositorio, y se comparte con quien lo clone. |

La ruta final tiene que ser `.../skills/axiom/SKILL.md`. **Sin una carpeta extra en medio**: si acabas con `.../skills/axiom/Axiom/SKILL.md`, Claude Code no la detecta. Es el error de instalación más frecuente.

---

## Windows

### Requisitos

Necesitas Git. Comprueba si ya lo tienes abriendo PowerShell:

```powershell
git --version
```

Si da error, instálalo con cualquiera de estas opciones:

```powershell
winget install --id Git.Git -e
```

O descárgalo de `https://git-scm.com/download/win`.

### Instalación

En PowerShell:

```powershell
git clone https://github.com/kevledex/Axiom.git "$env:USERPROFILE\.claude\skills\axiom"
```

Para instalarla solo en el proyecto actual, sitúate en la carpeta del proyecto y usa:

```powershell
git clone https://github.com/kevledex/Axiom.git ".claude\skills\axiom"
```

También puedes usar el script incluido:

```powershell
git clone https://github.com/kevledex/Axiom.git
cd Axiom
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

El `-ExecutionPolicy Bypass` es necesario porque Windows bloquea por defecto la ejecución de scripts descargados. Solo afecta a esa ejecución, no cambia la configuración del sistema.

### Verificar

```powershell
Test-Path "$env:USERPROFILE\.claude\skills\axiom\SKILL.md"
```

Debe devolver `True`.

### Actualizar y desinstalar

```powershell
git -C "$env:USERPROFILE\.claude\skills\axiom" pull
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\axiom"
```

### Problemas frecuentes en Windows

- **No puedo crear la carpeta `.claude` desde el Explorador.** Windows no deja crear carpetas que empiezan por punto desde la interfaz gráfica. Hazlo desde la terminal, o deja que `git clone` la cree por ti (lo hace solo).
- **`git` no se reconoce como comando** después de instalarlo. Cierra y vuelve a abrir PowerShell: la variable `PATH` se actualiza al abrir una sesión nueva.
- **Usas WSL.** Entonces tienes dos sistemas de archivos distintos. Si ejecutas Claude Code **dentro** de WSL, instala la skill en el `~/.claude/skills/` de Linux siguiendo la sección de Linux, no en el de Windows. Mezclarlos es una fuente típica de confusión.
- **La ruta no aparece.** `$env:USERPROFILE` es normalmente `C:\Users\TuNombre`. Comprueba con `echo $env:USERPROFILE`.

---

## macOS

### Requisitos

Comprueba si tienes Git en Terminal:

```bash
git --version
```

Si no lo tienes, macOS te ofrecerá instalar las herramientas de línea de comandos de Xcode. También puedes forzarlo:

```bash
xcode-select --install
```

O con Homebrew, si lo usas:

```bash
brew install git
```

### Instalación

```bash
git clone https://github.com/kevledex/Axiom.git ~/.claude/skills/axiom
```

Solo para el proyecto actual:

```bash
git clone https://github.com/kevledex/Axiom.git .claude/skills/axiom
```

Con el script incluido:

```bash
git clone https://github.com/kevledex/Axiom.git
cd Axiom
chmod +x scripts/install.sh
./scripts/install.sh
```

O en una línea, sin clonar a mano:

```bash
curl -fsSL https://raw.githubusercontent.com/kevledex/Axiom/main/scripts/install.sh | bash
```

### Verificar

```bash
ls -la ~/.claude/skills/axiom/SKILL.md
```

### Actualizar y desinstalar

```bash
git -C ~/.claude/skills/axiom pull
rm -rf ~/.claude/skills/axiom
```

### Problemas frecuentes en macOS

- **"No se puede abrir porque no se ha podido verificar el desarrollador."** Es Gatekeeper actuando sobre un archivo descargado con el atributo de cuarentena. Si has descargado el script suelto en lugar de clonarlo:

  ```bash
  xattr -d com.apple.quarantine scripts/install.sh
  chmod +x scripts/install.sh
  ```

  Clonando con `git` esto no ocurre, porque los archivos no vienen marcados como descargados.

- **`permission denied` al ejecutar el script.** Falta el permiso de ejecución: `chmod +x scripts/install.sh`.
- **La carpeta `.claude` no aparece en el Finder.** Las carpetas que empiezan por punto están ocultas. `Cmd + Shift + .` las muestra.
- **Usas `zsh` y el `~` no se expande** dentro de comillas. Escribe la ruta sin comillas, o usa `$HOME` en su lugar: `"$HOME/.claude/skills/axiom"`.
- **Mac con Apple Silicon.** No hay ninguna diferencia: la skill son archivos de texto, no binarios compilados.

---

## Linux

### Requisitos

```bash
git --version
```

Si no lo tienes, según tu distribución:

```bash
sudo apt install git          # Debian, Ubuntu, Mint
sudo dnf install git          # Fedora, RHEL
sudo pacman -S git            # Arch, Manjaro
sudo zypper install git       # openSUSE
```

### Instalación

```bash
git clone https://github.com/kevledex/Axiom.git ~/.claude/skills/axiom
```

Solo para el proyecto actual:

```bash
git clone https://github.com/kevledex/Axiom.git .claude/skills/axiom
```

Con el script incluido:

```bash
git clone https://github.com/kevledex/Axiom.git
cd Axiom
chmod +x scripts/install.sh
./scripts/install.sh
```

O en una línea:

```bash
curl -fsSL https://raw.githubusercontent.com/kevledex/Axiom/main/scripts/install.sh | bash
```

Si no tienes `curl`, `wget -qO- <url> | bash` hace lo mismo.

### Verificar

```bash
ls -la ~/.claude/skills/axiom/SKILL.md
```

### Actualizar y desinstalar

```bash
git -C ~/.claude/skills/axiom pull
rm -rf ~/.claude/skills/axiom
```

### Problemas frecuentes en Linux

- **`$HOME` no es lo que esperas** (contenedores, `sudo`, usuarios de servicio). Comprueba con `echo $HOME` antes de instalar. **No instales con `sudo`**: la skill acabaría en el directorio de root y Claude Code, ejecutándose como tu usuario, no la vería.
- **Shell distinta de bash.** El script empieza con `#!/usr/bin/env bash`, así que ejecútalo con `./scripts/install.sh` o `bash scripts/install.sh`. Con `sh scripts/install.sh` puede fallar en distribuciones donde `sh` no es bash.
- **Instalación en un servidor remoto o contenedor.** Funciona igual, pero recuerda que la skill tiene que estar en la máquina donde **se ejecuta** Claude Code, no en la que usas para conectarte.
- **Sistema de archivos de solo lectura** en tu `$HOME` (algunos entornos gestionados): instala la skill con alcance de proyecto, en `.claude/skills/` dentro de un directorio donde sí puedas escribir.

---

## Después de instalar, en cualquier sistema

1. **Abre una sesión nueva de Claude Code.** Las skills se cargan al iniciar sesión, no en caliente. Si ya la tenías abierta, ciérrala y ábrela otra vez.
2. Comprueba que se ha cargado pidiéndole algo de interfaz de Roblox, por ejemplo *"crea un selector premium de buses para mi juego"*. Debería empezar preguntando por el propósito de la interfaz en lugar de devolver código directamente.
3. También puedes invocarla por nombre con `/axiom`.

### Si no se activa

- Comprueba la ruta exacta: `.../skills/axiom/SKILL.md`, sin carpeta intermedia.
- Confirma que el archivo se llama `SKILL.md`, en mayúsculas.
- Reinicia la sesión de Claude Code.
- Si tienes una versión instalada en el proyecto y otra personal, la del proyecto tiene prioridad. Comprueba que no estás usando una copia antigua sin darte cuenta.

## Requisitos adicionales para usar lo que genera

Axiom produce scripts para Roblox Studio, así que además de la skill necesitas:

- **Roblox Studio**, en Windows o macOS. No hay versión oficial para Linux; en Linux puedes usar la skill para generar el código, pero necesitarás Studio en otra máquina (o una capa de compatibilidad) para instalar la interfaz.
- El instalador se ejecuta en la **Command Bar** en modo edición, porque necesita permisos de plugin para escribir el código de los módulos. No funciona en tiempo de ejecución.
