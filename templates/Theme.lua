-- Theme: única fuente de verdad del diseño.
-- Ningún otro archivo debe escribir colores, espaciados, radios o duraciones a mano.
-- Adapta los valores a la dirección visual del proyecto; no uses esta paleta tal cual.

local Theme = {}

-- Paleta base: dirección "industrial / transporte".
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
    Success = Color3.fromRGB(90, 200, 130),
    Warning = Color3.fromRGB(240, 180, 60),
    Danger = Color3.fromRGB(230, 90, 90),
}

-- Múltiplos de 4. No inventes valores intermedios.
Theme.Spacing = {
    XSmall = 4,
    Small = 8,
    Medium = 16,
    Large = 24,
    XLarge = 32,
}

-- Un solo registro de forma en toda la UI.
Theme.Radius = {
    Small = 4,
    Medium = 8,
    Large = 12,
    Pill = 999,
}

-- Nada por encima de 0.45 s.
Theme.Animation = {
    Fast = 0.12,
    Normal = 0.25,
    Slow = 0.35,
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

Theme.Weights = {
    Regular = Enum.FontWeight.Regular,
    Medium = Enum.FontWeight.Medium,
    SemiBold = Enum.FontWeight.SemiBold,
    Bold = Enum.FontWeight.Bold,
}

-- Breakpoints por ancho de pantalla, en píxeles.
Theme.Breakpoints = {
    Compacto = 600,
    Medio = 1000,
}

-- Devuelve una fuente lista para asignar a TextLabel.FontFace
function Theme.fuente(peso)
    return Font.new(Theme.Text.Family, peso)
end

-- Devuelve "Compacto", "Medio" o "Amplio" según un ancho dado.
function Theme.modoDePantalla(ancho)
    if ancho < Theme.Breakpoints.Compacto then
        return "Compacto"
    elseif ancho < Theme.Breakpoints.Medio then
        return "Medio"
    end
    return "Amplio"
end

return Theme
