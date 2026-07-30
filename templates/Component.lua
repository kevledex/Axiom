-- Component: patrón base para cualquier componente reutilizable.
-- Este ejemplo es un Button completo con variantes, icono opcional y los
-- estados normal / hover / presionado / deshabilitado / cargando.
--
-- Cópialo y adáptalo para Card, IconButton, Modal, SearchBar, Dropdown,
-- Notification, Tab, Tooltip y LoadingState. La forma es siempre la misma:
--   Component.new(config) -> instancia + API mínima
--
-- Uso:
--   local Button = require(ruta.Components.Button)
--   local comprar = Button.new({
--       Text = "Comprar",
--       Variant = "Primary",
--       Parent = panelAcciones,
--       OnClick = function()
--           print("comprado")
--       end,
--   })
--   comprar.setDeshabilitado(true)

local TweenService = game:GetService("TweenService")

local Configuration = script.Parent.Parent.Configuration
local Theme = require(Configuration.Theme)
local Icons = require(Configuration.Icons)

local Button = {}

local function animar(objeto, duracion, propiedades)
    local info = TweenInfo.new(duracion, Theme.Animation.Style, Theme.Animation.Direction)
    local tween = TweenService:Create(objeto, info, propiedades)
    tween:Play()
    return tween
end

-- Colores por variante. Añadir una variante nueva es añadir una entrada aquí,
-- no duplicar el componente.
local VARIANTES = {
    Primary = {
        Fondo = Theme.Colors.Primary,
        FondoHover = Theme.Colors.PrimaryHover,
        FondoPresionado = Theme.Colors.PrimaryPressed,
        Texto = Theme.Colors.TextOnPrimary,
        Borde = nil,
    },
    Secondary = {
        Fondo = Theme.Colors.Surface,
        FondoHover = Theme.Colors.SurfaceElevated,
        FondoPresionado = Theme.Colors.Surface,
        Texto = Theme.Colors.TextPrimary,
        Borde = Theme.Colors.Border,
    },
    Ghost = {
        Fondo = Theme.Colors.Surface,
        FondoHover = Theme.Colors.SurfaceElevated,
        FondoPresionado = Theme.Colors.Surface,
        Texto = Theme.Colors.TextSecondary,
        Borde = nil,
    },
    Danger = {
        Fondo = Theme.Colors.Danger,
        FondoHover = Theme.Colors.Danger,
        FondoPresionado = Theme.Colors.Danger,
        Texto = Theme.Colors.TextPrimary,
        Borde = nil,
    },
}

