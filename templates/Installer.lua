--[[
    INSTALADOR DE INTERFAZ — Roblox Studio Command Bar
    ==================================================
    Cómo usarlo:
      1. Abre Roblox Studio con tu proyecto.
      2. Pestaña View > Command Bar.
      3. Pega TODO este script.
      4. Presiona Enter.

    Este es el ESQUELETO de referencia. Al generar un instalador real,
    mantén esta estructura y amplía las secciones 6 a 9 con la interfaz
    diseñada en las Fases 1 y 2. El tamaño no importa: la editabilidad sí.

    No borra nada: si la UI ya existe, avisa y termina.
--]]

-- 1. CONFIGURACIÓN -----------------------------------------------------------

local NOMBRE_UI = "BusSelectorUI"
local destino = game:GetService("StarterGui")

-- IgnoreGuiInset: true usa la pantalla COMPLETA, incluida la franja superior
-- donde Roblox pone su boton. Necesario para fondos y overlays a pantalla
-- completa, pero obliga a reservar margen arriba (MARGEN_SUPERIOR).
-- false deja que Roblox reserve esa franja: mas seguro para HUD y paneles.
local IGNORAR_INSET = true
local MARGEN_SUPERIOR = 44

-- Ponlo en true solo si quieres borrar a mano una instalación anterior.
local REEMPLAZAR_SI_EXISTE = false

-- 2. COMPROBACIÓN DE EXISTENCIA ---------------------------------------------

local existente = destino:FindFirstChild(NOMBRE_UI)
if existente then
    if not REEMPLAZAR_SI_EXISTE then
        warn("Ya existe " .. NOMBRE_UI .. " en " .. destino.Name .. ". No se reemplazó. Renómbralo o bórralo tú si quieres reinstalar.")
        return
    end
    existente:Destroy()
    warn("Se eliminó la versión anterior de " .. NOMBRE_UI .. " porque REEMPLAZAR_SI_EXISTE estaba en true.")
end

-- 3. HISTORIAL (permite deshacer la instalación con Ctrl+Z) ------------------

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local registro = nil
pcall(function()
    registro = ChangeHistoryService:TryBeginRecording("Instalar " .. NOMBRE_UI)
end)

local function cerrarRegistro()
    if registro then
        pcall(function()
            ChangeHistoryService:FinishRecording(registro, Enum.FinishRecordingOperation.Commit)
        end)
    end
end

-- 4. HELPERS -----------------------------------------------------------------

-- Parent se asigna al final a propósito: cambiar propiedades con el objeto
-- ya dentro del árbol dispara un recálculo de layout en cada asignación.
local function crear(clase, propiedades, padre)
    local objeto = Instance.new(clase)
    for nombre, valor in pairs(propiedades or {}) do
        objeto[nombre] = valor
    end
    objeto.Parent = padre
    return objeto
end

local function esquinas(objeto, radio)
    crear("UICorner", { CornerRadius = UDim.new(0, radio) }, objeto)
end

local function borde(objeto, color, grosor, transparencia)
    crear("UIStroke", {
        Color = color,
        Thickness = grosor or 1,
        Transparency = transparencia or 0.4,
    }, objeto)
end

local function relleno(objeto, arriba, abajo, izquierda, derecha)
    crear("UIPadding", {
        PaddingTop = UDim.new(0, arriba),
        PaddingBottom = UDim.new(0, abajo or arriba),
        PaddingLeft = UDim.new(0, izquierda or arriba),
        PaddingRight = UDim.new(0, derecha or izquierda or arriba),
    }, objeto)
end

