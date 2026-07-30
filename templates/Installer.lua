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
    IgnoreGuiInset = true,
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
}, pantalla)

esquinas(main, R.L)
borde(main, C.Border, 1, 0.5)
relleno(main, S.L)

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
    Text = "✕",
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
    Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = 3,
}, main)
lista(filtros, Enum.FillDirection.Horizontal, S.S)

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
local cuerpo = crear("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, -160),
    LayoutOrder = 4,
}, main)
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

-- Datos de ejemplo: sustituir por los del juego
local EJEMPLOS = {
    { Nombre = "Urbano 240", Detalle = "36 asientos · 80 km/h" },
    { Nombre = "Interprovincial X", Detalle = "48 asientos · 110 km/h" },
    { Nombre = "Escolar Mini", Detalle = "22 asientos · 70 km/h" },
    { Nombre = "Doble Piso", Detalle = "72 asientos · 95 km/h" },
}

for indice, datos in ipairs(EJEMPLOS) do
    local tarjeta = crear("TextButton", {
        Name = "Card_" .. indice,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0,
        LayoutOrder = indice,
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
        Text = datos.Nombre,
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
        Text = datos.Detalle,
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

-- Estados de una tarjeta: normal y seleccionada
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

-- Feedback en cada tarjeta. En táctil no hay hover, así que el peso
-- del feedback lo lleva el estado presionado.
for _, tarjeta in ipairs(tarjetas:GetChildren()) do
    if tarjeta:IsA("TextButton") then
        local escala = tarjeta:FindFirstChildOfClass("UIScale")

        tarjeta.MouseEnter:Connect(function()
            if seleccionada ~= tarjeta and escala then
                animar(escala, Theme.Animation.Fast, { Scale = 1.02 })
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
            seleccionar(tarjeta)
        end)
    end
end

-- Búsqueda con estado vacío
entrada:GetPropertyChangedSignal("Text"):Connect(function()
    local consulta = string.lower(entrada.Text)
    local visibles = 0

    for _, tarjeta in ipairs(tarjetas:GetChildren()) do
        if tarjeta:IsA("TextButton") then
            local coincide = consulta == "" or string.find(string.lower(tarjeta.Nombre.Text), consulta, 1, true) ~= nil
            tarjeta.Visible = coincide
            if coincide then
                visibles = visibles + 1
            end
        end
    end

    vacio.Visible = visibles == 0
    if visibles == 0 then
        vacio.Mensaje.Text = "No hay autobuses que coincidan con '" .. entrada.Text .. "'"
    end
end)

-- Cierre
header.CloseButton.MouseButton1Click:Connect(function()
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
end

pantalla:GetPropertyChangedSignal("AbsoluteSize"):Connect(aplicarModo)
aplicarModo()

-- Selección inicial
local primera = tarjetas:FindFirstChild("Card_1")
if primera then
    seleccionar(primera)
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
