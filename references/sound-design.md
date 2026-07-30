# Sonido de interfaz

Leer en la Fase 3, cuando la UI tiene interacción frecuente.

El sonido es la capa de feedback más barata y la que se hace peor. Bien puesto, hace que la interfaz se sienta física y responda antes de que la animación termine. Mal puesto, es lo primero que el jugador silencia — y con él silencia también el audio de tu juego.

Contenido:
1. Los siete sonidos que hacen falta
2. Volúmenes
3. Antimetralleta: el throttle
4. Dónde vive el sonido y cómo se reproduce
5. Móvil y PC no suenan igual
6. Qué NO debe sonar
7. Silencio y accesibilidad
8. De dónde sacar los sonidos

---

## 1. Los siete sonidos que hacen falta

Más que esto es ruido. Menos, y la UI se siente muda.

| Nombre | Cuándo | Carácter |
|---|---|---|
| `Hover` | el cursor entra en un elemento interactivo (solo PC) | brevísimo, casi subliminal |
| `Click` | selección, cambio de pestaña, toque en una tarjeta | seco y corto |
| `Open` | se abre un panel o un modal | ascendente, con cuerpo |
| `Close` | se cierra | descendente, más corto que `Open` |
| `Success` | compra hecha, ajuste guardado, objeto equipado | positivo, dos notas como máximo |
| `Error` | falta saldo, la operación falló | grave, sin ser agresivo |
| `Locked` | se intenta usar algo bloqueado | sordo, "no pasa nada" |

Regla de duración: nada por encima de **300 ms** para `Hover`, `Click` y `Locked`. Si el sonido dura más que la animación que acompaña, llega tarde y se siente desconectado.

`Close` debe sonar más corto y más rápido que `Open`, igual que la animación de cierre es más rápida que la de apertura. Cerrar tiene que sentirse ágil.

## 2. Volúmenes

Punto de partida, ya aplicado en `templates/Sounds.lua`:

```
Hover 0.10   Click 0.22   Open 0.25   Close 0.20
Success 0.30   Error 0.30   Locked 0.18
```

Estos números son bajos a propósito. **Un sonido de UI que se nota es un sonido de UI mal puesto**: acompaña la acción, no la anuncia. Si al probar te parece que apenas se oye, probablemente está bien: recuerda que sonará por encima de la música y los efectos del juego, no en silencio.

El `Hover` es el que más fácil se pasa de volumen, y el que más molesta cuando lo hace, porque se dispara sin que el jugador haya decidido nada.

## 3. Antimetralleta: el throttle

Este es el fallo que arruina el sonido de UI. Pasar el ratón por encima de una lista de doce tarjetas dispara doce sonidos en medio segundo. Suena a error del juego.

La solución es un intervalo mínimo entre reproducciones del mismo sonido:

```lua
local INTERVALO_MINIMO = 0.06
local ultimoUso = {}

function Sounds.reproducir(nombre)
    local ahora = os.clock()
    if ahora - (ultimoUso[nombre] or 0) < INTERVALO_MINIMO then
        return
    end
    ultimoUso[nombre] = ahora
    -- reproducir
end
```

60 ms es suficiente para que un recorrido rápido suene a un solo golpe y para que dos clics deliberados suenen los dos.

Dos reglas más del mismo tipo:

- **No suena el hover del elemento ya seleccionado.** El jugador no está descubriendo nada.
- **No suena el hover al aparecer la UI.** Si el cursor ya está donde aparece un botón, `MouseEnter` se dispara solo. Ignora los eventos de hover durante los primeros 200 ms tras abrir un panel.

## 4. Dónde vive el sonido y cómo se reproduce

- Crea **un `SoundGroup`** para toda la UI y mete los `Sound` dentro. Así el volumen de la interfaz se controla en un solo punto, independiente de la música y los efectos.
- Reproduce con `SoundService:PlayLocalSound(sonido)`. Suena solo para ese jugador, no depende de la posición de la cámara y no se atenúa por distancia como un sonido 3D.
- **Una instancia `Sound` por sonido**, creada la primera vez que se pide y reutilizada. No crees un `Sound` nuevo en cada clic: es el mismo error que crear instancias de GUI en cada refresco (ver `performance.md`).
- Si necesitas que dos copias del mismo sonido se solapen de verdad (raro en UI), clona la instancia y destruye el clon con `Sound.Ended`.

## 5. Móvil y PC no suenan igual

- **En móvil no hay hover.** El sonido de `Hover` simplemente no existe ahí, así que el peso del feedback lo lleva `Click`. Merece la pena que en táctil el `Click` sea ligeramente más presente.
- Muchos jugadores de móvil juegan **en silencio**. El sonido nunca puede ser el único canal de una información: siempre acompaña a un cambio visual.
- Los altavoces de teléfono no reproducen bien los graves. Un `Error` basado solo en una nota grave se pierde; que tenga algo de cuerpo medio.

## 6. Qué NO debe sonar

- El scroll.
- Cada carácter escrito en un `TextBox`.
- La aparición de cada elemento en una animación en cascada. El conjunto lleva **un** sonido, no doce.
- Los cambios de estado que el jugador no provocó (una lista que se refresca sola, un dato que llega del servidor).
- El movimiento de un slider mientras se arrastra. Al soltarlo, sí: un `Click` corto.
- Un HUD permanente. Un contador de velocidad o de vida que hace clic cada vez que cambia es insoportable a los dos minutos.

## 7. Silencio y accesibilidad

- **Siempre debe poder silenciarse**, y el interruptor va en el menú de ajustes, no escondido. Con un `SoundGroup` es una línea: `grupo.Volume = 0`.
- Si añades sonidos de UI, añade también el ajuste. Un juego con sonidos de interfaz y sin forma de apagarlos es peor que uno sin sonidos.
- Guarda la preferencia. Un ajuste que se olvida al reconectar obliga al jugador a silenciarlo cada partida.
- Nada crítico solo por audio: ni la confirmación de una compra, ni un aviso de error.

## 8. De dónde sacar los sonidos

Como con los iconos, **no inventes IDs de audio**. Un ID inventado apunta al audio de otra persona, o a nada.

Opciones reales:

1. **Creator Store de Roblox**, filtrando por Audio. Hay packs de sonidos de interfaz gratuitos y con licencia para usar en experiencias.
2. **Subir los tuyos** desde Create → Manage my Assets → Audio. Ten en cuenta que Roblox limita la distribución de audios subidos según su duración y la configuración de permisos del asset.
3. Bibliotecas de sonido libres externas, comprobando la licencia antes de subir nada.

Mientras no haya IDs, el módulo `Sounds` deja los valores en `rbxassetid://0` y la interfaz funciona en silencio, sin errores en la Output. Eso es deliberado: una UI sin sonido está incompleta, pero una UI que escupe errores de audio está rota.
