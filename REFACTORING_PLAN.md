# План рефакторинга MythicPlusLootTracker

Документ для поэтапного рефакторинга аддона. Опирается на анализ кодовой базы на 2026-08-17 (v1.18, ~6000 строк, 11 модулей). Ссылки на строки — на момент анализа; после правок нумерация смещается, опираться на сигнатуры функций и имена.

## Принципы

1. **Поэтапно, модуль за модулем.** После каждого этапа аддон остаётся загружаемым; каждый этап — отдельный коммит, который можно проверить через `/reload`.
2. **Весь функционал сохраняется.** Это рефакторинг, не переписывание; поведение не меняется.
3. **Комментарии удаляются везде, кроме `MythicPlusLootTracker-GlobalConstants.lua`.** В нём имена боссов/сезонов в ID-таблицах — это данные, без них ежесезонное обновление превратится в гадание. В логических файлах (Core и модули) комментариев быть не должно.
4. **`Core.lua` разбивается** на тематические модули.
5. **Верификация только в игре** (`/reload`); прогонять `luac -p` / `luacheck` после каждого этапа, если доступны.

Порядок: Этап 1 → 2 → 3 → 4 → 5 → 6 (главный) → 7 → 8 → 9 → 10. После каждого — пауза на `/reload`-тест и коммит.

## Контекст архитектуры (краткая сводка находок)

**Загрузка:** `MythicPlusLootTracker.toc` — единственный источник порядка загрузки. Каждый `.lua` начинается с `local AddonName, Addon = ...`. Состояние разделяется через таблицу `Addon`, но на практике смешано три стиля: `Addon.*`, глобальные миксины (`MPLT*Mixin`) и глобальные функции (`PrepareEncounterList`, `GetEncounter`, `RecreateItemLink`, `CalcFortune`, `StoreCharacterData`).

**SavedVariables (8):** `MPLH_ENC`, `MPLH_ENC_ENDED`, `MPLH_TRACKITEM`, `MPLH_TRACKITEM_ORDER`, `MPLH_TRACKEDITEM_ITEMORDER`, `MPLH_KACDATA`, `MPLH_ORDER`, `MPLTOptions`. Любое изменение структуры — обратно-совместимое (nil-check + init в `AddonLoadedEvent`).

**Масштаб модулей (строки):**

| Файл | Строк | Назначение |
|---|---|---|
| `MythicPlusLootTracker-Core.lua` | 1451 | Хаб: SavedVariables, главный UI, события, лут, данные персонажа |
| `MythicPlusLootTracker-GlobalConstants.lua` | 611 | ID-таблицы подземелий/энкаунтеров |
| `MythicPlusLootTracker-LootSniffer.lua` | 681 | Попрошайка: детект апгрейдов, UI «попросить предмет» |
| `MythicPlusLootTracker-AltManager.xml` | 1062 | 16×`ItemFrameN` + 8×`DungeonN` вручную |
| `MythicPlusLootTracker-AltManager.lua` | 315 | Таб альтов |
| `MythicPlusLootTracker-RollFrame.lua` | 301 | Ролл за предмет |
| `MythicPlusLootTracker-Luck.lua` | 199 | Таб «Удача» |
| `MythicPlusLootTracker-ClassCodexImport.lua` | 202 | Импорт BiS из guide-данных |
| `MythicPlusLootTracker-Tracking.lua` | 159 | Таб отслеживания |
| `MythicPlusLootTracker-LFG.lua` | 71 | Аннотация LFG-листа |
| `MythicPlusLootTracker-ItemRank.lua` | 0 | Пустой, мёртвый |

## Ключевые проблемы (найдено при анализе)

**Баги и утечки:**
- `fotune = "N/A"` (`Core.lua:460`) — опечатка + утечка в глобал; «N/A»-ветка сломана.
- `dungeonID = select(3, ...)` (`Core.lua:212`) — утечка глобала, при этом значение нигде не читается.
- `IsRaid and ...` (`Core.lua:807`) — ссылка на неопределённый upvalue вместо локального `isRaid` (`:785`).
- `view` shadow (`LootSniffer.lua:548`, `RollFrame.lua:128`) — `if not view then local view = ...` реинициализирует scrollbox на каждом вызове.
- `realm` leak (`LootSniffer.lua:580`) — `unitName, realm = UnitFullName(...)` без `local`.

