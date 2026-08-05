# Seguridad de la interfaz

Leer en la Fase 3 siempre que la interfaz envíe algo al servidor: compras, equipar objetos, guardar ajustes, enviar texto, spawnear cosas.

Contenido:
1. El principio que gobierna todo
2. Qué es la validación de la UI y qué no es
3. Remotos: reglas de oro
4. Entradas de texto
5. Limitación de frecuencia
6. Qué no enviar nunca al cliente
7. Antipatrones concretos
8. Checklist

---

## 1. El principio que gobierna todo

**El cliente no es de confianza. Nunca.**

Un jugador puede modificar su propio cliente con herramientas de terceros. Puede cambiar el valor de un `TextBox`, alterar variables locales, disparar un `RemoteEvent` directamente desde una consola sin pasar por tu interfaz, y enviar los argumentos que quiera. Tu interfaz preciosa no es una barrera: es solo el camino que recorre un jugador honesto.

De ahí sale la única regla que importa: **toda decisión con consecuencias vive en el servidor.** El cliente pide; el servidor decide.

Esto no es paranoia teórica. Un botón de compra que descuenta monedas en el cliente y le dice al servidor "dame el objeto" es dinero infinito para cualquiera con cinco minutos de curiosidad.

## 2. Qué es la validación de la UI y qué no es

La interfaz **sí** debe validar, pero por otra razón: para que el jugador honesto tenga buena experiencia.

| Validación en el cliente | Validación en el servidor |
|---|---|
| Deshabilitar "Comprar" si no alcanza el saldo | Comprobar el saldo antes de cobrar |
| Limitar el `TextBox` a 20 caracteres | Rechazar cualquier texto de más de 20 |
| Ocultar objetos bloqueados | Verificar que el jugador tiene acceso |
| Para qué sirve: evitar errores y frustración | Para qué sirve: que el juego no se pueda romper |

Las dos son necesarias y no se sustituyen. Quitar la del cliente hace la UI molesta; quitar la del servidor hace el juego explotable.

Nunca describas la validación del cliente como una medida de seguridad. No lo es.

## 3. Remotos: reglas de oro

**Valida cada argumento, empezando por el tipo.** Un exploit puede enviar una tabla donde esperas un número, o `nil` donde esperas texto.

```lua
comprarRemote.OnServerEvent:Connect(function(jugador, idObjeto)
    -- 1. Tipo
    if type(idObjeto) ~= "string" then
        return
    end

    -- 2. Existencia: el objeto tiene que estar en TU catalogo,
    -- no basta con que el cliente diga que existe
    local objeto = Catalogo[idObjeto]
    if not objeto then
        return
    end

    -- 3. Estado real del jugador, leido en el servidor
    local saldo = obtenerSaldo(jugador)
    if saldo < objeto.Precio then
        return
    end

    -- 4. Reglas del juego
    if yaLoTiene(jugador, idObjeto) then
        return
    end

    -- Solo ahora se aplica el efecto
    descontarSaldo(jugador, objeto.Precio)
    entregarObjeto(jugador, idObjeto)
end)
```

**El precio nunca viaja desde el cliente.** El cliente manda *qué* quiere comprar, no *cuánto* cuesta. Si el cliente envía el precio, puede enviar cero.

**Deriva en el servidor todo lo que se pueda derivar.** Si el servidor puede saber quién es el jugador, qué tiene equipado o en qué zona está, no lo preguntes al cliente.

**El primer parámetro (`jugador`) lo pone Roblox y es fiable.** Nunca aceptes un identificador de jugador como argumento: sería permitir actuar en nombre de otro.

**Cuidado con `RemoteFunction` invocada al cliente.** `InvokeClient` deja al servidor esperando una respuesta que el cliente puede no devolver nunca. Para comunicación servidor → cliente, `RemoteEvent`.

## 4. Entradas de texto

Cualquier `TextBox` es una puerta. Tres capas:

**En el cliente**, por comodidad:

```lua
entrada.MaxVisibleGraphemes = 20

entrada:GetPropertyChangedSignal("Text"):Connect(function()
    if #entrada.Text > 20 then
        entrada.Text = string.sub(entrada.Text, 1, 20)
    end
end)
```

**En el servidor**, por seguridad. Longitud, tipo y contenido:

```lua
local function textoValido(texto)
    if type(texto) ~= "string" then
        return false
    end
    if #texto == 0 or #texto > 20 then
        return false
    end
    -- Lista blanca: solo lo que esperas, en vez de intentar
    -- enumerar todo lo que quieres prohibir
    if not string.match(texto, "^[%w%s]+$") then
        return false
    end
    return true
end
```

