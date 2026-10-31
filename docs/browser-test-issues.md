# Browser test issues

Registro de errores observados en una prueba corta del cliente WASM contra el
stack de OpenMU. Sirve como lista de trabajo para corregirlos poco a poco.

## Entorno de la prueba

- Cliente: MuMain compilado a WebAssembly, servido en `http://localhost:8085`.
- Servidor: OpenMU en Docker + proxy WebSocket-TCP (`:7100`) + PostgreSQL.
- Cuenta: `test400` / `test400`; personaje: `test400Dk`.
- Mapa: Lorencia.
- Fecha: 2026-10-31.
- Nota: la prueba se hizo **después** de corregir la versión de cliente
  (`Season 106 Episode 3`) y el serializador extendido de items. Varios fallos
  pueden venir de que el servidor ahora usa variantes "extended" del protocolo
  que el cliente todavía no interpreta del todo.

## Resumen

| ID | Título | Área | Severidad | Estado |
|----|--------|------|-----------|--------|
| BUG-001 | No hay recarga automática de vida | Cliente / servidor | Media | Abierto |
| BUG-002 | La tecla `M` no abre el mapa de transporte | Cliente (input/UI) | Media | Abierto |
| BUG-003 | No se envían mensajes por el chat | Cliente (input/red) | Alta | Corregido (pendiente de probar) |
| BUG-004 | El botón `+` de estadísticas no sube puntos | Cliente (UI/red) | Alta | Corregido (pendiente de probar) |
| BUG-005 | No se puede desequipar un item; queda anclado al cursor | Cliente (inventario/red) | Alta | Corregido (pendiente de probar) |
| BUG-006 | El menú de escape: Switch Character / Select Server no hacen nada; Exit Game se comporta raro | Cliente (UI/escenas) | Media | Corregido (pendiente de probar) |
| BUG-007 | NPCs y monstruos de Lorencia no aparecen (spawn correcto en servidor) | Cliente (protocolo/viewport) | Alta | Corregido |
| BUG-008 | Al hacer clic en un NPC no se abre el diálogo ni ocurre ninguna acción | Cliente (protocolo/NPC) | Alta | Corregido (pendiente de probar) |
| BUG-009 | Comprar, vender, reparar o pedir buff a un NPC no hace nada | Cliente (protocolo/NPC) | Alta | Corregido (pendiente de probar) |

## BUG-001 — No hay recarga automática de vida

**Síntomas.** El HP no sube con el tiempo; se queda en el valor con el que entró
el personaje (o en el que quedó tras recibir daño).

**Pasos.** Entrar al mundo con `test400Dk`, recibir daño y esperar sin hacer nada.

**Esperado.** OpenMU regenera HP/MP periódicamente y el cliente refleja el nuevo
valor.

**Actual.** La barra de vida no cambia.

**Pistas / hipótesis.**

- El cliente sí tiene manejadores para actualizaciones de stats:
  - `ReceiveStatsExtended` en `src/source/Network/Server/WSclient.cpp` (~7059):
    `Index == 0xFF` actualiza `Life`, `Mana`, `Shield`, `SkillMana`; `Index == 0xFE`
    actualiza los máximos.
  - `ReceiveRevival` (~1389) actualiza `Life`/`Mana` al revivir.
- Puede que el servidor no esté enviando el paquete periódico de regeneración,
  que el subcódigo/índice no coincida con lo que espera el cliente, o que la
  regeneración esté desactivada en la configuración de OpenMU.
- Confirmar con `openmu-browser-stack/proxy.log` si llegan paquetes de stats tras
  el daño y con qué bytes.

**Archivos probablemente implicados.**
`src/source/Network/Server/WSclient.cpp` (`ReceiveStatsExtended`, `ReceiveRevival`).
Servidor: configuración/plugin de regeneración de OpenMU (fuera de este repo).

## BUG-002 — La tecla `M` no abre el mapa de transporte

**Síntomas.** Pulsar `M` en el juego no abre la ventana de movimiento/transporte.

**Pasos.** Entrar al mundo y pulsar `M`.

**Esperado.** Se alterna `INTERFACE_MOVEMAP` (ventana `move_command.rml`).

**Actual.** No ocurre nada.

**Pistas / hipótesis.**

- El atajo está en `src/source/UI/HUD/HotKey.cpp`:
  - ~150: caso de duel watch.
  - ~289: `IsPress('M')` → `Toggle(INTERFACE_MOVEMAP)`.