**Мёртвый код:**
- Файлы: `MythicPlusLootTracker-ItemRank.lua` (пустой), `MythicPlusLootTracker-Core_old.xml`.
- Функции в Core: `GetItemSource` (`:241`), `isDungeonInCurrentSeason` (`:371`), цепочка `FixAboba`/`FixBrokenLinks`/`IsLinkBroken`/`GetItemIDFromName` (`:273-366`).
- `showOnlyEquip` (`:4`) без писателя → мёртвая ветка `:635-644`.
- Регистрация `CHAT_MSG_LOOT` (`:1442`) без обработчика.
- `RegisterAddonMessagePrefix('MPLT')` (`:46`) — нет ни `SendAddonMessage`, ни обработчика `CHAT_MSG_ADDON`.
- `issecretvalue` guards (`Core.lua:1378`, `RollFrame.lua:243,274`) — несуществующий глобал, всегда `nil`.
- LootSniffer: `GetCachedItem`, `:Timer`, `testTable`+`:Test()`. RollFrame: `:Test()`.
- AltManager: `MPLT_AltManagerItemsMixin`, построитель `isClassItem` (`:14-44`) — `IsItemClassSet` использует `classSetItems`.
- `LibSharedMedia-3.0` — загружается, нигде не вызывается вне `libs/`.

**Опечатки в именах (кросс-файловые):**
- `EJInstaceIDToMapID` / `MapIDToEJInstaceID` / `InstaceIDToMapID` (→ `...Instance...`).
- `GetDungeonTableLenght` (→ `GetTableLength`).
- `IsEquppable` (→ `IsEquippable`, LootSniffer).
- `riadInstanceID` (→ `raidInstanceID`, ClassCodexImport).
- `showLootShiffButton` (→ `showLootSnifferButton`, Core).

**Дублирование кода:**
- `done`-таблица отслеживаемого предмета: `Core.lua:839-848` ↔ `ClassCodexImport.lua:102-111`.
- `(itemType == 2) or (itemType == 4)` — 6 раз (Core, Luck, LootSniffer).
- `local name, realm = UnitFullName("player"); local playerID = name.."-"..realm` — ~10 раз.
- Блок отмены автозакрытия таймера — 5 раз (LootSniffer ×3, RollFrame ×2).
- «if nil then =1 else +1» для `MPLH_ENC_ENDED` — 2 раза в `CalcDungeonStat` (`:409-414`, `:423-427`).
- `ContinueOnItemLoad`-или-сразу обёртка —多处.

**Бог-функции:**
- `ProcessData` (`Core.lua:1106-1305`, ~200 строк) — смешивает построение UI и toggle.
- `StoreCharacterData` (`Core.lua:901-1099`, ~199 строк).
- `MPLT_AltManagerMixin:InitElements` (`AltManager.lua:74-275`, ~202 строк).
- `UpdateItemTable` (`Core.lua:625-741`, ~117 строк).
- `EJTrackItem` (`Core.lua:781-885`, ~105 строк).

**Магические числа:** `999999` (Great Vault), `888888` (Overall), `2393` (Great Vault mapID), `23` (EJ Mythic+ difficulty), `0.40` (drop rate), `1194` (megadungeon), `49` (vault interaction), `199202` (hardcoded itemID), difficulty `8/15/16/23`, thresholds `1/4/8`, slot `1/3/4/6/9/16` + skip `4`, `UnitLevel < 90`.

**Локализация:**
- Мёртвые ключи `valor`/`flux`/`dinar` (нет читателей).
- Хардкод: `"Characters"`, `"Seasons"`, `"Overall"`, `"No keystone"`, `"No RIO"`, `"ilvl"`, `"rio"`, `"Traded item"`, `"Mythic+ Loot Tracker"`.
- Фрагментная сборка `got1+got2+got3+gotTraded+gotChance` (`Tracking.lua:115-121`) — нельзя менять порядок слов при переводе.
- `helpBox`/`helpButton` — координаты layout, не строки; лежат в localization.
- `RollFrame` переиспользует `snifferAutoclose` вместо своего ключа.
- Цвета `|cff858585`/`|cffd9d7d7` вшиты в строки локализации и повторно применяются в Lua.

