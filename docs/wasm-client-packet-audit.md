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
- **176** siguen sin rama `__EMSCRIPTEN__`.
- **17** ya tienen rama nativa:
  `SendPing`, `SendItemMoveRequestExtended`, `SendWalkRequest`,
  `SendRequestCharacterList`, `SendSelectCharacter`, `SendFocusCharacter`,
  `SendTalkToNpcRequest`, `SendCloseNpcRequest`, `SendBuyItemFromNpcRequest`,
  `SendSellItemToNpcRequest`, `SendRepairItemRequest`, `SendNpcBuffRequest`,
  `SendPublicChatMessage`, `SendIncreaseCharacterStatPoint`, `SendLogOut`,
  `SendWarpCommandRequest` y `SendEnterGateRequest`.
- De los 176 pendientes, **22 no tienen ninguna llamada** desde el cliente.
- Los `SendLogin*` del catálogo no se usan en WASM: el login se escribe en
  `PacketFunctions_ClientToServer_Custom::SendLogin`.
- Las funciones de `PacketFunctions_ChatServer` no aplican con OpenMU, que
  gestiona el chat por el game server.

## Lote crítico (gameplay básico)

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

## Segunda capa (features completas)

- **NPC y quests**: `SendLegacyQuestStateRequest`, `SendQuestSelectRequest`,
  `SendQuestProceedRequest`, `SendQuestCompletionRequest`,
  `SendQuestClientActionRequest`, `SendQuestCancelRequest`,
  `SendActiveQuestListRequest`, `SendQuestStateRequest`,
  `SendEventQuestStateListRequest`, `SendAvailableQuestsRequest`.
- **Crafting**: `SendChaosMachineMixRequest`, `SendLahapJewelMixRequest`,
  `SendCraftingDialogCloseRequest`, `SendCrywolfChaosRateBenefitRequest`.
- **Baúl**: `SendVaultMoveMoneyRequest`, `SendUnlockVault`, `SendSetVaultPin`,
  `SendRemoveVaultPin`, `SendVaultClosed`.
- **Trade**: `SendTradeRequest`, `SendTradeRequestResponse`,
  `SendTradeButtonStateChange`, `SendTradeCancel`, `SendSetTradeMoney`.
- **Party**: `SendPartyInviteRequest`, `SendPartyInviteResponse`,
  `SendPartyListRequest`, `SendPartyPlayerKickRequest`.
- **Guild, amigos, cartas y salas de chat**: `SendGuild*`, `SendFriend*`,
  `SendLetter*`, `SendChatRoom*`, `SendRequestAllianceList`,
  `SendRemoveAllianceGuildRequest`.
- **Tienda personal**: `SendPlayerShopOpen`, `SendPlayerShopClose`,
  `SendPlayerShopSetItemPrice`, `SendPlayerShopSetItemPriceExtended`,
  `SendPlayerShopItemListRequest`, `SendPlayerShopItemBuyRequest`,
  `SendPlayerShopCloseOther`.
- **Mascotas**: `SendPetInfoRequest`, `SendPetCommandRequest`.
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

1. **Lote crítico** (en curso): desbloquear combate, items, mapa y personajes.
2. **Lote NPC/quest/crafting/baúl**.
3. **Lote social**: trade, party, guild, amigos y tienda personal.
4. **Eventos/cash shop/castle siege/MuHelper**.

## Listado completo de wrappers pendientes

La siguiente tabla es la foto de los 176 wrappers sin rama nativa. La columna
`Llamadas` cuenta las llamadas desde `src/source` (sin contar la definición del
bridge) y sirve para priorizar.

