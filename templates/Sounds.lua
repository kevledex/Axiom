-- Sounds: todos los sonidos de interfaz en un solo sitio.
--
-- Igual que con Icons, aquí NO hay IDs inventados. Sube tus sonidos a Roblox
-- (o cógelos del Creator Store) y pega los IDs. Mientras un ID valga
-- "rbxassetid://0", ese sonido simplemente no suena: la UI funciona igual,
-- sin errores en la Output ni silencios raros a medias.
--
-- Uso:
--   local Sounds = require(pantalla.Configuration.Sounds)
--   Sounds.reproducir("Hover")
--   Sounds.setSilencio(true)   -- desde el menú de ajustes

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

-- Volúmenes bajos a propósito. Un sonido de UI que se nota es un sonido
-- de UI mal puesto: acompaña la acción, no la anuncia.
local VOLUMENES = {
    Hover = 0.10,
    Click = 0.22,
    Open = 0.25,
    Close = 0.20,
    Success = 0.30,
    Error = 0.30,
    Locked = 0.18,
}

-- Sin esto, recorrer una lista con el ratón dispara veinte sonidos por segundo
-- y suena a metralleta.
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

-- Se crea una sola instancia por sonido, la primera vez que se pide.
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

    -- PlayLocalSound suena solo para este jugador y no depende de donde
    -- esté el sonido en el árbol ni de la posición de la cámara.
    SoundService:PlayLocalSound(sonido)
end

function Sounds.setSilencio(silenciado)
    grupo.Volume = silenciado and 0 or 1
end

function Sounds.estaSilenciado()
    return grupo.Volume == 0
end

-- Útil para no mostrar el ajuste de sonidos si todavía no hay ninguno puesto.
function Sounds.estaConfigurado()
    for _, id in pairs(Sounds.Ids) do
        if not esPlaceholder(id) then
            return true
        end
    end
    return false
end

return Sounds