local function lista(objeto, direccion, separacion)
    return crear("UIListLayout", {
        FillDirection = direccion,
        Padding = UDim.new(0, separacion),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, objeto)
end

local function crearModulo(nombre, fuente, padre)
    local modulo = Instance.new("ModuleScript")
    modulo.Name = nombre
    modulo.Source = fuente
    modulo.Parent = padre
    return modulo
end

local function crearLocal(nombre, fuente, padre)
    local guion = Instance.new("LocalScript")
    guion.Name = nombre
    guion.Source = fuente
    guion.Parent = padre
    return guion
end

-- 5. PALETA LOCAL (los mismos valores que irán en Theme) --------------------

local C = {
    Background = Color3.fromRGB(16, 18, 21),
    Surface = Color3.fromRGB(26, 29, 34),
    SurfaceElevated = Color3.fromRGB(38, 42, 49),
    Primary = Color3.fromRGB(255, 176, 32),
    TextPrimary = Color3.fromRGB(240, 242, 245),
    TextSecondary = Color3.fromRGB(150, 158, 170),
    Border = Color3.fromRGB(58, 64, 74),
    OnPrimary = Color3.fromRGB(20, 18, 12),
}

local FUENTE = "rbxasset://fonts/families/GothamSSm.json"
local S = { XS = 4, S = 8, M = 16, L = 24, XL = 32 }
local R = { S = 4, M = 8, L = 12 }

-- 6. SCREENGUI + MAIN --------------------------------------------------------

local pantalla = crear("ScreenGui", {
    Name = NOMBRE_UI,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = IGNORAR_INSET,
    ResetOnSpawn = false,
    DisplayOrder = 10,
    Enabled = true,
}, destino)

local main = crear("Frame", {
    Name = "Main",
    BackgroundColor3 = C.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(0.78, 0.8),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    -- Si algo desborda, se recorta en vez de pintarse encima de otra fila.
    ClipsDescendants = true,
}, pantalla)

esquinas(main, R.L)
borde(main, C.Border, 1, 0.5)

-- Con el inset ignorado, el margen superior lo reservamos nosotros para que
-- nada quede debajo del boton de Roblox.
relleno(main, IGNORAR_INSET and math.max(S.L, MARGEN_SUPERIOR - 24) or S.L, S.L, S.L, S.L)

-- Escala para adaptarse, constraint para no pasarse.
crear("UISizeConstraint", {
    MinSize = Vector2.new(320, 420),
    MaxSize = Vector2.new(1100, 780),
}, main)

local escalaGlobal = crear("UIScale", {}, main)

local columnaPrincipal = lista(main, Enum.FillDirection.Vertical, S.M)
columnaPrincipal.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 7. CONFIGURATION -----------------------------------------------------------

local configuracion = crear("Folder", { Name = "Configuration" }, pantalla)

crearModulo("Theme", [==[
local Theme = {}

Theme.Colors = {
    Background = Color3.fromRGB(16, 18, 21),
    Surface = Color3.fromRGB(26, 29, 34),
    SurfaceElevated = Color3.fromRGB(38, 42, 49),
    Primary = Color3.fromRGB(255, 176, 32),
    PrimaryHover = Color3.fromRGB(255, 196, 80),
    PrimaryPressed = Color3.fromRGB(214, 145, 20),
    TextPrimary = Color3.fromRGB(240, 242, 245),
    TextSecondary = Color3.fromRGB(150, 158, 170),
    TextOnPrimary = Color3.fromRGB(20, 18, 12),
    Border = Color3.fromRGB(58, 64, 74),
    Danger = Color3.fromRGB(230, 90, 90),
}

Theme.Spacing = { XSmall = 4, Small = 8, Medium = 16, Large = 24, XLarge = 32 }
Theme.Radius = { Small = 4, Medium = 8, Large = 12 }
Theme.Animation = {
    Fast = 0.12,
    Normal = 0.25,
    Style = Enum.EasingStyle.Quad,
    Direction = Enum.EasingDirection.Out,
}
Theme.Text = {
    Family = "rbxasset://fonts/families/GothamSSm.json",
    Title = 30,
    Section = 20,
    Body = 15,
    Label = 12,
}
Theme.Breakpoints = { Compacto = 600, Medio = 1000 }

function Theme.fuente(peso)
    return Font.new(Theme.Text.Family, peso)
end

function Theme.modoDePantalla(ancho)
    if ancho < Theme.Breakpoints.Compacto then
        return "Compacto"
    elseif ancho < Theme.Breakpoints.Medio then
        return "Medio"
    end
    return "Amplio"
end

return Theme
]==], configuracion)

crearModulo("Sounds", [==[
-- Cambia los 0 por tus IDs de audio. Mientras sean 0, la UI funciona en
-- silencio sin errores. Ver references/sound-design.md
local SoundService = game:GetService("SoundService")

local Sounds = {}

Sounds.Ids = {
    Hover = "rbxassetid://0",
    Click = "rbxassetid://0",
    Open = "rbxassetid://0",
    Close = "rbxassetid://0",
    Success = "rbxassetid://0",
    Error = "rbxassetid://0",
    Locked = "rbxassetid://0",
}

local VOLUMENES = {
    Hover = 0.10,
    Click = 0.22,
    Open = 0.25,
    Close = 0.20,
    Success = 0.30,
    Error = 0.30,
    Locked = 0.18,
}

-- Evita la metralleta de sonidos al recorrer una lista con el raton.
local INTERVALO_MINIMO = 0.06

local grupo = SoundService:FindFirstChild("AxiomUI")
if not grupo then
    grupo = Instance.new("SoundGroup")
    grupo.Name = "AxiomUI"
    grupo.Volume = 1
    grupo.Parent = SoundService
end

local instancias = {}
local ultimoUso = {}

local function esPlaceholder(id)
    return id == nil or id == "" or id == "rbxassetid://0"
end

local function obtener(nombre)
    if instancias[nombre] then
        return instancias[nombre]
    end

    local id = Sounds.Ids[nombre]
    if esPlaceholder(id) then
        return nil
    end

    local sonido = Instance.new("Sound")
    sonido.Name = nombre
    sonido.SoundId = id
    sonido.Volume = VOLUMENES[nombre] or 0.2
    sonido.SoundGroup = grupo
    sonido.Parent = grupo

    instancias[nombre] = sonido
    return sonido
end

function Sounds.reproducir(nombre)
    local sonido = obtener(nombre)
    if not sonido then
        return
    end

    local ahora = os.clock()
    if ahora - (ultimoUso[nombre] or 0) < INTERVALO_MINIMO then
        return
    end
    ultimoUso[nombre] = ahora

    SoundService:PlayLocalSound(sonido)
end

function Sounds.setSilencio(silenciado)
    grupo.Volume = silenciado and 0 or 1
end

function Sounds.estaSilenciado()
    return grupo.Volume == 0
end

return Sounds
]==], configuracion)

crearModulo("Data", [==[
-- Datos de ejemplo. Sustituye esta tabla por los datos reales de tu juego,
-- o rellenala desde el servidor con un RemoteFunction al abrir la interfaz.
return {
    { Nombre = "Urbano 240", Detalle = "36 asientos - 80 km/h", Tipo = "Urbano" },
    { Nombre = "Interprovincial X", Detalle = "48 asientos - 110 km/h", Tipo = "Interprovincial" },
    { Nombre = "Escolar Mini", Detalle = "22 asientos - 70 km/h", Tipo = "Escolar" },
    { Nombre = "Doble Piso", Detalle = "72 asientos - 95 km/h", Tipo = "Interprovincial" },
}
]==], configuracion)

crearModulo("Glyphs", [==[
-- Solo simbolos de Nivel A: heredan TextColor3 y no dependen de que el sistema
-- del jugador aporte una fuente de emoji en color. Ver references/emoji-safety.md
local Glyphs = {
    Close = "\u{2715}",
    Check = "\u{2713}",
    Star = "\u{2605}",
    ChevronDown = "\u{25BE}",
    ChevronRight = "\u{25B8}",
    Bullet = "\u{2022}",
    Settings = "\u{2699}",
}

return Glyphs
]==], configuracion)

crearModulo("Icons", [==[
-- Cambia los 0 por los IDs de tus imágenes subidas a Roblox.
local Icons = {
    Search = "rbxassetid://0",
    Settings = "rbxassetid://0",
    Close = "rbxassetid://0",
    Bus = "rbxassetid://0",
    Coin = "rbxassetid://0",
    Lock = "rbxassetid://0",
}

Icons.Shadow = "rbxassetid://1316045217"

function Icons.esPlaceholder(id)
    return id == nil or id == "" or id == "rbxassetid://0"
end

function Icons.obtener(nombre)
    local id = Icons[nombre]
    if type(id) ~= "string" or Icons.esPlaceholder(id) then
        return ""
    end
    return id
end

return Icons
]==], configuracion)

-- 8. ESTRUCTURA VISUAL -------------------------------------------------------

-- 8.1 Header: título dominante + subtítulo + botón de cerrar
local header = crear("Frame", {
    Name = "Header",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 56),
    LayoutOrder = 1,
}, main)

