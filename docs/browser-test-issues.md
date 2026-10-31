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
| BUG-003 | No se envían mensajes por el chat | Cliente (input/red) | Alta | Abierto |
| BUG-004 | El botón `+` de estadísticas no sube puntos | Cliente (UI/red) | Alta | Abierto |
| BUG-005 | No se puede desequipar un item; queda anclado al cursor | Cliente (inventario/red) | Alta | Corregido (pendiente de probar) |
| BUG-006 | El menú de escape: Switch Character / Select Server no hacen nada; Exit Game se comporta raro | Cliente (UI/escenas) | Media | Abierto |
| BUG-007 | NPCs y monstruos de Lorencia no aparecen (spawn correcto en servidor) | Cliente (protocolo/viewport) | Alta | Corregido |

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

**Pistas / hipótesis.**

- Ruta de envío: `src/source/Engine/Object/ZzzInterface.cpp` (~3506)
  `SocketClient->ToGameServer()->SendPublicChatMessage(...)`.
- Implementación del bridge: `src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
  `SendPublicChatMessage` (~55) carga el símbolo gestionado
  `SendPublicChatMessage`; si el símbolo no existe, la función no hace nada.
- Entrada de chat: `src/source/UI/Chat/ChatInput.cpp` (`CheckChatText`) y la
  ventana `INTERFACE_CHATINPUTBOX`.
- Revisar si la caja de chat se abre y captura texto en WASM (teclado/IME), y si
  el símbolo gestionado está disponible en el build.

**Archivos probablemente implicados.**
`src/source/UI/Chat/ChatInput.cpp`,
`src/source/Engine/Object/ZzzInterface.cpp`,
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`,
`src/source/UI/Core/WindowSystem.cpp`.

## BUG-004 — El botón `+` de estadísticas no sube puntos

**Síntomas.** En la ventana de personaje (`C`), pulsar `+` en Fuerza/Agilidad/
Vitalidad/Energía no sube el stat ni consume el punto.

**Pasos.** Abrir personaje, tener puntos de nivel disponibles y pulsar `+`.

**Esperado.** Se envía la petición al servidor y el stat sube.

**Actual.** No cambia nada.

**Pistas / hipótesis.**

- UI: `src/source/UI/Character/CharacterInfoWindow.cpp` `RmlClickIncreaseStat`
  (~302) → `SendIncreaseCharacterStatPoint`.
- Bridge: `src/source/Dotnet/PacketFunctions_ClientToServer.cpp`
  `SendIncreaseCharacterStatPoint` (~1107).
- Respuesta del servidor: `ReceiveAddPointExtended` en
  `src/source/Network/Server/WSclient.cpp` (~7006).
- Revisar si el evento RmlUi del botón se dispara (los botones son
  `#btn_stat_str`, etc.), si el símbolo gestionado se carga y si el servidor
  acepta la petición (nivel/puntos).

**Archivos probablemente implicados.**
`src/source/UI/Character/CharacterInfoWindow.cpp`,
`src/source/Dotnet/PacketFunctions_ClientToServer.cpp`,
`src/source/Network/Server/WSclient.cpp`.

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

**Pistas / hipótesis.**

- `src/source/UI/Windows/SysMenuWin.cpp`:
  - `ExitGame` (~108) usa `::PostMessage(g_hWnd, WM_CLOSE, 0, 0)`. En WASM no hay
  una ventana Win32 real; el shim de `PostMessage`/`WM_CLOSE` puede no mapear al
  cierre del navegador, de ahí el comportamiento raro.
  - `SelectServer` (~115) hace `LogOut = true` y
    `SendLogOut(LogOutType::BackToServerSelection)`; revisar si el flujo de
    reconexión al connect server funciona en el cliente web.
- Revisar si "Switch Character" tiene handler registrado y si el botón está
  oculto/deshabilitado según `m_bSelectServerEnabled` (solo en
  `CHARACTER_SCENE`).

**Archivos probablemente implicados.**
`src/source/UI/Windows/SysMenuWin.cpp`,
`src/source/Scenes/SceneManager.cpp`,
`src/source/Dotnet/Connection.cpp`,
`src/source/UI/Windows/ServerSelWin.cpp`.

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

## Cómo reproducir y capturar tráfico

1. Levantar el stack y el cliente (ver `openmu-browser-stack/README.md`).
2. Arrancar el proxy con `node start-services.js` desde
   `openmu-browser-stack/`, que escribe todo el tráfico en `proxy.log`.
3. Repetir el caso y buscar el paquete relevante en `proxy.log`
   (`[conn#N S->C]` / `[conn#N C->S]`).
4. Para pruebas deterministas, el proyecto tiene un socket de control y pruebas
   in-game: ver `docs/control-socket.md` y `docs/in-game-tests.md`.

## Causa común de BUG-003 a BUG-006

La misma limitación que causaba BUG-007 afecta a casi todos los paquetes
cliente→servidor del juego: `LoadManagedSymbol` es un stub que devuelve
`nullptr` en Emscripten. Ya se corrigió para el movimiento (BUG-007) y el
movimiento de items (BUG-005). Chat, puntos de estadísticas y logout usan el
mismo patrón y necesitan una rama nativa `#ifdef __EMSCRIPTEN__`. Antes de tocar
la UI conviene comprobar en `proxy.log` si el paquete sale o no: si no sale, el
problema está en el bridge, no en el botón.

## Prioridad sugerida

1. **BUG-003 y BUG-004**: serializadores nativos de `PublicChatMessage`
   (C1 `0x00`) e `IncreaseCharacterStatPoint` (C3 `F3 06`).
2. **BUG-006**: `LogOut` (C3 `F1 02`) para Select Server / Switch Character;
   revisar aparte el cierre de ventana de Exit Game.
3. **BUG-001 y BUG-002**: regeneración de HP y atajo `M`; primero descartar que
   el paquete de regeneración llegue y que el input de teclado llegue al canvas.