- La ventana se registra en `src/source/UI/Core/WindowSystem.cpp` (~597,
  `move_command.rml`) y se implementa en `src/source/UI/HUD/MoveCommandWindow.cpp`.
- Puede ser que el evento de teclado no llegue al cliente en WASM (el mismo tipo
  de problema que vimos al intentar abrir el inventario con una tecla sintética),
  que `CanUpdateKeyEvent()` devuelva `false`, o que la ventana no tenga datos de
  mapas (`src/source/Network/MoveCommandData.cpp`).

**Archivos probablemente implicados.**
`src/source/UI/HUD/HotKey.cpp`, `src/source/UI/HUD/MoveCommandWindow.cpp`,
`src/source/UI/Core/WindowSystem.cpp`, `src/source/Network/MoveCommandData.cpp`.

## BUG-003 — No se envían mensajes por el chat

**Síntomas.** Al escribir en el chat y pulsar Enter, el mensaje no se envía (no
aparece en el log del servidor ni a otros jugadores).

**Pasos.** Abrir el chat, escribir un texto y pulsar Enter.

**Esperado.** El cliente envía el mensaje público al game server y el servidor lo
retransmite.

**Actual.** No se envía nada.

**Causa raíz.** `SendPublicChatMessage` no tenía rama nativa para Emscripten:
como `LoadManagedSymbol` devuelve `nullptr` en WASM, la función era un no-op
silencioso y el paquete nunca salía. Se confirmó con `proxy.log`: en la sesión
del 2026-10-31 no apareció ningún `C1 xx 00` (chat público) aunque se escribieron
mensajes.

**Arreglo.** Se añadió una rama `__EMSCRIPTEN__` en
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` que escribe el paquete
C1 tal como lo define `PublicChatMessage` en `ClientToServerPackets.xml`:

```
C1 <longitud> 00 <nombre 10 bytes> <mensaje UTF-8> 00
```

- El nombre ocupa 10 bytes y se rellena con ceros.
- El mensaje va en UTF-8 y termina en cero, igual que el paquete gestionado
  (`GetRequiredSize` reserva `13 + bytes + 1`).
- La conversión UTF-16 → UTF-8 se añadió como
  `Core::Text::ToUtf8(const char16_t*)` en `src/source/Core/Text/Utf8.cpp`
  (maneja pares sustitutos; los no emparejados se sustituyen por U+FFFD).
- La longitud se limita a 255 bytes sin cortar un carácter UTF-8 a la mitad.

**Verificación.** El cliente compila para WebAssembly y el build despliega en
`openmu-browser-stack/public`. Queda pendiente confirmarlo con el cliente
recargado: al enviar un mensaje debe aparecer `c1 <len> 00 ...` en `proxy.log`
y el servidor debe reenviarlo al jugador.

**Archivos implicados.**
`src/source/UI/HUD/ChatInputBox.cpp`,
`src/source/Engine/Object/ZzzInterface.cpp` (`SendMacroChat`),
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
(`SendPublicChatMessage`),
`src/source/Core/Text/Utf8.cpp` (`ToUtf8(const char16_t*)`),
`src/source/UI/Core/WindowSystem.cpp`.

## BUG-004 — El botón `+` de estadísticas no sube puntos

**Síntomas.** En la ventana de personaje (`C`), pulsar `+` en Fuerza/Agilidad/
Vitalidad/Energía no sube el stat ni consume el punto.

**Pasos.** Abrir personaje, tener puntos de nivel disponibles y pulsar `+`.

**Esperado.** Se envía la petición al servidor y el stat sube.

**Actual.** No cambia nada.

**Causa raíz.** `SendIncreaseCharacterStatPoint` tampoco tenía rama nativa para
Emscripten, así que era un no-op: el botón actualizaba la UI local y el paquete
nunca salía. Se confirmó con `proxy.log`: no aparecía ningún `C3 05 F3 06`.

**Arreglo.** Se añadió una rama `__EMSCRIPTEN__` en
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` con el formato de
`IncreaseCharacterStatPoint` (`C3HeaderWithSubCode`, longitud 5):

```
C3 05 F3 06 <StatType>
```