local bloqueTitulo = crear("Frame", {
    Name = "TitleBlock",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -60, 1, 0),
}, header)

local columnaTitulo = lista(bloqueTitulo, Enum.FillDirection.Vertical, 2)
columnaTitulo.VerticalAlignment = Enum.VerticalAlignment.Center

crear("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Text = "Selector de autobuses",
    TextColor3 = C.TextPrimary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Bold),
    TextSize = 30,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = 1,
}, bloqueTitulo)

crear("TextLabel", {
    Name = "Subtitle",
    BackgroundTransparency = 1,
    Text = "Elige tu vehículo y sal a la ruta",
    TextColor3 = C.TextSecondary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Medium),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, 0, 0, 18),
    LayoutOrder = 2,
}, bloqueTitulo)

local cerrar = crear("TextButton", {
    Name = "CloseButton",
    -- \u{2715} en vez del emoji en color: se tine con TextColor3 y nunca sale
    -- como cuadro vacio. Ver references/emoji-safety.md
    Text = "\u{2715}",
    TextColor3 = C.TextSecondary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Bold),
    TextSize = 18,
    BackgroundColor3 = C.Surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    -- 44 px: mínimo cómodo para un dedo
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(1, 0, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
}, header)
esquinas(cerrar, R.M)
crear("UIScale", {}, cerrar)

