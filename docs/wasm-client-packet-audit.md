# Auditoría del bridge cliente→servidor en WebAssembly

Fecha: 2026-10-31.

Este documento registra los wrappers de `PacketFunctions_ClientToServer` que
todavía no tienen una rama nativa `#ifdef __EMSCRIPTEN__` y que, por tanto, son
no-ops silenciosos en el cliente WASM. Complementa a
[`browser-test-issues.md`](browser-test-issues.md), que recoge los bugs
observados en juego.

## Método

1. Se recorrieron los 193 wrappers de
   `src/source/Dotnet/PacketFunctions_ClientToServer.cpp`.
2. Se marcaron los que no contienen `#ifdef __EMSCRIPTEN__` dentro de su cuerpo.
3. Se cruzaron con las llamadas reales del cliente en `src/source`, excluyendo
   el propio directorio `Dotnet/`.
4. Se mapeó cada wrapper con `ClientToServerPackets.xml` para obtener header,
   código, subcódigo y longitud.

`LoadManagedSymbol` devuelve `nullptr` en Emscripten
(`src/source/Dotnet/Connection.h`), así que un wrapper sin rama nativa no envía
nada. También se revisaron `PacketFunctions_ChatServer.cpp`,
`PacketFunctions_ConnectServer.cpp` y `PacketFunctions_Custom.cpp`.

## Resumen

- **193** wrappers en total.
- **106** siguen sin rama `__EMSCRIPTEN__`.
- **87** ya tienen rama nativa:
  - Movimiento, login y NPCs: `SendPing`, `SendWalkRequest`,
    `SendRequestCharacterList`, `SendSelectCharacter`, `SendFocusCharacter`,
    `SendTalkToNpcRequest`, `SendCloseNpcRequest`, `SendBuyItemFromNpcRequest`,
    `SendSellItemToNpcRequest`, `SendRepairItemRequest`, `SendNpcBuffRequest`,
    `SendEnterGateRequest`, `SendWarpCommandRequest`.
  - Items e inventario: `SendItemMoveRequestExtended`, `SendPickupItemRequest`,
    `SendDropItemRequest`, `SendConsumeItemRequest`, `SendInventoryRequest`.
  - Chat y personajes: `SendPublicChatMessage`, `SendWhisperMessage`,
    `SendCreateCharacter`, `SendDeleteCharacter`.
  - Mapa, combate y acciones: `SendClientReadyAfterMapChange`, `SendHitRequest`,
    `SendTargetedSkill`, `SendAreaSkill`, `SendRageAttackRequest`,
    `SendRageAttackRangeRequest`, `SendInstantMoveRequest`,
    `SendAnimationRequest`, `SendMagicEffectCancelRequest`, `SendTeleportTarget`.
  - Estadísticas y configuración: `SendIncreaseCharacterStatPoint`,
    `SendAddMasterSkillPoint`, `SendSaveKeyConfiguration`, `SendLogOut`,
    `SendChecksumResponse`, `SendPingResponse`.
  - Lote 2 (detalle abajo): `SendCraftingDialogCloseRequest`,
    `SendChaosMachineMixRequest`, `SendLahapJewelMixRequest`,
    `SendCrywolfChaosRateBenefitRequest`, `SendPetCommandRequest`,
    `SendPetInfoRequest`, `SendUnlockVault`, `SendSetVaultPin`,
    `SendRemoveVaultPin`, `SendVaultClosed`, `SendVaultMoveMoneyRequest`,
    `SendLegacyQuestStateRequest`, `SendLegacyQuestStateSetRequest`,
    `SendAvailableQuestsRequest`, `SendQuestSelectRequest`,
    `SendQuestProceedRequest`, `SendQuestCompletionRequest`,
    `SendQuestClientActionRequest`, `SendQuestCancelRequest`,
    `SendActiveQuestListRequest`, `SendQuestStateRequest`,
    `SendEventQuestStateListRequest`.
  - Lote social, trade y party (detalle abajo): `SendTradeRequest`,
    `SendTradeRequestResponse`, `SendTradeButtonStateChange`, `SendTradeCancel`,
    `SendSetTradeMoney`, `SendPartyInviteRequest`, `SendPartyInviteResponse`,
    `SendPartyListRequest`, `SendPartyPlayerKickRequest`.
  - Lote social, guild y amigos (detalle abajo): `SendGuildKickPlayerRequest`,
    `SendGuildJoinRequest`, `SendGuildJoinResponse`, `SendGuildListRequest`,
    `SendGuildCreateRequest`, `SendGuildMasterAnswer`, `SendGuildWarResponse`,
    `SendGuildInfoRequest`, `SendGuildRoleAssignRequest`,
    `SendGuildRelationshipChangeRequest`, `SendGuildRelationshipChangeResponse`,
    `SendRequestAllianceList`, `SendRemoveAllianceGuildRequest`,
    `SendFriendListRequest`, `SendFriendAddRequest`, `SendFriendDelete`,
    `SendFriendAddResponse`, `SendSetFriendOnlineState`.