`StatType` es el valor del enum `CharacterStatAttribute` que ya usa la UI:
`0` Fuerza, `1` Agilidad, `2` Vitalidad, `3` Energía, `4` Liderazgo. El servidor
valida que haya un punto de nivel disponible y responde con
`ReceiveAddPointExtended`, que ya actualiza los stats en el cliente.

**Verificación.** El cliente compila para WebAssembly y el build despliega en
`openmu-browser-stack/public`. Queda pendiente confirmarlo con el cliente
recargado: al pulsar `+` debe aparecer `c3 05 f3 06 ...` en `proxy.log` y llegar
la respuesta del servidor con el stat actualizado.

**Archivos implicados.**
`src/source/UI/Character/CharacterInfoWindow.cpp`,
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
(`SendIncreaseCharacterStatPoint`),
`src/source/Network/Server/WSclient.cpp` (`ReceiveAddPointExtended`).

## BUG-005 — No se puede desequipar un item; queda anclado al cursor

**Síntomas.** Al hacer clic en un item equipado, el item se "pega" al cursor y no
se puede volver a soltar: ni equiparlo otra vez ni dejarlo en el inventario.

**Pasos.** Abrir inventario (`I`/`V`), hacer clic en un item del equipo e
intentar soltarlo en el inventario o en otra casilla de equipo.

**Esperado.** El item se mueve entre equipo e inventario.

**Actual (antes del arreglo).** El item queda anclado al cursor y el estado no se limpia.

**Causa raíz.** La misma que BUG-007: el cliente llamaba a
`SendItemMoveRequestExtended` al soltar el item, pero esa función era un no-op en
WASM (`LoadManagedSymbol` devuelve `nullptr`). El paquete `C3 24` nunca salía, el
servidor no confirmaba el movimiento y `ReceivePlayerTransfer` /
`DiscardPickedItem` nunca se ejecutaban, así que el item seguía pegado al cursor.

**Arreglo.** Se añadió a `SendItemMoveRequestExtended`
(`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`) una rama
`__EMSCRIPTEN__` que escribe el paquete nativo:

```
C3 07 24 <FromStorage> <FromSlot> <ToStorage> <ToSlot>
```

**Verificación.** El cliente compila y el paquete coincide con la definición
`ItemMoveRequestExtended` de `ClientToServerPackets.xml` (longitud 7). Queda
pendiente confirmarlo en una sesión con el cliente recargado: al soltar el item
debe aparecer `C3 24` en `proxy.log` y el servidor debe responder con su
`0x24`, momento en que `ReceivePlayerTransfer` limpia el cursor.

**Archivos implicados.**
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
(`SendItemMoveRequestExtended`),
`src/source/Engine/Object/ZzzInventory.cpp` (`SendRequestEquipmentItem`),
`src/source/UI/Inventory/MyInventory.cpp` (`EquipmentWindowProcess`),
`src/source/Network/Server/WSclient.cpp` (`ReceiveEquipmentItemExtended`).

## BUG-006 — Menú de escape: Switch Character / Select Server / Exit Game

**Síntomas.** En el menú de escape:
- **Switch Character** no hace nada.
- **Select Server** no hace nada.
- **Exit Game** tiene un comportamiento extraño.

**Esperado.** Switch Character vuelve a la selección de personaje; Select Server
cierra sesión y vuelve a la lista de servidores; Exit Game cierra el juego.

**Actual.** Los dos primeros no responden; el tercero se comporta de forma
inesperada.

**Causa raíz.** `SendLogOut` no tenía rama nativa para Emscripten, así que era
un no-op: `Switch Character`, `Choose Server` y `Select Server` marcaban
`LogOut = true`, pero el servidor nunca recibía la petición y la sesión seguía
abierta, por lo que el cliente se quedaba esperando. Se confirmó con
`proxy.log`: no aparecía ningún `C3 05 F1 02` en el tráfico C→S.

Además, el `Exit Game` del menú de escape solo hacía
`PostMessage(g_hWnd, WM_CLOSE, 0, 0)`, sin avisar antes al servidor.