---

## Этап 1. Удаление мёртвого кода и файлов (низкий риск)

**Цель:** убрать всё, что не загружается и не вызывается, без изменения поведения.

- [ ] Удалить файлы `MythicPlusLootTracker-ItemRank.lua` (пустой), `MythicPlusLootTracker-Core_old.xml` (не в `.toc`).
- [ ] `Core.lua`: удалить мёртвые функции — `GetItemSource` (`:241`), `isDungeonInCurrentSeason` (`:371`), цепочку `FixAboba`/`FixBrokenLinks`/`IsLinkBroken`/`GetItemIDFromName` (`:273-366`) и закомментированные вызовы (`:367-369`).
- [ ] `Core.lua`: удалить неиспользуемое — `showOnlyEquip` (`:4`) и ветку `if showOnlyEquip` (`:635-644`); регистрацию `CHAT_MSG_LOOT` (`:1442`); `RegisterAddonMessagePrefix('MPLT')` (`:46`).
- [ ] `LootSniffer.lua`: удалить `GetCachedItem` (`:136-145`), `MPLT_LootSnifferMixin:Timer` (`:427-435`), `testTable`+`:Test()` (`:608-613`).
- [ ] `RollFrame.lua`: удалить `:Test()` (`:234-239`).
- [ ] `AltManager.lua`: удалить `MPLT_AltManagerItemsMixin` (`:4`); удалить построитель `isClassItem` (`:14-44`).
- [ ] Удалить `issecretvalue` guards (`Core.lua:1378`, `RollFrame.lua:243,274`) и весь закомментированный блок `Core.lua:1377-1386`.
- [ ] Удалить debug `print` (Core: `253,375,377,435,554,731`; ClassCodexImport: `:50,135`; прочие).
- [ ] Удалить все закомментированные блоки кода (Core: `138-140,912-945,1051-1077,1451`; ClassCodexImport: `57-59`; Luck; AltManager; и т.д.).
- [ ] Удалить неиспользуемую либу `LibSharedMedia-3.0` из `libs.xml` и директорию `libs/LibSharedMedia-3.0/`.

## Этап 2. Исправление багов и утечек (низкий риск)

- [ ] `fotune = "N/A"` → `local fortune = "N/A"` (`Core.lua:460`).
- [ ] `dungeonID = select(3, ...)` → `local dungeonID` (`Core.lua:212`) либо убрать (не читается).
- [ ] `IsRaid and ...` → `isRaid and ...` (`Core.lua:807`).
- [ ] `view` shadow (`LootSniffer.lua:548`, `RollFrame.lua:128`) — вынести `view` в file scope/upvalue, создавать один раз.
- [ ] `realm` leak (`LootSniffer.lua:580`) — добавить `local`.

## Этап 3. Унификация стиля и переименование опечаток (средний риск)

Один проход search-replace по кросс-файловым ссылкам:

- [ ] `EJInstaceIDToMapID` / `MapIDToEJInstaceID` / `InstaceIDToMapID` → `...Instance...`.
- [ ] `GetDungeonTableLenght` → `GetTableLength`.
- [ ] `IsEquppable` → `IsEquippable` (LootSniffer).
- [ ] `riadInstanceID` → `raidInstanceID` (ClassCodexImport).
- [ ] `showLootShiffButton` → `showLootSnifferButton` (Core).
- [ ] Унифицировать отступы (tabs/spaces) и кавычки (`'...'` vs `"..."`).
- [ ] Убрать бессмысленное `_G["MPLH_..."]` там, где рядом bare `MPLH_...` (CalcFortune, ClassCodexImport, Tracking) — привести к bare global.
- [ ] Заменить `isKeyInTable(t, k)` на `t[k] ~= nil` (O(1) вместо O(n)); `isValueinTable` оставить только где нужен поиск по значению.
- [ ] Согласовать `seasonID` vs `Addon.currentSeason`: единый источник — `Addon.currentSeason`, дропдаун сезона обновляет его (сейчас расходится с file-local `seasonID`).