- De los 106 pendientes, **22 no tienen ninguna llamada** desde el cliente.
- Los `SendLogin*` del catálogo no se usan en WASM: el login se escribe en
  `PacketFunctions_ClientToServer_Custom::SendLogin`.
- Las funciones de `PacketFunctions_ChatServer` no aplican con OpenMU, que
  gestiona el chat por el game server.

## Lote crítico — corregido (2026-10-31)

| Función | Paquete | Impacto |
|---|---|---|
| `SendClientReadyAfterMapChange` | C1 `F3 12`, len 4 | ACK que el servidor espera tras un cambio de mapa. Sin él, el warp/puerta puede quedar a medias. |
| `SendHitRequest` | C1 `11`, len 7 | Ataque básico: no se hace daño. |
| `SendTargetedSkill` | C3 `19`, len 7 | Skills dirigidas. |
| `SendAreaSkill` | C3 `1E`, len 13 | Skills de área. |
| `SendRageAttackRequest` | C3 `4A`, len 8 | Ataques del Rage Fighter. |
| `SendRageAttackRangeRequest` | C1 `4B`, len 7 | Ataques a distancia del Rage Fighter. |
| `SendPickupItemRequest` | C3 `22`, len 5 | No se pueden recoger items. |
| `SendDropItemRequest` | C3 `23`, len 6 | No se pueden tirar items. |
| `SendConsumeItemRequest` | C3 `26`, len 6 | Pociones, frutas y joyas (todo `SendRequestUse`). |
| `SendInventoryRequest` | C3 `F3 10`, len 4 | Resincronización del inventario. |
| `SendWhisperMessage` | C1 `02`, variable | Susurros privados. |
| `SendCreateCharacter` | C1 `F3 01`, len 15 | Crear personaje. |
| `SendDeleteCharacter` | C1 `F3 02`, len 24 | Borrar personaje. |
| `SendInstantMoveRequest` | C1 `15`, len 5 | Movimiento instantáneo de ciertas skills. |
| `SendAnimationRequest` | C1 `18`, len 5 | Acciones (sentarse, pose, heal, respetar). |
| `SendMagicEffectCancelRequest` | C1 `1B`, len 7 | Quitar buffs. |
| `SendTeleportTarget` | C3 `B0`, len 7 | Teletransporte dirigido. |
| `SendAddMasterSkillPoint` | C1 `F3 52`, len 6 | Subir puntos master. |
| `SendSaveKeyConfiguration` | C1 `F3 30`, variable | Guardar atajos de teclado. |
| `SendChecksumResponse` | C3 `03`, len 8 | Si el servidor pide checksum y no se responde, puede desconectar. |
| `SendPingResponse` | C1 `71`, len 3 | Respuesta al ping del servidor. |

Los 21 wrappers de esta tabla ya tienen rama nativa. Quedan pendientes de
probar en juego, sobre todo el ACK de cambio de mapa y el combate.

## Lote 2 — corregido (2026-11-01)