**Arreglo.** Se añadió la rama `__EMSCRIPTEN__` en
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` con el formato de
`LogOut` (`C3HeaderWithSubCode`, longitud 5):

```
C3 05 F1 02 <LogOutType>
```

`LogOutType`: `0` cerrar el juego, `1` volver a la selección de personaje, `2`
volver a la selección de servidor. Con eso funcionan tanto los botones del menú
de game over (`CustomMessageBox`) como `SelectServer` del menú de escape.

También se actualizó `CSysMenuWin::ExitGame`
(`src/source/UI/Windows/SysMenuWin.cpp`) para enviar
`SendLogOut(LogOutType::CloseGame)` antes de `WM_CLOSE`, igual que ya hacía el
menú de game over. Así el servidor libera al jugador en vez de dejar la sesión
abierta hasta que expire el socket.

**Verificación.** El cliente compila para WebAssembly y el build despliega en
`openmu-browser-stack/public`. Queda pendiente confirmarlo con el cliente
recargado, buscando en `proxy.log`:

- `Switch Character`: `c3 05 f1 02 01` y transición a la lista de personajes;
- `Select Server`: `c3 05 f1 02 02` y vuelta a la lista de servidores;
- `Exit Game`: `c3 05 f1 02 00`.

**Nota sobre Exit Game en el navegador.** En WASM `PostMessage(WM_CLOSE)` se
traduce en `SDL_EVENT_QUIT`, que pone `Destroy = true` y llama a
`emscripten_cancel_main_loop()`. El bucle se detiene y el canvas conserva el
último frame; el navegador no permite cerrar la pestaña desde el juego, así que
hay que cerrarla a mano. El `ShutdownRuntime` completo solo se ejecuta en las
builds nativas. Esto es una limitación del entorno web, no del logout: la sesión
del servidor sí se cierra ahora correctamente.

**Archivos implicados.**
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` (`SendLogOut`),
`src/source/UI/Windows/SysMenuWin.cpp` (`ExitGame`, `SelectServer`),
`src/source/UI/Dialogs/CustomMessageBox.cpp` (Switch Character / Choose Server /
Exit),
`src/source/Network/Server/WSclient.cpp` (`ReceiveLogOut`).

## BUG-007 — NPCs y monstruos de Lorencia no aparecen

**Síntomas.** En Lorencia no se ven:
- el NPC del bar,
- el baúl,
- los monstruos que deberían aparecer fuera de Lorencia,

aunque el spawn está definido correctamente en el servidor.

**Pasos.** Entrar a Lorencia y recorrer la zona; comparar con los spawns del
servidor.

**Esperado.** El servidor envía los viewports y el cliente crea/renderiza los
NPCs y monstruos.

**Actual (antes del arreglo).** No se crean o no se renderizan.

**Causa raíz.** El cliente nunca enviaba los paquetes de movimiento al
servidor. Se verificó con `openmu-browser-stack/proxy.log`: el cliente movía al
héroe localmente, pero no salía ningún `C1 D4` (WalkRequest); solo se veían los
pings `C3 0C 0E 00 ...`. Por eso OpenMU seguía creyendo que el héroe estaba en
el punto de entrada y nunca actualizaba su viewport: los NPCs y monstruos que
quedaban fuera del radio inicial jamás se enviaban.

El motivo es que, en la compilación WASM, `LoadManagedSymbol` devuelve siempre
`nullptr` (`src/source/Dotnet/Connection.h`, rama `__EMSCRIPTEN__`). Todos los
`PacketFunctions_ClientToServer::Send*` que no tienen una rama nativa para
Emscripten se convierten en un no-op silencioso. `SendWalkRequest` era uno de
ellos; solo `SendPing`, el login y los paquetes del connect server tenían
serialización nativa. El mismo patrón explica BUG-003, BUG-004, BUG-005 y
BUG-006.

**Arreglo.** Se añadió a `SendWalkRequest`
(`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`) una rama
`__EMSCRIPTEN__` que escribe el paquete C1 `0xD4` directamente:

```
C1 <tamaño> D4 <SourceX> <SourceY> <StepCount | TargetRotation << 4> <direcciones...>
```

El tamaño es `6 + longitud de direcciones`. La longitud se limita a 8 bytes,
que es el máximo que produce `SendCharacterMove` (`PathNew[8]`).

**Verificación (2026-10-31).**

- C→S al hacer clic en el suelo:
  `c1 09 d4 8c 85 33 33 33 30` (origen 140,133).
- S→C confirmando el movimiento:
  `c1 0a d4 02 00 8c 85 91 85 00` (destino 145,133).
- Al alejarse del punto de entrada, el servidor retiró objetos del viewport:
  `c1 0a 14 03 02 11 02 0d 03 3c` (quita 371, 257 y 568).