-- 8.2 SearchBar
local barraBusqueda = crear("Frame", {
    Name = "SearchBar",
    BackgroundColor3 = C.Surface,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 42),
    LayoutOrder = 2,
}, main)
esquinas(barraBusqueda, R.M)
borde(barraBusqueda, C.Border, 1, 0.6)
relleno(barraBusqueda, 0, 0, S.M, S.M)

crear("TextBox", {
    Name = "Input",
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Buscar autobús...",
    PlaceholderColor3 = C.TextSecondary,
    TextColor3 = C.TextPrimary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Regular),
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    Size = UDim2.new(1, 0, 1, 0),
}, barraBusqueda)

-- 8.3 Filters
local filtros = crear("Frame", {
    Name = "Filters",
    BackgroundTransparency = 1,
    -- AutomaticSize.Y para que, si los chips no caben en una linea, la fila
    -- crezca en vez de recortarlos.
    Size = UDim2.new(1, 0, 0, 34),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 3,
}, main)
local filaFiltros = lista(filtros, Enum.FillDirection.Horizontal, S.S)
pcall(function()
    filaFiltros.Wraps = true
end)

local ETIQUETAS_FILTRO = { "Todos", "Urbano", "Interprovincial", "Escolar" }
for indice, texto in ipairs(ETIQUETAS_FILTRO) do
    local activo = indice == 1
    local chip = crear("TextButton", {
        Name = "Filter_" .. texto,
        Text = texto,
        TextColor3 = activo and C.OnPrimary or C.TextSecondary,
        FontFace = Font.new(FUENTE, Enum.FontWeight.Medium),
        TextSize = 13,
        BackgroundColor3 = activo and C.Primary or C.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        LayoutOrder = indice,
    }, filtros)
    esquinas(chip, R.M)
    relleno(chip, 0, 0, S.M, S.M)
    crear("UIScale", {}, chip)