| Función | Paquete | Notas |
|---|---|---|
| `SendCraftingDialogCloseRequest` | C1 `87`, len 3 | Cerrar el diálogo del goblin del caos. |
| `SendChaosMachineMixRequest` | C1 `86`, len 5 | Mezcla del chaos machine. |
| `SendLahapJewelMixRequest` | C1 `BC`, len 7 | Combinar y separar stacks de joyas con Lahap. |
| `SendCrywolfChaosRateBenefitRequest` | C1 `BD/09`, len 4 | Beneficio de tasa de caos de CryWolf. |
| `SendPetCommandRequest` | C1 `A7`, len 7 | El `TargetId` va como short big-endian. |
| `SendPetInfoRequest` | C1 `A9`, len 6 | Nivel y experiencia del cuervo/caballo. |
| `SendUnlockVault` | C1 `83/00`, len 7 | PIN como short little-endian. |
| `SendSetVaultPin` | C1 `83/01`, len 27 | PIN little-endian y contraseña UTF-8 de 20 bytes. |
| `SendRemoveVaultPin` | C1 `83/02`, len 27 | Contraseña UTF-8 de 20 bytes. |
| `SendVaultClosed` | C1 `82`, len 3 | El servidor actualiza el estado del baúl. |
| `SendVaultMoveMoneyRequest` | C1 `81`, len 8 | Importe como integer little-endian. |
| `SendLegacyQuestStateRequest` | C1 `A0`, len 3 | Estado de quests al entrar al mundo. |
| `SendLegacyQuestStateSetRequest` | C1 `A2`, len 5 | Iniciar o terminar una quest legacy. |
| `SendAvailableQuestsRequest` | C1 `F6/30`, len 4 | Lista de quests del NPC. |
| `SendQuestSelectRequest` | C1 `F6/0A`, len 9 | Número y grupo de quest little-endian. |
| `SendQuestProceedRequest` | C1 `F6/0B`, len 9 | Avanzar la quest. |
| `SendQuestCompletionRequest` | C1 `F6/0D`, len 8 | Completar la quest. |
| `SendQuestClientActionRequest` | C1 `F6/10`, len 8 | Acción de cliente (p. ej. tutorial). |
| `SendQuestCancelRequest` | C1 `F6/0F`, len 8 | Cancelar la quest. |
| `SendActiveQuestListRequest` | C1 `F6/1A`, len 4 | Lista de quests activas. |
| `SendQuestStateRequest` | C1 `F6/1B`, len 8 | Estado de una quest concreta. |
| `SendEventQuestStateListRequest` | C1 `F6/21`, len 4 | Quests de evento (Gens). |

El baúl (abrir, cerrar, mover items y mover dinero) quedó verificado en juego el
2026-11-01. Quedan pendientes de probar las mascotas y el flujo completo de
quests.

El cierre del baúl ahora envía `VaultClosed` (`C1 03 82`). Antes de esta rama, el
wrapper era un no-op y el servidor mantenía el storage abierto, así que rechazaba
cualquier reapertura hasta reconectar o cambiar de personaje. Las dos rutas de
cierre del cliente —la X de la ventana y caminar (`UpdateSendMoveInterface`)—
pasan por `CStorageInventory::ProcessClosing` y envían el paquete.

## Lote social — trade y party (2026-11-01)

| Función | Paquete | Notas |
|---|---|---|
| `SendTradeRequest` | C3 `36`, len 5 | `PlayerId` como short big-endian. |
| `SendTradeRequestResponse` | C1 `37`, len 4 | Aceptar o rechazar la invitación. |
| `SendTradeButtonStateChange` | C1 `3C`, len 4 | Estado del botón de confirmación. |
| `SendTradeCancel` | C1 `3D`, len 3 | Cancelar el trade. |
| `SendSetTradeMoney` | C1 `3A`, len 8 | Zen del trade, little-endian. |
| `SendPartyInviteRequest` | C1 `40`, len 5 | `TargetPlayerId` big-endian. |
| `SendPartyInviteResponse` | C1 `41`, len 6 | Aceptar o rechazar, con el id del invitador. |
| `SendPartyListRequest` | C1 `42`, len 3 | Pedir la lista del grupo. |
| `SendPartyPlayerKickRequest` | C1 `43`, len 4 | Expulsar por índice de jugador. |

Queda pendiente probar en juego el trade completo (invitar, poner zen, confirmar
y cancelar) y el flujo de invitación/expulsión de party.

