-- ProgressBar: barra de progreso con máximo SIEMPRE explícito.
--
-- Existe por un fallo concreto: las barras de estadísticas se construían
-- asignando un Size a ojo, sin fórmula de valor/máximo. Resultado: todas
-- salían casi llenas sin importar el dato real, y la barra dejaba de
-- comunicar nada. Aquí el máximo es obligatorio y la proporción se calcula
-- siempre igual.
--
-- Uso:
--   local ProgressBar = require(ruta.Components.ProgressBar)
--
--   local velocidad = ProgressBar.new({
--       Etiqueta = "Velocidad",
--       Valor = 170,
--       Maximo = 250,              -- obligatorio
--       Unidad = "km/h",
--       Parent = panelStats,
--   })
--
--   velocidad.setValor(210)
--
-- Para vida, resistencia o carga, el mismo componente con Maximo distinto.

local TweenService = game:GetService("TweenService")

local Configuration = script.Parent.Parent.Configuration
local Theme = require(Configuration.Theme)

local ProgressBar = {}

local function animar(objeto, duracion, propiedades)
    local info = TweenInfo.new(duracion, Theme.Animation.Style, Theme.Animation.Direction)
    local tween = TweenService:Create(objeto, info, propiedades)
    tween:Play()
    return tween
end

-- Umbrales discretos: un gradiente continuo no se distingue de reojo.
-- Solo se aplican si el componente se crea con UsarUmbrales = true.
local function colorParaProporcion(proporcion)
    if proporcion > 0.5 then
        return Theme.Colors.Success
    elseif proporcion > 0.25 then
        return Theme.Colors.Warning
    end
    return Theme.Colors.Danger
end

function ProgressBar.new(config)
    config = config or {}

    -- El maximo no tiene valor por defecto a proposito. Una barra sin maximo
    -- no puede representar nada, y un 100 implicito es justo el bug que este
    -- componente evita.
    assert(
        type(config.Maximo) == "number" and config.Maximo > 0,
        "ProgressBar necesita un Maximo numerico mayor que cero"
    )

    local maximo = config.Maximo
    local valor = math.clamp(config.Valor or 0, 0, maximo)
    local usarUmbrales = config.UsarUmbrales == true
    local alturaBarra = config.AlturaBarra or 6

    local contenedor = Instance.new("Frame")
    contenedor.Name = config.Name or "ProgressBar"
    contenedor.BackgroundTransparency = 1
    contenedor.Size = config.Size or UDim2.new(1, 0, 0, 34)
    contenedor.LayoutOrder = config.LayoutOrder or 0

    local columna = Instance.new("UIListLayout")
    columna.FillDirection = Enum.FillDirection.Vertical
    columna.Padding = UDim.new(0, Theme.Spacing.XSmall)
    columna.SortOrder = Enum.SortOrder.LayoutOrder
    columna.Parent = contenedor

    -- Fila superior: etiqueta a la izquierda, valor a la derecha
    local cabecera = Instance.new("Frame")
    cabecera.Name = "Header"
    cabecera.BackgroundTransparency = 1
    cabecera.Size = UDim2.new(1, 0, 0, 16)
    cabecera.LayoutOrder = 1
    cabecera.Parent = contenedor

    local etiqueta = Instance.new("TextLabel")
    etiqueta.Name = "Etiqueta"
    etiqueta.BackgroundTransparency = 1
    etiqueta.Text = config.Etiqueta or ""
    etiqueta.TextColor3 = Theme.Colors.TextSecondary
    etiqueta.FontFace = Theme.fuente(Theme.Weights.Medium)
    etiqueta.TextSize = Theme.Text.Label
    etiqueta.TextXAlignment = Enum.TextXAlignment.Left
    etiqueta.TextTruncate = Enum.TextTruncate.AtEnd
    etiqueta.Size = UDim2.new(1, -70, 1, 0)
    etiqueta.Parent = cabecera

    -- Ancho fijo para que el numero no desplace nada al cambiar de magnitud
    local lectura = Instance.new("TextLabel")
    lectura.Name = "Valor"
    lectura.BackgroundTransparency = 1
    lectura.TextColor3 = Theme.Colors.TextPrimary
    lectura.FontFace = Theme.fuente(Theme.Weights.Bold)
    lectura.TextSize = Theme.Text.Label
    lectura.TextXAlignment = Enum.TextXAlignment.Right
    lectura.Size = UDim2.new(0, 70, 1, 0)
    lectura.Position = UDim2.new(1, 0, 0, 0)
    lectura.AnchorPoint = Vector2.new(1, 0)
    lectura.Parent = cabecera

    -- Riel
    local riel = Instance.new("Frame")
    riel.Name = "Riel"
    riel.BackgroundColor3 = Theme.Colors.Surface
    riel.BorderSizePixel = 0
    riel.Size = UDim2.new(1, 0, 0, alturaBarra)
    riel.LayoutOrder = 2
    riel.ClipsDescendants = true
    riel.Parent = contenedor

    local esquinaRiel = Instance.new("UICorner")
    esquinaRiel.CornerRadius = UDim.new(0, math.floor(alturaBarra / 2))
    esquinaRiel.Parent = riel

    local relleno = Instance.new("Frame")
    relleno.Name = "Relleno"
    relleno.BackgroundColor3 = config.Color or Theme.Colors.Primary
    relleno.BorderSizePixel = 0
    relleno.Size = UDim2.fromScale(0, 1)
    relleno.Parent = riel

    local esquinaRelleno = Instance.new("UICorner")
    esquinaRelleno.CornerRadius = UDim.new(0, math.floor(alturaBarra / 2))
    esquinaRelleno.Parent = relleno

    -- Logica ---------------------------------------------------------------

    local function textoDeValor()
        local numero = math.floor(valor + 0.5)
        if config.Unidad then
            return tostring(numero) .. " " .. config.Unidad
        end
        if config.MostrarMaximo then
            return tostring(numero) .. "/" .. tostring(math.floor(maximo))
        end
        return tostring(numero)
    end

    local function pintar(animado)
        -- La unica formula: valor entre maximo, acotada. Nunca un Size a ojo.
        local proporcion = math.clamp(valor / maximo, 0, 1)
        local destino = UDim2.fromScale(proporcion, 1)

        if animado then
            animar(relleno, Theme.Animation.Normal, { Size = destino })
        else
            relleno.Size = destino
        end

        if usarUmbrales then
            local color = colorParaProporcion(proporcion)
            if animado then
                animar(relleno, Theme.Animation.Fast, { BackgroundColor3 = color })
            else
                relleno.BackgroundColor3 = color
            end
        end

        lectura.Text = textoDeValor()
    end

    pintar(false)

    local api = {}
    api.Instance = contenedor

    function api.setValor(nuevo)
        valor = math.clamp(tonumber(nuevo) or 0, 0, maximo)
        pintar(true)
    end

    -- Cambiar el maximo tambien es legitimo (subir de nivel, mejorar el
    -- deposito), pero sigue siendo explicito.
    function api.setMaximo(nuevo)
        nuevo = tonumber(nuevo)
        assert(nuevo and nuevo > 0, "El maximo debe ser un numero mayor que cero")
        maximo = nuevo
        valor = math.clamp(valor, 0, maximo)
        pintar(true)
    end

    function api.getProporcion()
        return valor / maximo
    end

    function api.destruir()
        contenedor:Destroy()
    end

    contenedor.Parent = config.Parent

    return api
end

return ProgressBar