end

-- 8.4 Cuerpo: lista de tarjetas + panel de detalle
-- El cuerpo ocupa el espacio que sobra. NUNCA se calcula a mano con algo como
-- UDim2.new(1, 0, 1, -160): ese numero se rompe en cuanto cambia la altura de
-- una fila, el padding o la separacion, y es la causa tipica de que una fila
-- quede tapada por el contenido de abajo en pantallas de poca altura.
local cuerpo = crear("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    LayoutOrder = 4,
}, main)

-- UIFlexItem hace el reparto de espacio de forma declarativa, como flex: 1 en CSS.
-- Si la version de Studio no lo tiene, el controlador mide y ajusta (ver ajustarCuerpo).
pcall(function()
    crear("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }, cuerpo)
end)
lista(cuerpo, Enum.FillDirection.Horizontal, S.M)

-- El estado vacío no puede ser hijo directo del ScrollingFrame: el UIGridLayout
-- lo trataría como una celda más. Por eso va dentro de un wrapper sin layout.
local contenedorLista = crear("Frame", {
    Name = "ListWrapper",
    BackgroundTransparency = 1,
    Size = UDim2.new(0.62, 0, 1, 0),
    LayoutOrder = 1,
}, cuerpo)

local tarjetas = crear("ScrollingFrame", {
    Name = "BusCards",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ElasticBehavior = Enum.ElasticBehavior.Never,
}, contenedorLista)

local rejilla = crear("UIGridLayout", {
    CellSize = UDim2.new(0.48, 0, 0, 96),
    CellPadding = UDim2.new(0.04, 0, 0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tarjetas)

-- Lote fijo de tarjetas reutilizables (pooling).
-- El instalador crea las instancias una sola vez y el controlador las rellena
-- con datos y las muestra u oculta. Nunca se destruyen ni se recrean al filtrar:
-- Instance.new por cada item en cada refresco es la causa numero uno de tirones
-- en moviles de gama baja. Ver references/performance.md
local MAX_TARJETAS = 12

for indice = 1, MAX_TARJETAS do
    local tarjeta = crear("TextButton", {
        Name = "Card_" .. indice,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0,
        LayoutOrder = indice,
        Visible = false,
    }, tarjetas)
    esquinas(tarjeta, R.M)
    borde(tarjeta, C.Border, 1, 0.6)
    relleno(tarjeta, S.M)
    crear("UIScale", {}, tarjeta)

    local columna = lista(tarjeta, Enum.FillDirection.Vertical, S.XS)
    columna.VerticalAlignment = Enum.VerticalAlignment.Center

    crear("TextLabel", {
        Name = "Nombre",
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.TextPrimary,
        FontFace = Font.new(FUENTE, Enum.FontWeight.SemiBold),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = 1,
    }, tarjeta)

    crear("TextLabel", {
        Name = "Detalle",
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.TextSecondary,
        FontFace = Font.new(FUENTE, Enum.FontWeight.Regular),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = 2,
    }, tarjeta)
end

-- Estado vacío: siempre icono atenuado + mensaje + salida
local vacio = crear("Frame", {
    Name = "EmptyState",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
    ZIndex = 2,
}, contenedorLista)

crear("TextLabel", {
    Name = "Mensaje",
    BackgroundTransparency = 1,
    Text = "No hay autobuses que coincidan con tu búsqueda",
    TextColor3 = C.TextSecondary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Medium),
    TextSize = 14,
    TextWrapped = true,
    Size = UDim2.new(0.8, 0, 0, 40),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
}, vacio)

local detalles = crear("Frame", {
    Name = "DetailsPanel",
    BackgroundColor3 = C.SurfaceElevated,
    BorderSizePixel = 0,
    Size = UDim2.new(0.34, 0, 1, 0),
    LayoutOrder = 2,
}, cuerpo)
esquinas(detalles, R.M)
relleno(detalles, S.L)

local columnaDetalles = lista(detalles, Enum.FillDirection.Vertical, S.S)
columnaDetalles.VerticalAlignment = Enum.VerticalAlignment.Top

crear("TextLabel", {
    Name = "Titulo",
    BackgroundTransparency = 1,
    Text = "Urbano 240",
    TextColor3 = C.TextPrimary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Bold),
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, 0, 0, 26),
    LayoutOrder = 1,
}, detalles)

