# Patrones visuales por género

Leer en la Fase 1, cuando ya se sabe qué género es el juego pero todavía no hay dirección visual.

Estas no son recetas para copiar. Son los patrones que se han consolidado en cada género porque **resuelven un problema concreto de ese género**. Entender el problema es lo que permite adaptarlos en lugar de imitarlos.

Contenido:
1. Cómo usar este documento
2. Simulador de colección e idle
3. Tycoon y gestión
4. Roleplay y hangout social
5. Obby y parkour competitivo
6. Tower defense
7. Combate y shooter
8. Horror y supervivencia
9. Conducción y transporte
10. Números grandes: el problema transversal
11. Cómo tomar prestado sin copiar

---

## 1. Cómo usar este documento

Los géneros dominantes en Roblox no coinciden con los de consola: aquí manda el simulador de colección, el roleplay, el obby, el tower defense, el horror y el combate. Un juego de Roblox compite por la atención de un público que juega mayoritariamente en móvil, en sesiones cortas, y que salta de experiencia en experiencia. Eso condiciona la UI más que cualquier tendencia estética.

Dos advertencias antes de seguir:

- **El género informa, no dicta.** Si tu simulador quiere sentirse sobrio y adulto, puedes romper con el patrón chillón del género. Pero rómpelo a propósito y sabiendo qué función cumplía lo que estás quitando.
- **Los patrones más repetidos de un género suelen ser los más funcionales, y a la vez los que más aburren.** El objetivo es cumplir la función con una identidad propia, no reproducir el aspecto.

## 2. Simulador de colección e idle

Mascotas, huevos, mejoras, multiplicadores. El bucle es recoger, mejorar, recoger más rápido.

**Qué siente el jugador:** progreso constante. Cada pocos segundos algo sube.

**El problema de UI del género:** hay que comunicar cantidad, rareza y progreso simultáneamente, sin parar, y con números que crecen sin límite.

**Patrones consolidados:**

- **Contadores permanentes en pantalla**, arriba: moneda principal, moneda premium, multiplicador activo. Son el corazón del bucle y no pueden esconderse en un menú.
- **Rareza por color, con escala fija y aprendible.** Común → poco común → raro → épico → legendario → mítico. Una vez que el jugador aprende que el dorado es lo mejor, ese código no se puede cambiar.
- **Rareza reforzada por más de un canal**: color del borde, brillo del fondo, partículas, y el nombre coloreado. En este género es aceptable ser más llamativo de lo normal, porque el momento de conseguir algo raro *es* la recompensa.
- **Barra de progreso hacia lo siguiente**, siempre visible. El jugador nunca debe preguntarse cuánto le falta.
- **Feedback numérico flotante** en cada recogida (ver `examples/DamageNumbers.md`, misma técnica).

**Registro visual habitual:** saturado, brillante, gradientes marcados, esquinas muy redondeadas, tipografía redonda y gruesa.

**Antipatrón del género:** que *todo* brille. Cuando el borde común también tiene resplandor, el legendario deja de significar nada. Reserva los efectos fuertes para la parte alta de la escala y deja lo común deliberadamente sobrio.

**Adaptación con criterio:** mantén la escala de rareza y los contadores permanentes, y baja el ruido en todo lo demás. Un simulador con UI limpia y solo el legendario brillando se distingue del resto del género de inmediato.

## 3. Tycoon y gestión

Construir, expandir, optimizar. El jugador toma decisiones de inversión.

**Qué siente el jugador:** control y planificación.

**El problema de UI del género:** mostrar coste, beneficio y estado de muchos elementos a la vez, para que se puedan comparar decisiones.

**Patrones consolidados:**

- **Tarjeta de compra con coste, efecto y estado**: "Cinta transportadora — 2.500 — +12/s". Los tres datos juntos, siempre en el mismo orden.
- **Colores de estado inequívocos**: comprable, no alcanzable, ya comprado, bloqueado por requisito. Cuatro estados, cuatro tratamientos.
- **Números alineados a la derecha** en cualquier lista comparable. Es lo que permite comparar sin leer.
- **Indicador de ingresos por segundo** permanente: es el dato que valida cada decisión del jugador.
- **Árbol o ruta de progresión** visible, aunque sea simplificada. El jugador quiere ver hacia dónde va.

**Registro visual habitual:** más sobrio que el simulador. Superficies planas, tipografía neutra, densidad de datos alta, acento único.

**Antipatrón del género:** paneles de texto largos explicando cada mejora. Nadie los lee. Un icono, un número y una línea de efecto.

## 4. Roleplay y hangout social

Casas, trabajos, avatares, vida social. No hay condición de victoria.

**Qué siente el jugador:** expresión personal y pertenencia.

**El problema de UI del género:** la interfaz tiene que apartarse. El contenido son los demás jugadores y el mundo, no la UI.

**Patrones consolidados:**