## Этап 4. Выделение констант (средний риск)

Создать `MythicPlusLootTracker-Constants.lua` (логические константы, без ID-данных), подключить в `.toc` после `GlobalConstants.lua`:

- [ ] Магические числа: `GREAT_VAULT_ID = 999999`, `OVERALL_ID = 888888`, `GREAT_VAULT_MAP_ID = 2393`, `EJ_DIFFICULTY_MYTHIC_PLUS = 23`, `LOOT_DROP_RATE = 0.40`, `GREAT_VAULT_INTERACTION_TYPE = 49`, `MIN_CHARACTER_LEVEL = 90`, `MPLUS_DIFFICULTY_INDICES = {8,15,16,23}`, `KEY_THRESHOLDS = {1,4,8}`, `MAX_KEY_RUNS = 8`, `INVENTORY_SLOTS = {1,3,4,6,9,16}` (skip `4`).
- [ ] Цвета: `Color.TextGray = "|cff858585"`, `Color.TextLight = "|cffd9d7d7"`, `Color.Epic = "|cffa335ee"`, `Color.AltGray = "|cffc7c7c7"`, `Color.AltDim = "|cff7d7d7d"`, `Color.Brand = "|cFFAA13D4"`, `Color.BisGreen`, `Color.BorderBlue` (из XML), `Color.BorderPink` (Tracking nine-slice).
- [ ] Layout: размеры/якоря главного окна (`800x495`), scrollframe, контента, табов; общие `775` ширина и `5,-45/-65` офсеты.
- [ ] Перенести `helpBox`/`helpButton` из localization в Constants.

## Этап 5. Общие хелперы (средний риск)

- [x] `Addon.GetPlayerID()` — заменить ~10 дублей `UnitFullName`-блоков.
- [x] `Addon.MakeTrackedItemRecord(itemID)` — убрать дубль done-таблицы, инкапсулировать инвариант трёх таблиц (`TRACKITEM` + `TRACKITEM_ORDER` + `TRACKEDITEM_ITEMORDER`).
- [x] `Addon.IsEquippableItemType(itemType)` — убрать 6 дублей `(itemType == 2) or (itemType == 4)`.
- [x] Хелпер автозакрытия таймера — убрать 5 дублей (LootSniffer ×3, RollFrame ×2).
- [x] Хелпер `ContinueOnItemLoad`-или-сразу — убрать дублирование cache-check обёртки.
- [x] `Addon.GetTableLength(t)` — обёртка с nil-guard; `#tbl` для массивов где можно.

## Этап 6. Разбивка Core.lua на модули (высокий риск — главный этап)

Цель: `Core.lua` (1451 строк) → тематические файлы. Каждый начинается с `local AddonName, Addon = ...`, добавляется в `.toc` в правильном порядке.

Новая структура:

- [ ] `MythicPlusLootTracker-SavedVariables.lua` — `AddonLoadedEvent` (init/migration 8 SavedVariables).
- [ ] `MythicPlusLootTracker-EventDispatcher.lua` — `eventHandlerFrame`, `ProcessEvent`, регистрация событий.
- [ ] `MythicPlusLootTracker-ItemLink.lua` — `RecreateItemLink`, `SplitItemLink`.
- [ ] `MythicPlusLootTracker-LootProcessing.lua` — `LootReceivedEvent`, `EncounterLooted`, `CalcDungeonStat`, `CalcFortune`, `CalcChance`, `DetectGreatVault`, `DetectTrade`.
- [ ] `MythicPlusLootTracker-CharacterData.lua` — `StoreCharacterData` (разбить на хелперы: gear, mythicRuns, raidRuns, keystone, score).
- [ ] `MythicPlusLootTracker-EncounterJournal.lua` — `EJTrackItem`, `OnDataRangeChanged`, `InstanceIDToMapID`, инъекция `MPLT_ButtonHolder`/`EJTracker_HelpButton` в `Blizzard_EncounterJournal`, help plate.
- [ ] `MythicPlusLootTracker-MainWindow.lua` — `CreateMainWindow()` (UI из first-call `ProcessData`) + `ToggleMainWindow()` (else-branch) + `SetTabs` + `MPLT_UpdateSubFrames` + `Tab_OnClick`.
- [ ] `MythicPlusLootTracker-LDBIcon.lua` — `Addon:InitIcon`, `Addon:Init`.