## Lote social — guild y amigos (2026-11-01)

| Función | Paquete | Notas |
|---|---|---|
| `SendGuildKickPlayerRequest` | C1 `53`, variable | Nombre de 10 bytes y código de seguridad UTF-8 con terminador. |
| `SendGuildJoinRequest` | C1 `50`, len 5 | `GuildMasterPlayerId` big-endian. |
| `SendGuildJoinResponse` | C1 `51`, len 6 | Aceptar o rechazar la solicitud. |
| `SendGuildListRequest` | C1 `52`, len 3 | Lista de miembros. |
| `SendGuildCreateRequest` | C1 `55`, len 44 | Nombre de 8 bytes y emblema de 32. |
| `SendGuildMasterAnswer` | C1 `54`, len 4 | Mostrar o no el diálogo de creación. |
| `SendGuildWarResponse` | C1 `61`, len 4 | Aceptar o rechazar la guerra. |
| `SendGuildInfoRequest` | C1 `66`, len 8 | `GuildId` little-endian. |
| `SendGuildRoleAssignRequest` | C1 `E1`, len 15 | Tipo, rol y nombre de 10 bytes. |
| `SendGuildRelationshipChangeRequest` | C1 `E5`, len 7 | Alianza/hostilidad con `TargetPlayerId` big-endian. |
| `SendGuildRelationshipChangeResponse` | C1 `E6`, len 8 | Respuesta a la relación propuesta. |
| `SendRequestAllianceList` | C1 `E9`, len 3 | Lista de guilds aliadas. |
| `SendRemoveAllianceGuildRequest` | C1 `EB/01`, len 12 | Nombre de guild de 8 bytes. |
| `SendFriendListRequest` | C1 `C0`, len 3 | Lista de amigos. |
| `SendFriendAddRequest` | C1 `C1`, len 13 | Nombre de 10 bytes. |
| `SendFriendDelete` | C1 `C3`, len 13 | Nombre de 10 bytes. |
| `SendFriendAddResponse` | C1 `C2`, len 14 | Aceptar o rechazar, con el nombre del solicitante. |
| `SendSetFriendOnlineState` | C1 `C4`, len 4 | El managed normaliza cualquier valor distinto de 1 a 0. |

Queda pendiente probar en juego la creación de guild, la asignación de roles, las
alianzas/hostilidades y el flujo completo de amigos.

## Segunda capa (features completas)

Con el lote 2 y el lote social de trade/party/guild/amigos, la capa de paquetes
de NPC, quests, crafting, baúl, mascotas, trade, party, guild y amigos ya está
cubierta; lo que falta de esos sistemas es el flujo de UI en juego.

- **Cartas y salas de chat**: `SendLetter*`, `SendChatRoom*`.
- **Tienda personal**: `SendPlayerShopOpen`, `SendPlayerShopClose`,
  `SendPlayerShopSetItemPrice`, `SendPlayerShopSetItemPriceExtended`,
  `SendPlayerShopItemListRequest`, `SendPlayerShopItemBuyRequest`,
  `SendPlayerShopCloseOther`.
- **Eventos y sistemas especiales**: Blood Castle, Devil Square, Chaos Castle,
  Illusion Temple, Doppelganger, Lucky Coin, Gens, CryWolf, Kanturu, Castle
  Siege, Cash Shop y MuHelper.

## Sin llamadas (no merece la pena portarlas)

`SendPickupItemRequest075`, `SendConsumeItemRequest075`,
`SendItemMoveRequest` (no extended), `SendEnterGateRequest075`,
`SendItemRepair`, `SendWalkRequest075`, `SendTargetedSkill075`,
`SendTargetedSkill095`, `SendAreaSkill075`, `SendAreaSkill095`,
`SendLoginLongPassword`, `SendLoginShortPassword`, `SendLogin075`,
`SendLetterListRequest`, `SendCancelGuildCreation`, `SendGuildTypeChangeRequest`,
`SendMutoNumberRequest`, `SendEventChipExchangeRequest`,
`SendRaklionStateInfoRequest`, `SendCashShopDeleteStorageItemRequest`,
`SendServerImmigrationRequest`, `SendGuildCreateRequest075`.