- **HUD mínimo**: casi nada permanente. Un botón de menú, quizá el dinero.
- **Menús que se abren desde iconos discretos**, agrupados en una barra lateral o inferior, con la mayoría del espacio para el juego.
- **Personalización con vista previa inmediata.** Cambiar el color de una camiseta y verlo al instante, sin confirmar.
- **Rueda de emotes** (ver `examples/RadialMenu.md`): es el género donde este patrón tiene más sentido, porque se usa constantemente y sin dejar de moverse.
- **Catálogos con imágenes grandes y poco texto.** El jugador elige por aspecto, no por estadísticas.

**Registro visual habitual:** claro, suave, amable. Es uno de los pocos casos donde una paleta clara funciona mejor que una oscura, porque acompaña el tono acogedor.

**Antipatrón del género:** un HUD de shooter en un juego de convivir. Barras, contadores y avisos constantes rompen por completo la sensación de estar habitando un lugar.

## 5. Obby y parkour competitivo

Saltar, caer, repetir. Habilidad pura, sesiones cortas, tensión constante.

**Qué siente el jugador:** urgencia y comparación con otros.

**El problema de UI del género:** el jugador está mirando la plataforma siguiente. Cualquier cosa en el centro de la pantalla es un estorbo activo que le hace fallar.

**Patrones consolidados:**

- **Temporizador grande y periférico.** Arriba centro o arriba derecha, nunca en el camino visual.
- **Progreso de la etapa** ("Etapa 14/30") como texto compacto, no como barra que ocupe ancho.
- **Marcador lateral con los primeros puestos**, muy comprimido. Es el motor social del género.
- **Feedback de checkpoint inmediato**: un destello corto y un sonido. Nada que interrumpa el movimiento.
- **Pantalla de muerte casi inexistente.** Reaparecer tiene que ser instantáneo; una animación de medio segundo al morir se convierte en minutos de espera acumulada.

**Registro visual habitual:** alto contraste, colores muy saturados que se distingan del entorno, tipografía condensada, cero decoración.

**Antipatrón del género:** un panel de resultados con animación de tres segundos cada vez que el jugador cae. En un juego donde se muere cuarenta veces por partida, cada interrupción se multiplica por cuarenta.

## 6. Tower defense

Colocar unidades, gestionar oleadas, ver números subir.

**Qué siente el jugador:** tensión creciente y decisión bajo presión.

**El problema de UI del género:** el jugador necesita decidir rápido mientras la partida no se detiene, con información de coste, alcance y estado de muchas unidades.

**Patrones consolidados:**

- **Barra inferior de unidades disponibles** con coste visible y estado de asequibilidad. Es el elemento más usado de toda la interfaz: va donde llega el pulgar.
- **Indicador de oleada y cuenta atrás** siempre visible, arriba.
- **Vista previa de alcance** al seleccionar una unidad, antes de colocarla. Nunca obligues a comprar para descubrir el alcance.
- **Panel de unidad seleccionada** con mejora y venta, que aparece pegado a la unidad o en un lateral fijo, sin tapar el campo.
- **Aviso de oleada especial o jefe**: es el momento en que el HUD tiene permiso para interrumpir.

**Registro visual habitual:** oscuro para que las unidades y los efectos destaquen, acento cálido para la moneda, iconos muy legibles a tamaño pequeño.

**Antipatrón del género:** paneles que tapan el camino de los enemigos. En este género el espacio de juego es sagrado; toda la UI se pega a los bordes.

## 7. Combate y shooter

Habilidad, reflejos, enfrentamiento directo.

**Qué siente el jugador:** precisión y consecuencia inmediata.

**El problema de UI del género:** información crítica (vida, munición, enfriamientos) que hay que leer en fracciones de segundo, sin apartar la vista del centro.

**Patrones consolidados:**

- **Información crítica en las esquinas inferiores**, cerca del centro de atención pero fuera de él.
- **Enfriamientos como arcos o barras sobre el icono de la habilidad.** El jugador aprende la forma, no lee el número.
- **Feedback de impacto separado del HUD**: marca de acierto en la mira, números de daño en el mundo (ver `examples/DamageNumbers.md`), viñeta al recibir daño.
- **Estado crítico con canal doble**: la barra roja *y* la viñeta en los bordes. Uno solo no basta cuando el jugador está concentrado en apuntar.
- **Nada de animaciones de entrada en el HUD.** Aparece ya puesto.

**Registro visual habitual:** oscuro, radios pequeños o rectos, tipografía técnica, un acento frío para el equipo propio y uno cálido para el enemigo.

**Antipatrón del género:** decoración en el HUD. Marcos ornamentados, gradientes, brillos. Cada píxel decorativo compite con información que puede costar la partida.

## 8. Horror y supervivencia

Tensión, escasez, incertidumbre.

**Qué siente el jugador:** vulnerabilidad.

**El problema de UI del género:** la interfaz no debe romper la atmósfera, pero el jugador necesita saber su estado.