function Button.new(config)
    config = config or {}

    local variante = VARIANTES[config.Variant or "Primary"] or VARIANTES.Primary
    local altura = config.Height or 44 -- 44 px: mínimo cómodo para un dedo
    local deshabilitado = config.Disabled == true
    local cargando = false

    local boton = Instance.new("TextButton")
    boton.Name = config.Name or "Button"
    boton.Text = ""
    boton.AutoButtonColor = false -- el oscurecimiento por defecto arruina el diseño
    boton.BorderSizePixel = 0
    boton.BackgroundColor3 = variante.Fondo
    boton.Size = config.Size or UDim2.new(1, 0, 0, altura)
    boton.LayoutOrder = config.LayoutOrder or 0

    local escala = Instance.new("UIScale")
    escala.Parent = boton

    local esquina = Instance.new("UICorner")
    esquina.CornerRadius = UDim.new(0, Theme.Radius.Medium)
    esquina.Parent = boton

    if variante.Borde then
        local borde = Instance.new("UIStroke")
        borde.Color = variante.Borde
        borde.Thickness = 1
        borde.Transparency = 0.4
        borde.Parent = boton
    end

    local relleno = Instance.new("UIPadding")
    relleno.PaddingLeft = UDim.new(0, Theme.Spacing.Medium)
    relleno.PaddingRight = UDim.new(0, Theme.Spacing.Medium)
    relleno.Parent = boton

    -- Contenido en fila: icono opcional + texto, centrados
    local fila = Instance.new("UIListLayout")
    fila.FillDirection = Enum.FillDirection.Horizontal
    fila.HorizontalAlignment = Enum.HorizontalAlignment.Center
    fila.VerticalAlignment = Enum.VerticalAlignment.Center
    fila.Padding = UDim.new(0, Theme.Spacing.Small)
    fila.SortOrder = Enum.SortOrder.LayoutOrder
    fila.Parent = boton

    local icono = nil
    if config.Icon then
        icono = Instance.new("ImageLabel")
        icono.Name = "Icon"
        icono.BackgroundTransparency = 1
        icono.Image = Icons.obtener(config.Icon)
        icono.ImageColor3 = variante.Texto
        icono.Size = UDim2.new(0, 18, 0, 18)
        icono.LayoutOrder = 1

        -- Si el ID aún es placeholder, se ve un cuadro tenue en lugar de nada
        if Icons.esPlaceholder(Icons[config.Icon]) then
            icono.BackgroundTransparency = 0.7
            icono.BackgroundColor3 = variante.Texto
        end

        local proporcion = Instance.new("UIAspectRatioConstraint")
        proporcion.AspectRatio = 1
        proporcion.Parent = icono

        icono.Parent = boton
    end

    local etiqueta = Instance.new("TextLabel")
    etiqueta.Name = "Label"
    etiqueta.BackgroundTransparency = 1
    etiqueta.Text = config.Text or "Botón"
    etiqueta.TextColor3 = variante.Texto
    etiqueta.FontFace = Theme.fuente(Theme.Weights.SemiBold)
    etiqueta.TextSize = Theme.Text.Body
    etiqueta.AutomaticSize = Enum.AutomaticSize.X
    etiqueta.Size = UDim2.new(0, 0, 1, 0)
    etiqueta.LayoutOrder = 2
    etiqueta.Parent = boton

    -- Estados -------------------------------------------------------------

    local function aplicarNormal()
        animar(boton, Theme.Animation.Fast, {
            BackgroundColor3 = variante.Fondo,
            BackgroundTransparency = 0,
        })
        animar(escala, Theme.Animation.Fast, { Scale = 1 })
        etiqueta.TextTransparency = 0
    end

    local function aplicarDeshabilitado()
        animar(boton, Theme.Animation.Fast, {
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = 0.35,
        })
        animar(escala, Theme.Animation.Fast, { Scale = 1 })
        etiqueta.TextTransparency = 0.5
    end

    local function activo()
        return not deshabilitado and not cargando
    end

    -- MouseEnter/MouseLeave solo existen con ratón; en táctil el peso del
    -- feedback lo lleva el estado presionado, que se maneja abajo.
    boton.MouseEnter:Connect(function()
        if not activo() then
            return
        end
        animar(boton, Theme.Animation.Fast, { BackgroundColor3 = variante.FondoHover })
        animar(escala, Theme.Animation.Fast, { Scale = 1.03 })
    end)

    boton.MouseLeave:Connect(function()
        if not activo() then
            return
        end
        aplicarNormal()
    end)

    boton.InputBegan:Connect(function(entrada)
        if not activo() then
            return
        end
        local esClic = entrada.UserInputType == Enum.UserInputType.MouseButton1
        local esToque = entrada.UserInputType == Enum.UserInputType.Touch
        if esClic or esToque then
            animar(boton, 0.08, { BackgroundColor3 = variante.FondoPresionado })
            animar(escala, 0.08, { Scale = 0.97 })
        end
    end)

    boton.InputEnded:Connect(function(entrada)
        if not activo() then
            return
        end
        local esClic = entrada.UserInputType == Enum.UserInputType.MouseButton1
        local esToque = entrada.UserInputType == Enum.UserInputType.Touch
        if esClic or esToque then
            animar(escala, Theme.Animation.Fast, { Scale = 1 })
            animar(boton, Theme.Animation.Fast, { BackgroundColor3 = variante.Fondo })
        end
    end)

    boton.MouseButton1Click:Connect(function()
        if not activo() then
            return
        end
        if config.OnClick then
            config.OnClick()
        end
    end)

    -- API pública ---------------------------------------------------------

    local api = {}
    api.Instance = boton

    function api.setTexto(texto)
        etiqueta.Text = texto
    end

    function api.setDeshabilitado(valor)
        deshabilitado = valor == true
        boton.Active = not deshabilitado
        if deshabilitado then
            aplicarDeshabilitado()
        else
            aplicarNormal()
        end
    end

    function api.setCargando(valor)
        cargando = valor == true
        if cargando then
            etiqueta.Text = "..."
            aplicarDeshabilitado()
        else
            etiqueta.Text = config.Text or "Botón"
            aplicarNormal()
        end
    end

    function api.destruir()
        boton:Destroy()
    end

    if deshabilitado then
        api.setDeshabilitado(true)
    end

    -- Parent al final: cada propiedad asignada con el objeto ya en el árbol
    -- provoca un recálculo de layout.
    boton.Parent = config.Parent

    return api
end

return Button