## Plan

1. **Lote crítico** (hecho el 2026-10-31): combate, items, mapa y personajes.
2. **Lote NPC/quest/crafting/baúl** (hecho el 2026-11-01): el lote 2 de arriba.
3. **Lote social** (en curso): trade, party, guild y amigos hechos el
   2026-11-01; queda la tienda personal.
4. **Eventos/cash shop/castle siege/MuHelper**.

## Listado completo de wrappers pendientes

La siguiente tabla es la foto vigente de los 106 wrappers que siguen sin rama nativa. La columna
`Llamadas` cuenta las llamadas desde `src/source` (sin contar la definición del
bridge) y sirve para priorizar.

| Llamadas | Función | Header | Código | Longitud |
|---:|---|---|---|---|
| 9 | `SendCashShopStorageListRequest` | C1HeaderWithSubCode | `D2/05` | 10 |
| 8 | `SendMiniGameOpeningStateRequest` | C1Header | `91` | 5 |
| 6 | `SendCashShopPointInfoRequest` | C1HeaderWithSubCode | `D2/01` | 4 |
| 5 | `SendCastleSiegeDefenseUpgradeRequest` | C1HeaderWithSubCode | `B2/07` | 20 |
| 5 | `SendCashShopOpenState` | C1HeaderWithSubCode | `D2/02` | 5 |
| 4 | `SendPlayerShopItemListRequest` | C3HeaderWithSubCode | `3F/05` | 16 |
| 3 | `SendCastleSiegeTaxChangeRequest` | C1HeaderWithSubCode | `B2/09` | 9 |
| 3 | `SendEventChipExitDialog` | C1Header | `97` | 3 |
| 3 | `SendDuelStartRequest` | C3HeaderWithSubCode | `AA/01` | 16 |
| 2 | `SendPlayerShopOpen` | C3HeaderWithSubCode | `3F/02` | 30 |
| 2 | `SendPlayerShopClose` | C3HeaderWithSubCode | `3F/03` | 4 |
| 2 | `SendCastleSiegeRegistrationStateRequest` | C1HeaderWithSubCode | `B2/03` | 4 |
| 2 | `SendCastleSiegeDefenseBuyRequest` | C1HeaderWithSubCode | `B2/05` | 12 |
| 2 | `SendCastleSiegeDefenseRepairRequest` | C1HeaderWithSubCode | `B2/06` | 12 |
| 2 | `SendCastleSiegeRegisteredGuildsListRequest` | C1Header | `B4` | 3 |
| 2 | `SendWeaponExplosionRequest` | C1HeaderWithSubCode | `B7/04` | 6 |
| 2 | `SendCrywolfInfoRequest` | C1HeaderWithSubCode | `BD/00` | 4 |
| 2 | `SendCrywolfContractRequest` | C1HeaderWithSubCode | `BD/03` | 6 |
| 2 | `SendSantaClausItemRequest` | C1HeaderWithSubCode | `D0/10` | 4 |
| 2 | `SendCashShopStorageItemConsumeRequest` | C1HeaderWithSubCode | `D2/0B` | 15 |
| 2 | `SendLetterDeleteRequest` | C1Header | `C8` | 6 |
| 2 | `SendLetterReadRequest` | C1Header | `C7` | 6 |
| 2 | `SendMuHelperStatusChangeRequest` | C1HeaderWithSubCode | `BF/51` | 5 |
| 2 | `SendGensJoinRequest` | C1HeaderWithSubCode | `F8/01` | 5 |
| 2 | `SendGensRewardRequest` | C1HeaderWithSubCode | `F8/09` | 5 |
| 2 | `SendMiniGameEventCountRequest` | C1Header | `9F` | 4 |
| 2 | `SendChaosCastleEnterRequest` | C1HeaderWithSubCode | `AF/01` | 6 |
| 2 | `SendDuelStopRequest` | C3HeaderWithSubCode | `AA/03` | 4 |
| 1 | `SendLogOutByCheatDetection` | C3HeaderWithSubCode | `F1/03` | 6 |
| 1 | `SendResetCharacterPointRequest` | C1HeaderWithSubCode | `F2/00` | 4 |
| 1 | `SendPlayerShopSetItemPrice` | C3HeaderWithSubCode | `3F/01` | 9 |
| 1 | `SendPlayerShopItemBuyRequest` | C3HeaderWithSubCode | `3F/06` | 17 |
| 1 | `SendPlayerShopCloseOther` | C3HeaderWithSubCode | `3F/07` | 16 |
| 1 | `SendPlayerShopSetItemPriceExtended` | C3HeaderWithSubCode | `3F/09` | 13 |
| 1 | `SendServerChangeAuthentication` | C3HeaderWithSubCode | `B1/01` | 69 |
| 1 | `SendCastleSiegeStatusRequest` | C1HeaderWithSubCode | `B2/00` | 4 |
| 1 | `SendCastleSiegeRegistrationRequest` | C1HeaderWithSubCode | `B2/01` | 4 |
| 1 | `SendCastleSiegeUnregisterRequest` | C1HeaderWithSubCode | `B2/02` | 5 |
| 1 | `SendCastleSiegeMarkRegistration` | C1HeaderWithSubCode | `B2/04` | 5 |
| 1 | `SendCastleSiegeTaxInfoRequest` | C1HeaderWithSubCode | `B2/08` | 4 |
| 1 | `SendCastleSiegeTaxMoneyWithdraw` | C1HeaderWithSubCode | `B2/10` | 8 |
| 1 | `SendToggleCastleGateRequest` | C1HeaderWithSubCode | `B2/12` | 7 |
| 1 | `SendCastleGuildCommand` | C1HeaderWithSubCode | `B2/1D` | 8 |
| 1 | `SendCastleSiegeHuntingZoneEntranceSetting` | C1HeaderWithSubCode | `B2/1F` | 5 |
| 1 | `SendCastleSiegeGateListRequest` | C1HeaderWithSubCode | `B3/01` | 4 |
| 1 | `SendCastleSiegeStatueListRequest` | C1HeaderWithSubCode | `B3/02` | 4 |
| 1 | `SendCastleOwnerListRequest` | C1Header | `B5` | 3 |
| 1 | `SendFireCatapultRequest` | C1HeaderWithSubCode | `B7/01` | 7 |
| 1 | `SendGuildLogoOfCastleOwnerRequest` | C1HeaderWithSubCode | `B9/02` | 4 |
| 1 | `SendCastleSiegeHuntingZoneEnterRequest` | C1HeaderWithSubCode | `B9/05` | 8 |
| 1 | `SendWhiteAngelItemRequest` | C1HeaderWithSubCode | `D0/03` | 4 |
| 1 | `SendEnterOnWerewolfRequest` | C1HeaderWithSubCode | `D0/07` | 4 |
| 1 | `SendEnterOnGatekeeperRequest` | C1HeaderWithSubCode | `D0/08` | 4 |
| 1 | `SendLeoHelperItemRequest` | C1HeaderWithSubCode | `D0/09` | 4 |
| 1 | `SendMoveToDeviasBySnowmanRequest` | C1HeaderWithSubCode | `D0/0A` | 4 |
| 1 | `SendKanturuInfoRequest` | C1HeaderWithSubCode | `D1/00` | 4 |
| 1 | `SendKanturuEnterRequest` | C1HeaderWithSubCode | `D1/01` | 4 |
| 1 | `SendCashShopItemBuyRequest` | C1HeaderWithSubCode | `D2/03` | 23 |
| 1 | `SendCashShopItemGiftRequest` | C1HeaderWithSubCode | `D2/04` | 234 |
| 1 | `SendCashShopEventItemListRequest` | C1HeaderWithSubCode | `D2/13` | 8 |
| 1 | `SendLetterSendRequest` | C4Header | `C5` | — |
| 1 | `SendChatRoomCreateRequest` | C1Header | `CA` | 13 |
| 1 | `SendChatRoomInvitationRequest` | C1Header | `CB` | 19 |
| 1 | `SendIllusionTempleEnterRequest` | C1HeaderWithSubCode | `BF/00` | 6 |
| 1 | `SendIllusionTempleSkillRequest` | C1HeaderWithSubCode | `BF/02` | 8 |
| 1 | `SendIllusionTempleRewardRequest` | C1HeaderWithSubCode | `BF/05` | 4 |
| 1 | `SendLuckyCoinCountRequest` | C1HeaderWithSubCode | `BF/0B` | 4 |
| 1 | `SendLuckyCoinRegistrationRequest` | C1HeaderWithSubCode | `BF/0C` | 4 |
| 1 | `SendLuckyCoinExchangeRequest` | C1HeaderWithSubCode | `BF/0D` | 8 |
| 1 | `SendDoppelgangerEnterRequest` | C1HeaderWithSubCode | `BF/0E` | 5 |
| 1 | `SendEnterMarketPlaceRequest` | C1HeaderWithSubCode | `BF/17` | 4 |
| 1 | `SendMuHelperSaveDataRequest` | C2Header | `AE` | 261 |
| 1 | `SendEnterEmpireGuardianEvent` | C1HeaderWithSubCode | `F7/01` | 5 |
| 1 | `SendGensLeaveRequest` | C1HeaderWithSubCode | `F8/03` | 4 |
| 1 | `SendGensRankingRequest` | C1HeaderWithSubCode | `F8/0B` | 4 |
| 1 | `SendDevilSquareEnterRequest` | C1Header | `90` | 5 |
| 1 | `SendEventChipRegistrationRequest` | C1Header | `95` | 5 |
| 1 | `SendLuckyNumberRequest` | C1Header | `9D` | 18 |
| 1 | `SendBloodCastleEnterRequest` | C1Header | `9A` | 5 |
| 1 | `SendChaosCastlePositionSet` | C1HeaderWithSubCode | `AF/02` | 6 |
| 1 | `SendDuelStartResponse` | C3HeaderWithSubCode | `AA/02` | 17 |
| 1 | `SendDuelChannelJoinRequest` | C3HeaderWithSubCode | `AA/07` | 5 |
| 1 | `SendDuelChannelQuitRequest` | C3HeaderWithSubCode | `AA/09` | 4 |
| 1 | `SendChatCommandListRequest` | C1HeaderWithSubCode | `F5/00` | 4 |
| 0 | `SendLoginLongPassword` | C3HeaderWithSubCode | `F1/01` | 60 |
| 0 | `SendLoginShortPassword` | C3HeaderWithSubCode | `F1/01` | 50 |
| 0 | `SendLogin075` | C3HeaderWithSubCode | `F1/01` | 48 |
| 0 | `SendPickupItemRequest075` | C1Header | `22` | 5 |
| 0 | `SendItemMoveRequest` | C3Header | `24` | 19 |
| 0 | `SendConsumeItemRequest075` | C1Header | `26` | 5 |
| 0 | `SendEnterGateRequest075` | C3Header | `1C` | 6 |
| 0 | `SendRaklionStateInfoRequest` | C1HeaderWithSubCode | `D1/10` | 4 |
| 0 | `SendCashShopDeleteStorageItemRequest` | C1HeaderWithSubCode | `D2/0A` | 234 |
| 0 | `SendWalkRequest075` | C1Header | `10` | — |
| 0 | `SendTargetedSkill075` | C1Header | `19` | 6 |
| 0 | `SendTargetedSkill095` | C3Header | `19` | 6 |
| 0 | `SendAreaSkill075` | C1Header | `1E` | 7 |
| 0 | `SendAreaSkill095` | C3Header | `1E` | 7 |
| 0 | `SendLetterListRequest` | C1Header | `C9` | 3 |
| 0 | `SendGuildCreateRequest075` | C1Header | `55` | 43 |
| 0 | `SendCancelGuildCreation` | C1Header | `57` | 3 |
| 0 | `SendGuildTypeChangeRequest` | C1Header | `E2` | 4 |
| 0 | `SendItemRepair` | C3Header | `34` | 4 |
| 0 | `SendMutoNumberRequest` | C1Header | `96` | 3 |
| 0 | `SendEventChipExchangeRequest` | C1Header | `98` | 4 |
| 0 | `SendServerImmigrationRequest` | C3Header | `99` | — |