**Patrones consolidados:**

- **HUD que aparece solo cuando importa.** La cordura o la batería no están siempre en pantalla: se muestran al cambiar y se desvanecen.
- **Diegético cuando se puede**: la batería de la linterna en la propia linterna, el inventario como una mochila real. Integrar la información en el mundo en lugar de superponerla.
- **Paleta muy reducida.** Un solo acento, casi siempre cálido y sucio, sobre negros y grises fríos.
- **Sin animaciones alegres.** Nada de rebotes ni escalas juguetonas. Fundidos lentos.
- **Tipografía con carácter**, pero solo en títulos; el cuerpo sigue siendo legible.

**Registro visual habitual:** casi monocromo, radios rectos, transparencias altas, ruido o grano sutil.

**Antipatrón del género:** un toast redondeado y colorido diciendo "¡Objeto conseguido!" en medio de una escena de tensión. Rompe en un segundo lo que la ambientación construyó en diez minutos.

## 9. Conducción y transporte

Vehículos, rutas, velocidad, gestión de flota.

**Qué siente el jugador:** competencia técnica y progresión material.

**El problema de UI del género:** dos contextos muy distintos con la misma identidad visual: el HUD mientras conduce y los menús de gestión cuando está parado.

**Patrones consolidados:**

- **HUD de conducción minimalista**: velocidad, marcha, y poco más (ver `examples/Speedometer.md`).
- **Selector de vehículos con estadísticas comparables**: velocidad, capacidad, aceleración como barras normalizadas, no como números sueltos. Las barras se comparan de un vistazo; "0-100 en 8.4 s" no.
- **Vista previa del vehículo**, idealmente en 3D con `ViewportFrame`. Es el género donde el coste de un `ViewportFrame` está justificado, porque el aspecto del vehículo *es* la decisión — pero uno visible a la vez, nunca uno por tarjeta.
- **Estado de propiedad claro**: comprado, equipado, comprable, bloqueado por nivel.
- **Información de ruta o destino** durante la conducción, discreta y en un lateral.

**Registro visual habitual:** industrial y técnico. Fondos oscuros con tinte frío, acento ámbar o cian (los colores de la señalización real), radios pequeños, tipografía neutra, datos tabulados.

**Antipatrón del género:** tratar el selector de vehículos como un catálogo de moda, con imágenes grandes y ninguna estadística. En este género el jugador quiere comparar prestaciones, no solo mirar.

## 10. Números grandes: el problema transversal

Los simuladores de Roblox llegan a cifras absurdas (billones, cuatrillones) y eso rompe cualquier layout que no lo previera. Reglas:

- **Abrevia siempre en listas**: `1.2 K`, `450 M`, `3.7 B`, `82 T`. El número exacto solo en el detalle.
- **Sufijos consistentes en todo el juego.** Si eliges `K/M/B/T`, no mezcles con `mil/millón`.
- **Un decimal como máximo.** `1.2 M` sí; `1.24 M` no aporta y ocupa más.
- **Ancho reservado para el máximo posible.** Si el contenedor se ajusta al contenido, el HUD baila cada vez que el jugador cruza un umbral.
- **Alineación a la derecha** en cualquier columna comparable.

```lua
local SUFIJOS = { "", "K", "M", "B", "T", "Qa", "Qi" }

local function abreviar(numero)
    local indice = 1
    while numero >= 1000 and indice < #SUFIJOS do
        numero = numero / 1000
        indice = indice + 1
    end

    if indice == 1 then
        return tostring(math.floor(numero))
    end
    return string.format("%.1f", numero) .. SUFIJOS[indice]
end
```

## 11. Cómo tomar prestado sin copiar

La forma correcta de aprender de un juego que te gusta:

1. **Analiza la estructura, no la estética.** ¿Qué información hay en pantalla? ¿En qué orden se lee? ¿Qué está siempre visible y qué está a un toque? Eso es lo transferible.
2. **Pregúntate qué problema resuelve cada elemento.** Si un juego pone el saldo arriba a la derecha, es porque el jugador lo consulta antes de cada compra. Ese razonamiento sirve para tu juego; la posición exacta y el color, no necesariamente.
3. **Copia decisiones, no valores.** "Un solo acento cálido sobre fondo oscuro" es una decisión. `Color3.fromRGB(255, 176, 32)` es un valor que pertenece a otro juego.
4. **Cambia al menos tres cosas de fondo**: la paleta, el registro de forma y la tipografía. Con eso, dos UIs con la misma estructura se ven como de juegos distintos.
5. **No reproduzcas assets, marcas, logotipos ni personajes de otros juegos.** Aparte del problema legal, es la forma más rápida de que tu juego parezca una imitación en lugar de una alternativa.

El objetivo declarado de esta skill es que la UI no parezca hecha por una IA ni copiada de un tutorial. Reproducir la estética de un juego popular falla en lo segundo aunque el código sea impecable.
