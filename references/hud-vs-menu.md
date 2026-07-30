# HUD y menú: reglas distintas

Leer cuando la respuesta a la Ronda 1 de la Fase 0 sea "algo permanente en pantalla", o cuando el pedido sea un velocímetro, una barra de vida, un minimapa, un contador, un feed de notificaciones o cualquier cosa que convive con el juego.

Aplicar reglas de menú a un HUD es uno de los errores más comunes y de los más molestos para el jugador: acaba con una interfaz preciosa que le tapa el juego y le roba la atención cada dos segundos.

Contenido:
1. La diferencia de fondo
2. Tabla comparativa
3. Reglas específicas del HUD
4. No bloquear el input
5. Legibilidad sobre un fondo que cambia
6. Zonas seguras
7. Refresco y rendimiento
8. Cuándo ocultarse
9. Jerarquía entre varios elementos de HUD

---

## 1. La diferencia de fondo

Un **menú** tiene el foco del jugador. Ha decidido abrirlo, está mirándolo, y mientras esté ahí el juego puede esperar. Puede ser denso, animado y detallado.

Un **HUD** no tiene el foco. El jugador está mirando el juego y solo consulta el HUD de reojo, durante fracciones de segundo, mientras conduce, corre o dispara. Compite por atención con lo que de verdad importa.

De ahí sale todo lo demás: **el HUD tiene que poder leerse sin ser mirado.**

## 2. Tabla comparativa

| | Menú / panel | HUD permanente |
|---|---|---|
| Atención del jugador | tiene el foco | de reojo, medio segundo |
| Densidad de información | alta, se puede explorar | mínima, solo lo esencial |
| Cantidad de texto | libre | lo menos posible; números y símbolos |
| Tamaño de tipografía | jerarquía completa (12–32) | grande y uniforme (16–28) |
| Animación | de entrada, selección, transiciones | casi ninguna; solo el cambio de valor |
| Interacción | es el objetivo | ninguna, o un solo botón grande |
| Fondo | propio, controlado | el juego, que cambia todo el rato |
| Bloqueo de input | sí, captura los clics | nunca; el clic pasa al juego |
| Presupuesto de instancias | ~300 | bastante menos; compite con el render del juego |
| Refresco | por eventos | continuo pero limitado (~15–20/s) |

## 3. Reglas específicas del HUD

- **Un dato por elemento.** Un velocímetro muestra la velocidad. No la velocidad, más el nombre del vehículo, más la marcha, más el combustible, más la ruta. Si hay que meter todo eso, hay que jerarquizar: el número grande manda y el resto es secundario o va en un panel que se abre.
- **Números legibles de un vistazo.** Peso Bold, alineación estable (que el número no baile al pasar de 99 a 100) y sin decimales innecesarios. `120` se lee; `119.7 km/h` obliga a leer.
- **Ancho fijo para valores cambiantes.** Si el contenedor se ajusta al contenido, el HUD se mueve cada vez que cambia el valor. Reserva el espacio del valor máximo posible y alinea.
- **Nada que parpadee sin motivo.** Un HUD con movimiento constante en la periferia de la visión es agotador. El movimiento se reserva para avisos reales (vida crítica, aviso de peligro).
- **Sin sonido.** Un contador que hace clic cada vez que cambia es insoportable a los dos minutos. Ver `sound-design.md`.
- **Opacidad moderada.** Un HUD ligeramente transparente (fondo al 0.2–0.4) se integra sin tapar. Pero el texto y los números van opacos: la transparencia es para el fondo, nunca para la información.

## 4. No bloquear el input

Esto es lo que más se olvida. Un `Frame` de HUD que cubre parte de la pantalla puede robar los clics que deberían llegar al juego.

- En los contenedores decorativos, `Active = false`. Así el clic atraviesa hacia el mundo.
- No uses `TextButton` ni `ImageButton` para algo que no es un botón: esas clases capturan la entrada por definición.
- Si el HUD tiene un botón de verdad (abrir el menú, activar la bocina), que sea lo más pequeño posible en superficie de captura y esté en una zona donde el jugador no necesite tocar el mundo.
- `Modal = true` en un `GuiButton` fuerza que el cursor aparezca y bloquea el control de la cámara. Eso es para modales, jamás para un HUD.