Порядок в `.toc` (зависимости вниз): GlobalConstants → Constants → SavedVariables → ItemLink → LootProcessing → CharacterData → EncounterJournal → MainWindow → LDBIcon → EventDispatcher → (Luck, Tracking, AltManager, LFG, LootSniffer, RollFrame, data, ClassCodexImport).

- [ ] `MPLTCoreMixin` остаётся глобальным (XML ссылается), переезжает в `MainWindow.lua` или `EncounterJournal.lua` (где `OnHide` по смыслу).
- [ ] Глобальные фреймы (`MPLTLootFrame`, `MPLTDropDown`, `MPLTDropDownSeason`) остаются глобальными (к ним обращаются из других файлов).
- [ ] Кросс-файловые функции (`PrepareEncounterList`, `GetEncounter`, `RecreateItemLink`, `CalcFortune`, `MPLT_UpdateSubFrames`, `StoreCharacterData`) → на `Addon.*` вместо голых глобалов (поэтапно, с обновлением точек вызова).
- [ ] После этапа — отдельное тщательное тестирование загрузки и всех табов.

## Этап 7. Рефакторинг GlobalConstants.lua (средний риск)

- [ ] Унифицировать три ID-таблицы (`currentSeasonEncounters`, `EJInstaceIDToMapID`, `ActivityID`) в одну таблицу подземелий `[mapID] = { ejID, activityID, encounters, name }` с производными lookup-таблицами при загрузке — убирает баги «дублирующийся ключ молча перезаписывается» (`[1194]`, `[1178]`, Karazhan).
- [ ] Удалить закомментированные альтернативные маппинги и мёртвые записи (Mechagon Junkyard, Karazhan).
- [ ] Исправить дубликаты энкаунтеров: `[464]` Time-Lost Battlefield (`:293-294`), `[353]` Chopper Redhook (`:178,183`).
- [ ] `MapIDToEJInstaceID` / `RaidEJInstanceID` — либо заполнять eagerly (файл самодостаточен), либо документировать как runtime-populated (комментарий-данные разрешён).
- [ ] Переименовать `EJInstace...` → `EJInstance...` (согласовано с Этапом 3).
- [ ] Оставить имена боссов/сезонов как комментарии-данные (по принципам).

## Этап 8. Локализация (средний риск)

- [ ] Удалить мёртвые ключи `valor`/`flux`/`dinar` (нет читателей).
- [ ] Локализовать хардкод: `"Characters"`, `"Seasons"` (Core:1226,1258), `"Overall"` (Core:225, ClassCodexImport:5,45,152), `"No keystone"`/`"No RIO"`/`"ilvl"`/`"rio"` (AltManager:83,161,163,190,191), `"Traded item"` (Luck:39), `"Mythic+ Loot Tracker"`/тултип (Core:1311,1322) — добавить ключи в оба файла.
- [ ] Заменить фрагментную сборку `got1+got2+got3+gotTraded+gotChance` (`Tracking.lua:115-121`) на один `string.format`-паттерн с плейсхолдерами.
- [ ] Добавить `rollAutoclose` вместо переиспользования `sninnerAutoclose` (RollFrame.lua:90).
- [ ] `helpBox`/`helpButton` — перенести в Constants (Этап 4), из localization убрать.
- [ ] Синхронизировать EN/RU.

## Этап 9. AltManager — XML и бог-функция (высокий риск)