crear("TextLabel", {
    Name = "Descripcion",
    BackgroundTransparency = 1,
    Text = "Autobús urbano ágil, ideal para rutas cortas con muchas paradas.",
    TextColor3 = C.TextSecondary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.Regular),
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Size = UDim2.new(1, 0, 0, 60),
    LayoutOrder = 2,
}, detalles)

local confirmar = crear("TextButton", {
    Name = "ConfirmButton",
    Text = "Seleccionar",
    TextColor3 = C.OnPrimary,
    FontFace = Font.new(FUENTE, Enum.FontWeight.SemiBold),
    TextSize = 15,
    BackgroundColor3 = C.Primary,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.new(1, 0, 0, 44),
    LayoutOrder = 10,
}, detalles)
esquinas(confirmar, R.M)
crear("UIScale", {}, confirmar)

-- 9. CONTROLLERS -------------------------------------------------------------

local controladores = crear("Folder", { Name = "Controllers" }, pantalla)

crearLocal("UIController", [==[
-- Controlador de la interfaz: selección, búsqueda, cierre y responsive.
local TweenService = game:GetService("TweenService")

local pantalla = script.Parent.Parent
local Theme = require(pantalla.Configuration.Theme)
local Data = require(pantalla.Configuration.Data)
local Sounds = require(pantalla.Configuration.Sounds)

local main = pantalla:WaitForChild("Main")
local header = main:WaitForChild("Header")
local cuerpo = main:WaitForChild("Body")
local contenedorLista = cuerpo:WaitForChild("ListWrapper")
local tarjetas = contenedorLista:WaitForChild("BusCards")
local detalles = cuerpo:WaitForChild("DetailsPanel")
local vacio = contenedorLista:WaitForChild("EmptyState")
local entrada = main:WaitForChild("SearchBar"):WaitForChild("Input")
local escalaGlobal = main:FindFirstChildOfClass("UIScale")

local seleccionada = nil

local function animar(objeto, duracion, propiedades)
    local info = TweenInfo.new(duracion, Theme.Animation.Style, Theme.Animation.Direction)
    local tween = TweenService:Create(objeto, info, propiedades)
    tween:Play()
    return tween
end

-- Lote de tarjetas ya creadas por el instalador. Se reutilizan siempre:
-- rellenar texto y alternar Visible es mucho mas barato que crear y destruir
-- instancias en cada busqueda o cada cambio de filtro.
local lote = {}
for _, hijo in ipairs(tarjetas:GetChildren()) do
    if hijo:IsA("TextButton") then
        table.insert(lote, hijo)
    end
end
table.sort(lote, function(a, b)
    return a.LayoutOrder < b.LayoutOrder
end)

local visibles = {}

local function pintarTarjeta(tarjeta, activa)
    local trazo = tarjeta:FindFirstChildOfClass("UIStroke")
    animar(tarjeta, Theme.Animation.Fast, {
        BackgroundColor3 = activa and Theme.Colors.SurfaceElevated or Theme.Colors.Surface,
    })
    if trazo then
        animar(trazo, Theme.Animation.Fast, {
            Color = activa and Theme.Colors.Primary or Theme.Colors.Border,
            Transparency = activa and 0 or 0.6,
        })
    end
end

local function seleccionar(tarjeta)
    if seleccionada == tarjeta then
        return
    end
    if seleccionada then
        pintarTarjeta(seleccionada, false)
    end
    seleccionada = tarjeta
    pintarTarjeta(tarjeta, true)

    detalles.Titulo.Text = tarjeta.Nombre.Text
    detalles.Descripcion.Text = tarjeta.Detalle.Text
end

-- Los eventos se conectan UNA sola vez por tarjeta, no en cada refresco.
-- Reconectar en cada render duplica conexiones y filtra memoria.
for _, tarjeta in ipairs(lote) do
    local escala = tarjeta:FindFirstChildOfClass("UIScale")

    tarjeta.MouseEnter:Connect(function()
        if seleccionada ~= tarjeta and escala then
            animar(escala, Theme.Animation.Fast, { Scale = 1.02 })
            Sounds.reproducir("Hover")
        end
    end)

    tarjeta.MouseLeave:Connect(function()
        if escala then
            animar(escala, Theme.Animation.Fast, { Scale = 1 })
        end
    end)

    tarjeta.MouseButton1Down:Connect(function()
        if escala then
            animar(escala, 0.08, { Scale = 0.97 })
        end
    end)

    tarjeta.MouseButton1Click:Connect(function()
        if escala then
            animar(escala, Theme.Animation.Fast, { Scale = 1 })
        end
        Sounds.reproducir("Click")
        seleccionar(tarjeta)
    end)
end

-- Rellena el lote con los datos que toque mostrar. Si hay mas datos que
-- tarjetas, avisa en lugar de crear instancias nuevas en silencio: el limite
-- es deliberado y se sube cambiando MAX_TARJETAS en el instalador, o se
-- resuelve con paginacion.
local function renderizar(datos)
    visibles = {}

    for indice, tarjeta in ipairs(lote) do
        local fila = datos[indice]
        if fila then
            tarjeta.Nombre.Text = fila.Nombre
            tarjeta.Detalle.Text = fila.Detalle
            tarjeta.Visible = true
            table.insert(visibles, tarjeta)
        else
            tarjeta.Visible = false
        end
    end

    if #datos > #lote then
        warn("Hay " .. #datos .. " elementos y solo " .. #lote .. " tarjetas. Sube MAX_TARJETAS o pagina la lista.")
    end

    vacio.Visible = #visibles == 0
end

local function filtrar(consulta)
    consulta = string.lower(consulta or "")
    if consulta == "" then
        renderizar(Data)
        return
    end

    local resultado = {}
    for _, fila in ipairs(Data) do
        if string.find(string.lower(fila.Nombre), consulta, 1, true) then
            table.insert(resultado, fila)
        end
    end

    renderizar(resultado)
    if #resultado == 0 then
        vacio.Mensaje.Text = "No hay autobuses que coincidan con '" .. entrada.Text .. "'"
    end
end

entrada:GetPropertyChangedSignal("Text"):Connect(function()
    filtrar(entrada.Text)
end)

-- Cierre
header.CloseButton.MouseButton1Click:Connect(function()
    Sounds.reproducir("Close")
    -- No se anima escalaGlobal aquí: la usa el sistema responsive.
    animar(main, Theme.Animation.Fast, { BackgroundTransparency = 1 })
    task.delay(Theme.Animation.Fast, function()
        pantalla.Enabled = false
    end)
end)

-- Responsive: se escucha AbsoluteSize, así cubre también el redimensionado
-- de la ventana en PC y la rotación en móvil.
local rejilla = tarjetas:FindFirstChildOfClass("UIGridLayout")
local listaCuerpo = cuerpo:FindFirstChildOfClass("UIListLayout")

-- Respaldo por si la version de Studio no tiene UIFlexItem: en vez de restar un
-- numero fijo, se MIDE lo que ocupan las filas fijas y se reparte lo que sobra.
local function ajustarCuerpo()
    if cuerpo:FindFirstChildOfClass("UIFlexItem") then
        return
    end

    local columna = main:FindFirstChildOfClass("UIListLayout")
    local rellenoMain = main:FindFirstChildOfClass("UIPadding")
    local disponible = main.AbsoluteSize.Y

    if rellenoMain then
        disponible = disponible - rellenoMain.PaddingTop.Offset - rellenoMain.PaddingBottom.Offset
    end

    for _, hijo in ipairs(main:GetChildren()) do
        if hijo:IsA("GuiObject") and hijo ~= cuerpo then
            disponible = disponible - hijo.AbsoluteSize.Y - columna.Padding.Offset
        end
    end

    cuerpo.Size = UDim2.new(1, 0, 0, math.max(disponible, 120))
end

local function aplicarModo()
    local ancho = pantalla.AbsoluteSize.X
    local modo = Theme.modoDePantalla(ancho)
    local compacto = modo == "Compacto"

    if escalaGlobal then
        escalaGlobal.Scale = math.clamp(ancho / 1280, 0.85, 1.2)
    end

    -- En compacto el detalle no cabe al lado: la lista ocupa todo
    -- y el detalle se muestra debajo, no encogido en una columna estrecha.
    listaCuerpo.FillDirection = compacto and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
    contenedorLista.Size = compacto and UDim2.new(1, 0, 0.58, 0) or UDim2.new(0.62, 0, 1, 0)
    detalles.Size = compacto and UDim2.new(1, 0, 0.4, 0) or UDim2.new(0.34, 0, 1, 0)
    rejilla.CellSize = compacto and UDim2.new(0.98, 0, 0, 84) or UDim2.new(0.48, 0, 0, 96)
    rejilla.CellPadding = compacto and UDim2.new(0, 0, 0, 8) or UDim2.new(0.04, 0, 0, 12)

    ajustarCuerpo()
end

pantalla:GetPropertyChangedSignal("AbsoluteSize"):Connect(aplicarModo)
aplicarModo()

-- Boton de confirmar del panel de detalle
local confirmar = detalles:WaitForChild("ConfirmButton")
local escalaConfirmar = confirmar:FindFirstChildOfClass("UIScale")

confirmar.MouseEnter:Connect(function()
    animar(confirmar, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.PrimaryHover })
    if escalaConfirmar then
        animar(escalaConfirmar, Theme.Animation.Fast, { Scale = 1.02 })
    end
    Sounds.reproducir("Hover")
end)

confirmar.MouseLeave:Connect(function()
    animar(confirmar, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.Primary })
    if escalaConfirmar then
        animar(escalaConfirmar, Theme.Animation.Fast, { Scale = 1 })
    end
end)

confirmar.MouseButton1Down:Connect(function()
    animar(confirmar, 0.08, { BackgroundColor3 = Theme.Colors.PrimaryPressed })
    if escalaConfirmar then
        animar(escalaConfirmar, 0.08, { Scale = 0.98 })
    end
end)

confirmar.MouseButton1Click:Connect(function()
    animar(confirmar, Theme.Animation.Fast, { BackgroundColor3 = Theme.Colors.Primary })
    if escalaConfirmar then
        animar(escalaConfirmar, Theme.Animation.Fast, { Scale = 1 })
    end
    Sounds.reproducir("Success")
    -- Aqui va la llamada al servidor que aplica la seleccion.
end)

-- Sonido de apertura, solo si la UI arranca visible
if pantalla.Enabled then
    Sounds.reproducir("Open")
end

-- Render inicial y seleccion de la primera tarjeta visible
renderizar(Data)

if visibles[1] then
    seleccionar(visibles[1])
end
]==], controladores)

-- 10. CIERRE -----------------------------------------------------------------

cerrarRegistro()

pcall(function()
    game:GetService("Selection"):Set({ pantalla })
end)

print("✅ " .. NOMBRE_UI .. " instalada en " .. destino.Name)
print("👉 Edita Configuration/Icons y cambia los rbxassetid://0 por tus propios IDs")
print("👉 Prueba en Test > Device con un teléfono pequeño y una tablet")