## 5. Legibilidad sobre un fondo que cambia

El fondo de un menú lo controlas tú. El de un HUD es el juego: cielo blanco, túnel negro, hierba verde, explosión naranja. El mismo texto blanco que se lee perfecto de noche desaparece contra el cielo.

Tres soluciones, de menos a más intrusiva:

1. **`UIStroke` en el texto** — un contorno de 1–2 px del color de fondo del tema. Casi invisible y funciona en cualquier fondo. Es la primera opción.
2. **Una superficie propia** — un `Frame` semitransparente oscuro detrás del dato. Da contraste garantizado a cambio de tapar un poco.
3. **Gradiente de desvanecido** — para HUD pegado a un borde: un `UIGradient` de opaco a transparente hacia el centro de la pantalla. Se integra mejor que un rectángulo con borde.

Nunca dejes texto de HUD sin ninguna de las tres. "En mi mapa se ve bien" no es una prueba.

## 6. Zonas seguras

En un menú a pantalla completa los controles se ocultan y no importa. En un HUD sí:

- **Abajo a la izquierda**: joystick virtual en móvil. Intocable.
- **Abajo a la derecha**: botón de salto en móvil. Intocable.
- **Arriba a la izquierda**: logo de Roblox.
- **Arriba a la derecha**: chat y lista de jugadores.
- **Centro**: donde mira el jugador. Solo para avisos momentáneos, nunca para información permanente.

Queda: las esquinas superiores hacia el centro, los laterales a media altura, y la franja inferior central. Ese es el espacio real de un HUD.

## 7. Refresco y rendimiento

Un HUD se actualiza continuamente, así que es el único sitio de la UI donde un bucle por frame está justificado — pero limitado:

```lua
local ultimo = 0
local ultimoValor = -1

RunService.RenderStepped:Connect(function()
    local ahora = os.clock()
    if ahora - ultimo < 0.05 then  -- ~20 veces por segundo
        return
    end
    ultimo = ahora

    local valor = math.floor(velocidadActual)
    if valor == ultimoValor then
        return  -- no toques .Text si el numero es el mismo
    end
    ultimoValor = valor
    etiqueta.Text = tostring(valor)
end)
```

Las dos guardas importan: la primera limita a 20 actualizaciones por segundo (indistinguible de 60 para un número), y la segunda evita recalcular los límites del texto cuando el valor redondeado no ha cambiado.

Para barras (vida, resistencia, combustible) anima el `Size` con un tween corto en lugar de asignarlo cada frame: se ve mejor y cuesta menos.

## 8. Cuándo ocultarse

Un buen HUD sabe desaparecer:

- Cuando se abre un menú a pantalla completa.
- En cinemáticas o transiciones.
- Cuando el dato no aplica (el velocímetro no tiene sentido si el jugador va a pie).
- Elementos que solo importan en cierto contexto: el indicador de munición mientras hay arma, el de combustible solo en vehículo.

Ocúltalo con transparencia animada, no con `Visible` de golpe: un HUD que aparece y desaparece bruscamente da la sensación de bug. Y si es un elemento que reaparece a menudo, `Visible = false` sobre el contenedor es más barato que destruirlo y reconstruirlo.

## 9. Jerarquía entre varios elementos de HUD

Cuando hay varios (vida, munición, minimapa, notificaciones), tienen que estar ordenados entre sí:

- **Crítico** (vida baja, aviso de peligro): puede usar el centro y puede animarse.
- **Constante** (velocidad, munición, monedas): esquinas, tamaño medio, sin animación.
- **Contextual** (notificaciones, feed de eventos): aparece, se lee y se va sola en 2–4 segundos.

Usa `DisplayOrder` en los `ScreenGui` para controlar qué se dibuja encima cuando coinciden, en lugar de pelear con `ZIndex` entre interfaces distintas. Un aviso crítico tiene que poder pintarse sobre el minimapa.