- Al acercarse a (146,110), el servidor **añadió** el baúl de Baz:
  `c2 00 0f 13 01 02 01 00 f0 92 6e 92 6e 30 00`
  (tipo 240, posición 146,110), y el NPC se ve en pantalla.

Los spawns del servidor se comprobaron en la base de datos
(`config."MonsterSpawnArea"`): Lumen en (123,135), Baz en (146,110) y
(147,145), Leo en (130,126), etc.

**Archivos implicados.**
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` (`SendWalkRequest`),
`src/source/Dotnet/Connection.h` (`LoadManagedSymbol`),
`src/source/Network/Server/WSclient.cpp` (`ReceiveCreateMonsterViewport`,
`ReceiveCreateTransformViewport`),
`src/source/Engine/Object/ZzzCharacter.cpp` (`CreateMonster`).

## BUG-008 — Al hacer clic en un NPC no se abre el diálogo ni ocurre ninguna acción

**Síntomas.** Al hacer clic sobre un NPC (por ejemplo Lumen o Baz en Lorencia) el
héroe camina hasta él, pero no se abre la ventana de diálogo, tienda o baúl, y no
ocurre ninguna acción.

**Pasos.** Entrar al mundo, hacer clic sobre un NPC y esperar a que el héroe
llegue a su lado.

**Esperado.** El cliente envía `TalkToNpcRequest`; el servidor responde con
`NpcWindowResponse` (C3 `0x30`) o con el diálogo de quest, y el cliente abre la
ventana correspondiente.

**Actual (antes del arreglo).** El héroe se acerca al NPC pero el servidor nunca
recibe la petición, así que no responde y no se abre nada.

**Causa raíz.** La misma que BUG-003 a BUG-007: en WASM `LoadManagedSymbol`
devuelve `nullptr`, y `SendTalkToNpcRequest` y `SendCloseNpcRequest` no tenían
rama nativa, por lo que eran no-ops silenciosos. Se confirmó con `proxy.log`
(sesión del 2026-10-31 hasta las 03:03): el tráfico C→S solo contenía pings
(`C3 0C 0E`), walk requests (`C1 07/08/09 D4`) y movimientos de item
(`C3 07 24`); no aparecía ningún `C3 05 30` (talk) ni `C1 03 31` (close) aunque
el personaje se movió junto a los NPCs.

**Arreglo.** Se añadieron ramas `__EMSCRIPTEN__` en
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`:

- `SendTalkToNpcRequest` escribe el paquete C3 (5 bytes) con el id del NPC como
  short big-endian:

  ```
  C3 05 30 <NpcId alto> <NpcId bajo>
  ```

- `SendCloseNpcRequest` escribe el paquete C1 (3 bytes), necesario para que el
  servidor cierre el diálogo y el jugador pueda volver a hablar con el NPC:

  ```
  C1 03 31
  ```

Ambos formatos coinciden con las definiciones `TalkToNpcRequest` (longitud 5) y
`CloseNpcRequest` (longitud 3) de `ClientToServerPackets.xml`.

**Verificación.** El cliente compila para WebAssembly y el build despliega en
`openmu-browser-stack/public`. Queda pendiente confirmarlo en una sesión con el
cliente recargado: al hacer clic en un NPC debe aparecer `c3 05 30 ...` en
`proxy.log` y el servidor debe responder con `c3 0b 30 ...`
(`NpcWindowResponse`) o el diálogo de quest, momento en que se abre la ventana.

**Pendiente relacionado.** En el momento de este arreglo, las acciones dentro de
esos diálogos seguían siendo no-ops en WASM: `SendBuyItemFromNpcRequest`
(`C3 32`), `SendSellItemToNpcRequest` (`C3 33`), `SendRepairItemRequest`
(`C1 34`) y `SendNpcBuffRequest` (`C1 04 F6 31`). Es decir, la ventana ya se
abría, pero comprar/vender/reparar/pedir buff todavía no enviaba nada. Corregido
después en BUG-009.

**Archivos implicados.**
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
(`SendTalkToNpcRequest`, `SendCloseNpcRequest`),
`src/source/Engine/Object/ZzzInterface.cpp` (selección del NPC y `MOVEMENT_TALK`),
`src/source/Network/Server/WSclient.cpp` (`ReceiveTalk`,
`ReceiveNPCDlgUIStart`).