Lista blanca, no lista negra. Enumerar lo permitido es corto y completo; enumerar lo prohibido siempre deja huecos.

**Filtrado de Roblox**, obligatorio para cualquier texto de un jugador que otro jugador vaya a ver: nombres personalizados, mensajes, etiquetas de vehículo.

```lua
local TextService = game:GetService("TextService")

local function filtrarParaTodos(texto, jugador)
    local resultado
    local exito = pcall(function()
        resultado = TextService:FilterStringAsync(texto, jugador.UserId)
    end)

    if not exito or not resultado then
        return nil   -- si el filtro falla, NO se muestra el texto
    end

    return resultado:GetNonChatStringForBroadcastAsync()
end
```

Dos cosas que se hacen mal a menudo: envolver siempre en `pcall` (el servicio puede fallar), y que **si el filtro falla no se muestre nada**. Mostrar el texto sin filtrar "porque el filtro no respondió" es exactamente el caso que el filtro existía para cubrir.

La búsqueda local dentro de tu propia lista no necesita filtrado: no sale del cliente ni la ve nadie más.

## 5. Limitación de frecuencia

Un botón se puede pulsar rápido; un exploit puede llamar al remoto miles de veces por segundo. Sin límite, eso tumba el servidor o multiplica recompensas.

```lua
local ultimoUso = {}
local INTERVALO = 0.5

local function permitido(jugador)
    local ahora = os.clock()
    if ahora - (ultimoUso[jugador.UserId] or 0) < INTERVALO then
        return false
    end
    ultimoUso[jugador.UserId] = ahora
    return true
end

remoto.OnServerEvent:Connect(function(jugador, ...)
    if not permitido(jugador) then
        return
    end
    -- ...
end)

game:GetService("Players").PlayerRemoving:Connect(function(jugador)
    ultimoUso[jugador.UserId] = nil   -- sin esto, la tabla crece para siempre
end)
```

En el cliente, bloquea el botón mientras la operación está en curso (el estado **cargando** de `states.md`). Eso evita el doble clic honesto; el límite del servidor evita el resto.

## 6. Qué no enviar nunca al cliente

Todo lo que llega al cliente es visible para el jugador, aunque tu interfaz no lo muestre.

- Datos de otros jugadores que no deberían ser públicos.
- La tabla completa de probabilidades de un sistema de recompensas aleatorias, si la sorpresa importa. El sorteo se hace en el servidor.
- Posiciones de objetos ocultos, respuestas de un puzle, contenido no desbloqueado.
- Cualquier clave, endpoint o credencial.

Regla práctica: si lo pones en `ReplicatedStorage` o lo mandas por un remoto, considéralo público.

## 7. Antipatrones concretos

**Comprar con el precio que manda el cliente**
```lua
-- MAL
comprar:FireServer(idObjeto, precio)
```
El cliente envía `precio = 0`. Manda solo el identificador.

**Descontar en el cliente y avisar al servidor**
```lua
-- MAL
saldoLocal = saldoLocal - precio
darObjeto:FireServer(idObjeto)
```
El servidor descuenta; el cliente solo refleja el resultado.

**Confiar en que el botón estaba deshabilitado**
Un botón bloqueado en la UI no impide llamar al remoto. La comprobación se repite en el servidor.

**Guardar ajustes sin validar**
```lua
-- MAL
guardarAjustes.OnServerEvent:Connect(function(jugador, ajustes)
    datos[jugador.UserId] = ajustes
end)
```
Eso acepta cualquier tabla, de cualquier tamaño, con cualquier contenido, y va directo a tu almacenamiento. Valida clave por clave, con tipos y rangos.

**Mostrar texto de un jugador sin filtrar**
Aunque sea "solo el nombre del autobús".

**Un remoto que hace de todo**
Un `EjecutarAccion:FireServer(nombreFuncion, argumentos)` es una puerta abierta. Un remoto por acción, con sus argumentos concretos.

## 8. Checklist

- [ ] Ningún precio, cantidad o recompensa viaja desde el cliente.
- [ ] Cada remoto valida tipo, existencia y reglas del juego antes de aplicar nada.
- [ ] Ningún remoto acepta un identificador de jugador como argumento.
- [ ] Todo `TextBox` tiene límite en cliente y validación por lista blanca en servidor.
- [ ] Todo texto de un jugador visible para otros pasa por el filtro de Roblox, con `pcall`, y no se muestra si el filtro falla.
- [ ] Los remotos llamables desde botones tienen limitación de frecuencia, y la tabla se limpia al salir el jugador.
- [ ] No se envía al cliente nada que el jugador no deba poder ver.
- [ ] La interfaz valida para la experiencia, y eso está descrito como comodidad, nunca como seguridad.