| Llamadas | Función | Header | Código | Longitud |
|---:|---|---|---|---|
| 11 | `SendCraftingDialogCloseRequest` | C1Header | `87` | 3 |
| 10 | `SendGuildRelationshipChangeRequest` | C1Header | `E5` | 7 |
| 9 | `SendCashShopStorageListRequest` | C1HeaderWithSubCode | `D2/05` | 10 |
| 8 | `SendPetCommandRequest` | C1Header | `A7` | 7 |
| 8 | `SendMiniGameOpeningStateRequest` | C1Header | `91` | 5 |
| 7 | `SendPickupItemRequest` | C3Header | `22` | 5 |
| 6 | `SendCashShopPointInfoRequest` | C1HeaderWithSubCode | `D2/01` | 4 |
| 6 | `SendPetInfoRequest` | C1Header | `A9` | 6 |
| 5 | `SendCastleSiegeDefenseUpgradeRequest` | C1HeaderWithSubCode | `B2/07` | 20 |
| 5 | `SendCashShopOpenState` | C1HeaderWithSubCode | `D2/02` | 5 |
| 5 | `SendInventoryRequest` | C3HeaderWithSubCode | `F3/10` | 4 |
| 4 | `SendPlayerShopItemListRequest` | C3HeaderWithSubCode | `3F/05` | 16 |
| 4 | `SendPartyInviteRequest` | C1Header | `40` | 5 |
| 4 | `SendInstantMoveRequest` | C1Header | `15` | 5 |
| 4 | `SendRageAttackRequest` | C3Header | `4A` | 8 |
| 4 | `SendTradeCancel` | C1Header | `3D` | 3 |
| 4 | `SendTradeButtonStateChange` | C1Header | `3C` | 4 |
| 4 | `SendTradeRequest` | C3Header | `36` | 5 |
| 4 | `SendGuildListRequest` | C1Header | `52` | 3 |
| 4 | `SendGuildWarResponse` | C1Header | `61` | 4 |
| 4 | `SendSetFriendOnlineState` | C1Header | `C4` | 4 |
| 3 | `SendDropItemRequest` | C3Header | `23` | 6 |
| 3 | `SendCastleSiegeTaxChangeRequest` | C1HeaderWithSubCode | `B2/09` | 9 |
| 3 | `SendVaultMoveMoneyRequest` | C1Header | `81` | 8 |
| 3 | `SendPartyInviteResponse` | C1Header | `41` | 6 |
| 3 | `SendCreateCharacter` | C1HeaderWithSubCode | `F3/01` | 15 |
| 3 | `SendTradeRequestResponse` | C1Header | `37` | 4 |
| 3 | `SendGuildJoinRequest` | C1Header | `50` | 5 |
| 3 | `SendGuildRelationshipChangeResponse` | C1Header | `E6` | 8 |
| 3 | `SendLegacyQuestStateSetRequest` | C1Header | `A2` | 5 |
| 3 | `SendEventChipExitDialog` | C1Header | `97` | 3 |
| 3 | `SendDuelStartRequest` | C3HeaderWithSubCode | `AA/01` | 16 |
| 2 | `SendWhisperMessage` | C1Header | `02` | — |
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
| 2 | `SendVaultClosed` | C1Header | `82` | 3 |
| 2 | `SendLahapJewelMixRequest` | C1Header | `BC` | 7 |
| 2 | `SendPartyPlayerKickRequest` | C1Header | `43` | 4 |
| 2 | `SendLetterDeleteRequest` | C1Header | `C8` | 6 |
| 2 | `SendLetterReadRequest` | C1Header | `C7` | 6 |
| 2 | `SendGuildJoinResponse` | C1Header | `51` | 6 |
| 2 | `SendGuildMasterAnswer` | C1Header | `54` | 4 |
| 2 | `SendGuildRoleAssignRequest` | C1Header | `E1` | 15 |
| 2 | `SendRequestAllianceList` | C1Header | `E9` | 3 |
| 2 | `SendChaosMachineMixRequest` | C1Header | `86` | 5 |
| 2 | `SendFriendAddRequest` | C1Header | `C1` | 13 |
| 2 | `SendFriendAddResponse` | C1Header | `C2` | 14 |
| 2 | `SendMuHelperStatusChangeRequest` | C1HeaderWithSubCode | `BF/51` | 5 |
| 2 | `SendQuestSelectRequest` | C1HeaderWithSubCode | `F6/0A` | 9 |
| 2 | `SendQuestProceedRequest` | C1HeaderWithSubCode | `F6/0B` | 9 |
| 2 | `SendQuestCompletionRequest` | C1HeaderWithSubCode | `F6/0D` | 8 |
| 2 | `SendQuestClientActionRequest` | C1HeaderWithSubCode | `F6/10` | 8 |
| 2 | `SendGensJoinRequest` | C1HeaderWithSubCode | `F8/01` | 5 |
| 2 | `SendGensRewardRequest` | C1HeaderWithSubCode | `F8/09` | 5 |
| 2 | `SendMiniGameEventCountRequest` | C1Header | `9F` | 4 |
| 2 | `SendChaosCastleEnterRequest` | C1HeaderWithSubCode | `AF/01` | 6 |
| 2 | `SendDuelStopRequest` | C3HeaderWithSubCode | `AA/03` | 4 |
| 1 | `SendChecksumResponse` | C3Header | `03` | 8 |
| 1 | `SendLogOutByCheatDetection` | C3HeaderWithSubCode | `F1/03` | 6 |
| 1 | `SendResetCharacterPointRequest` | C1HeaderWithSubCode | `F2/00` | 4 |
| 1 | `SendPlayerShopSetItemPrice` | C3HeaderWithSubCode | `3F/01` | 9 |
| 1 | `SendPlayerShopItemBuyRequest` | C3HeaderWithSubCode | `3F/06` | 17 |
| 1 | `SendPlayerShopCloseOther` | C3HeaderWithSubCode | `3F/07` | 16 |
| 1 | `SendPlayerShopSetItemPriceExtended` | C3HeaderWithSubCode | `3F/09` | 13 |
| 1 | `SendConsumeItemRequest` | C3Header | `26` | 6 |
| 1 | `SendTeleportTarget` | C3Header | `B0` | 7 |
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
| 1 | `SendCrywolfChaosRateBenefitRequest` | C1HeaderWithSubCode | `BD/09` | 4 |
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
| 1 | `SendUnlockVault` | C1HeaderWithSubCode | `83/00` | 7 |
| 1 | `SendSetVaultPin` | C1HeaderWithSubCode | `83/01` | 27 |
| 1 | `SendRemoveVaultPin` | C1HeaderWithSubCode | `83/02` | 27 |
| 1 | `SendPartyListRequest` | C1Header | `42` | 3 |
| 1 | `SendAnimationRequest` | C1Header | `18` | 5 |
| 1 | `SendDeleteCharacter` | C1HeaderWithSubCode | `F3/02` | 24 |
| 1 | `SendClientReadyAfterMapChange` | C1HeaderWithSubCode | `F3/12` | 4 |
| 1 | `SendSaveKeyConfiguration` | C1HeaderWithSubCode | `F3/30` | — |
| 1 | `SendAddMasterSkillPoint` | C1HeaderWithSubCode | `F3/52` | 6 |
| 1 | `SendHitRequest` | C1Header | `11` | 7 |
| 1 | `SendTargetedSkill` | C3Header | `19` | 7 |
| 1 | `SendMagicEffectCancelRequest` | C1Header | `1B` | 7 |
| 1 | `SendAreaSkill` | C3Header | `1E` | 13 |
| 1 | `SendRageAttackRangeRequest` | C1Header | `4B` | 7 |
| 1 | `SendSetTradeMoney` | C1Header | `3A` | 8 |
| 1 | `SendLetterSendRequest` | C4Header | `C5` | — |
| 1 | `SendGuildKickPlayerRequest` | C1Header | `53` | — |
| 1 | `SendGuildCreateRequest` | C1Header | `55` | 44 |
| 1 | `SendGuildInfoRequest` | C1Header | `66` | 8 |
| 1 | `SendRemoveAllianceGuildRequest` | C1HeaderWithSubCode | `EB/01` | 12 |
| 1 | `SendPingResponse` | C1Header | `71` | 3 |
| 1 | `SendFriendListRequest` | C1Header | `C0` | 3 |
| 1 | `SendFriendDelete` | C1Header | `C3` | 13 |
| 1 | `SendChatRoomCreateRequest` | C1Header | `CA` | 13 |
| 1 | `SendChatRoomInvitationRequest` | C1Header | `CB` | 19 |
| 1 | `SendLegacyQuestStateRequest` | C1Header | `A0` | 3 |
| 1 | `SendIllusionTempleEnterRequest` | C1HeaderWithSubCode | `BF/00` | 6 |
| 1 | `SendIllusionTempleSkillRequest` | C1HeaderWithSubCode | `BF/02` | 8 |
| 1 | `SendIllusionTempleRewardRequest` | C1HeaderWithSubCode | `BF/05` | 4 |
| 1 | `SendLuckyCoinCountRequest` | C1HeaderWithSubCode | `BF/0B` | 4 |
| 1 | `SendLuckyCoinRegistrationRequest` | C1HeaderWithSubCode | `BF/0C` | 4 |
| 1 | `SendLuckyCoinExchangeRequest` | C1HeaderWithSubCode | `BF/0D` | 8 |
| 1 | `SendDoppelgangerEnterRequest` | C1HeaderWithSubCode | `BF/0E` | 5 |
| 1 | `SendEnterMarketPlaceRequest` | C1HeaderWithSubCode | `BF/17` | 4 |
| 1 | `SendMuHelperSaveDataRequest` | C2Header | `AE` | 261 |
| 1 | `SendQuestCancelRequest` | C1HeaderWithSubCode | `F6/0F` | 8 |
| 1 | `SendActiveQuestListRequest` | C1HeaderWithSubCode | `F6/1A` | 4 |
| 1 | `SendQuestStateRequest` | C1HeaderWithSubCode | `F6/1B` | 8 |
| 1 | `SendEventQuestStateListRequest` | C1HeaderWithSubCode | `F6/21` | 4 |
| 1 | `SendAvailableQuestsRequest` | C1HeaderWithSubCode | `F6/30` | 4 |
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