## BUG-009 — Comprar, vender, reparar o pedir buff a un NPC no hace nada

**Síntomas.** Con la ventana del NPC ya abierta (BUG-008 corregido), al pulsar
comprar, vender, reparar o pedir el buff del NPC soldado, la acción no envía
nada: no se mueve zen, no cambia el inventario y no aparece el buff.

**Pasos.** Hablar con un mercader de Lorencia, intentar comprar y vender un item;
hablar con el herrero y reparar; hablar con el NPC soldado y pedir el buff.

**Esperado.** El cliente envía la petición correspondiente y el servidor responde
con `ItemBought` / `NpcItemSellResult` / el resultado de reparación o el buff,
actualizando el inventario y el zen.

**Actual (antes del arreglo).** Los botones no hacen nada porque las cuatro
funciones seguían siendo no-ops en WASM (`LoadManagedSymbol` devuelve `nullptr`).

**Causa raíz.** La misma de BUG-003 a BUG-008: faltaban las ramas nativas
`#ifdef __EMSCRIPTEN__` para los paquetes de acciones de NPC.

**Arreglo.** Se añadieron ramas `__EMSCRIPTEN__` en
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp` con los formatos de
`ClientToServerPackets.xml`:

- `SendBuyItemFromNpcRequest` → `C3 04 32 <ItemSlot>`
- `SendSellItemToNpcRequest` → `C3 04 33 <ItemSlot>`
- `SendRepairItemRequest` → `C1 05 34 <ItemSlot> <IsSelfRepair>`
- `SendNpcBuffRequest` → `C1 04 F6 31`

`IsSelfRepair` se escribe tal cual lo pasa el cliente (la UI usa `0` al reparar
desde la ventana del NPC y `1` al reparar desde el inventario). El paquete de
reparación también cubre `ItemSlot = 0xFF` (reparar todo) y la reparación de la
mascota, que el servidor valida según el NPC abierto.

**Verificación.** El cliente compila para WebAssembly y el build despliega en
`openmu-browser-stack/public`. Queda pendiente confirmarlo en una sesión con el
cliente recargado, buscando en `proxy.log`:

- compra: `c3 04 32 ...` y respuesta `c3 ... 32` (`ItemBought`);
- venta: `c3 04 33 ...` y respuesta `c3 ... 33` (`NpcItemSellResult`);
- reparación: `c1 05 34 ...` y respuesta `c1 ... 34` (`ItemRepaired`);
- buff: `c1 04 f6 31`.

**Archivos implicados.**
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
(`SendBuyItemFromNpcRequest`, `SendSellItemToNpcRequest`,
`SendRepairItemRequest`, `SendNpcBuffRequest`),
`src/source/UI/NPCs/NPCShop.cpp`,
`src/source/UI/Inventory/InventoryActionController.cpp`,
`src/source/GameLogic/NPCs/npcBreeder.cpp`.

## Cómo reproducir y capturar tráfico

1. Levantar el stack y el cliente (ver `openmu-browser-stack/README.md`).
2. Arrancar el proxy con `node start-services.js` desde
   `openmu-browser-stack/`, que escribe todo el tráfico en `proxy.log`.
3. Repetir el caso y buscar el paquete relevante en `proxy.log`
   (`[conn#N S->C]` / `[conn#N C->S]`).
4. Para pruebas deterministas, el proyecto tiene un socket de control y pruebas
   in-game: ver `docs/control-socket.md` y `docs/in-game-tests.md`.

## Causa común de BUG-003 a BUG-009

La misma limitación que causaba BUG-007 afecta a casi todos los paquetes
cliente→servidor del juego: `LoadManagedSymbol` es un stub que devuelve
`nullptr` en Emscripten. Ya se corrigió para el movimiento (BUG-007), el
movimiento de items (BUG-005), la interacción con NPCs (BUG-008), las acciones
de sus tiendas (BUG-009), el chat público (BUG-003), los puntos de estadísticas
(BUG-004) y el logout (BUG-006). Antes de tocar la UI conviene comprobar en
`proxy.log` si el paquete sale o no: si no sale, el problema está en el bridge,
no en el botón.

## Prioridad sugerida

1. **BUG-001 y BUG-002**: regeneración de HP y atajo `M`; primero descartar que
   el paquete de regeneración llegue y que el input de teclado llegue al canvas.
   Ninguno de los dos es un problema del bridge de paquetes.