- [ ] `AltManager.xml` (1062 строк): заменить 16 ручных `ItemFrameN` + 8 `DungeonN` (~840 строк) на один `MPLT_AltManagerSlotTemplate` + цикл в Lua (Lua уже обращается по индексу `frame["ItemFrame"..i]`).
- [ ] Убрать `mixin="MPLT_AltManagerMixin"` с 27 дочерних фреймов (`OnEnter` пустой).
- [ ] 9-slice бордюр `CharacterFrame` (8 текстур × повтор цвета, `:20-72`) → `NineSlicePanel` или общий шаблон (аналогично `Tracking.xml`).
- [ ] Разбить `MPLT_AltManagerMixin:InitElements` (202 строки) на хелперы: keystone, dungeons tooltip, ilvl/prog, rio, gear slots — разделить доступ к данным (`MPLH_KACDATA`) и рендеринг.
- [ ] `OutputLogMixin` (пустой, XML ссылается) — либо оставить пустой глобал, либо убрать ссылку из XML.
- [ ] `OutputLogTemplate.xml`: удалить мёртвый блок `MPLT_Frame` (`:46-129`, `MPLT_FrameMixin` не определён), profession-flavored дефолты (`PROFESSIONS_*`).

## Этап 10. Прочие модули и UI/XML (средний риск)

- [ ] `Tracking.xml`: убрать мёртвый `local oldSelection` (`Tracking.lua:9`); 9-slice → общий шаблон; хардкод `<Color>` → константы.
- [ ] `LootSniffer.xml`/`RollFrame.xml`: убрать хардкод `text="w"`/`text="p"` (Lua уже ставит); хардкод-цвета → константы; анимация `NeedRollAnim` (RollFrame.xml:171-250) — тайминги в константы (низкий приоритет).
- [ ] `Luck.xml`: убрать profession-flavored дефолт `CritText`; дедуплицировать item-card шаблон с `MPLT_Frame` (после удаления мёртвого `MPLT_Frame` — Luck-шаблон становится единственным).
- [ ] `ClassCodexImport.lua`: переименовать параметр `type` (тенит builtin) → `sourceType`; убрать `_G[...]` mix (Этап 3).
- [ ] `LFG.lua`: привести к единому стилю доступа.
- [ ] (Опционально) Унификация списков: legacy `UpdateItemTable` (Core, `CreateFramePool` + manual anchoring) → миграция на `DataProvider`+`ScrollBoxListLinearView`. Убирает 5 frame-pool глобалов и ручной offset-матан. Если рискованно — отложить.

## Что НЕ входит в scope

- Изменение логики/поведения аддона (только рефакторинг).
- Обновление сезонных данных (ID-таблицы, `currentSeason`) — отдельная задача (см. AGENTS.md).
- Scraper `FromClassCodex/` (TypeScript) — не трогаем.
- `data/*.lua` — генерируется, не редактируется руками.
- Реализация addon-comms (приёмник `CHAT_MSG_ADDON`) — убираем мёртвую регистрацию, но не добавляем новую фичу.

## Проверка после каждого этапа

- [ ] Синтаксис: `luac -p` / `luacheck` если доступны.
- [ ] `.toc` валидность: порядок загрузки, все файлы из `.toc` существуют.
- [ ] Загрузка в игре: `/reload` после этапа → сообщить об ошибках → фикс.
- [ ] После Этапа 6 (разбивка Core) — отдельное тщательное тестирование всех табов и событий (лут, ролл, попрошайка, альт-менеджер, импорт).

## Трекер прогресса

Обновлять чекбоксы по мере выполнения. После завершения этапа — коммит с сообщением вида `refactor(N): <этап>`, где N — номер этапа.

- [x] Этап 1 — Удаление мёртвого кода и файлов
- [x] Этап 2 — Исправление багов и утечек
- [x] Этап 3 — Унификация стиля и переименование опечаток
- [x] Этап 4 — Выделение констант
- [x] Этап 5 — Общие хелперы
- [ ] Этап 6 — Разбивка Core.lua на модули
- [ ] Этап 7 — Рефакторинг GlobalConstants.lua
- [ ] Этап 8 — Локализация
- [ ] Этап 9 — AltManager — XML и бог-функция
- [ ] Этап 10 — Прочие модули и UI/XML