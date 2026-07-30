-- Icons: todos los IDs de imagen en un solo sitio.
-- Sube tus iconos a Roblox (Create > Manage my Assets > Images) y pega aquí los IDs.
-- Mientras un icono valga "rbxassetid://0", la UI mostrará un cuadro de relleno
-- en lugar de una imagen roto, gracias a Icons.esPlaceholder().
--
-- Consejo: si subes los iconos en blanco puro, puedes teñirlos desde el Theme con
-- ImageLabel.ImageColor3 y reutilizar el mismo asset en todos los estados.

local Icons = {
    -- Navegación
    Home = "rbxassetid://0",
    Back = "rbxassetid://0",
    Close = "rbxassetid://0",
    ChevronDown = "rbxassetid://0",

    -- Acciones
    Search = "rbxassetid://0",
    Settings = "rbxassetid://0",
    Filter = "rbxassetid://0",
    Buy = "rbxassetid://0",

    -- Estados
    Lock = "rbxassetid://0",
    Check = "rbxassetid://0",
    Warning = "rbxassetid://0",
    Empty = "rbxassetid://0",

    -- Específicos del juego (renombra según tu proyecto)
    Bus = "rbxassetid://0",
    Coin = "rbxassetid://0",
    Speed = "rbxassetid://0",
    Seats = "rbxassetid://0",
}

-- Sombra reutilizable de Roblox, útil para dar profundidad a paneles y tarjetas.
-- Usar con ScaleType = Slice y SliceCenter = Rect.new(10, 10, 118, 118)
Icons.Shadow = "rbxassetid://1316045217"

function Icons.esPlaceholder(id)
    return id == nil or id == "" or id == "rbxassetid://0"
end

-- Devuelve el ID si existe, o una cadena vacía para que el ImageLabel
-- no intente cargar un asset inválido.
function Icons.obtener(nombre)
    local id = Icons[nombre]
    if type(id) ~= "string" or Icons.esPlaceholder(id) then
        return ""
    end
    return id
end

return Icons
