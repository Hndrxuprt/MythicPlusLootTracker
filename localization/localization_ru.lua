if GetLocale() ~= "ruRU" then return end

local AddonName, Addon = ...

Addon.localization = {}

Addon.localization.title = "Mythic Plus Loot Tracker"
Addon.localization.dStatTitle = "Статистика Подземелья"
Addon.localization.fortune = "Везение:"
Addon.localization.runs = "Пройдено:"

Addon.localization.tab1 = " Удача "
Addon.localization.tab2 = " Отслеживание "
Addon.localization.tab3 = " AltManager "

Addon.localization.characters = "Персонажи"
Addon.localization.seasons = "Сезоны"
Addon.localization.overall = "Итого"
Addon.localization.noKeystone = "Нет ключа"
Addon.localization.noRIO = "Нет RIO"
Addon.localization.ilvl = "илвл"
Addon.localization.rio = "рио"
Addon.localization.tradedItem = "Обменян"

Addon.localization.since = "|cff858585Отслеживается с: "
Addon.localization.attempts = "Попыток: "
Addon.localization.chance = "|cff858585Шанс: "
Addon.localization.done = "|cff858585Получен |cffd9d7d7%s |cff858585после |cffd9d7d7%s |cff858585попыток |cff858585с шансом |cffd9d7d7%s%%|r"
Addon.localization.doneTraded = "|cff858585Получен |cffd9d7d7обменом |cffd9d7d7%s |cff858585после |cffd9d7d7%s |cff858585попыток |cff858585с шансом |cffd9d7d7%s%%|r"

Addon.localization.updDate = "Обновлено: "

Addon.localization.gvault = "Великое Хранилище"

Addon.localization.showEquip = "Только экипировка"

Addon.localization.version = "Версия: "

Addon.localization.mbutton     = "ЛКМ (клик) - открыть окно\n" ..
                                "ЛКМ (зажать) - передвинуть иконку"


Addon.localization.season = {
    "BfA Season 1", --[1]
    "BfA Season 2", --[2]
    "BfA Season 3", --[3]
    "BfA Season 4", --[4]
    "SL Season 1", --[5]
    "SL Season 2", --[6]
    "SL Season 3", --[7]
    "SL Season 4", --[8]
    "DF Season 1", --[9]
    "DF Season 2", --[10]
    "DF Season 3", --[11]
    "DF Season 4", --[12]
    "TWW Season 1", --[13]
    "TWW Season 2", --[14]
    "TWW Season 3", --[15]
    "TWW Season 4", --[16]
    "Midnight Season 1", --[17]
    "Midnight Season 2", --[18]
    "Midnight Season 3", --[19]
}

Addon.localization.help1 = "Вы можете добавлять и удалять предметы для отслеживания в Mythic Plus Loot Tracker"
Addon.localization.help2 = "Для рейдов отслеживание работает в любом режиме, для подземелий только в `Эпохальный+`"
Addon.localization.help3 = "Отслеживание предметов доступно для Подземелий и Рейдов"

Addon.localization.snifferTitle = "Попрошайка"
Addon.localization.snifferW = "Ш"
Addon.localization.snifferP = "П"
Addon.localization.snifferAutoclose = "Автозакрытие"
Addon.localization.rollAutoclose = "Автозакрытие"

Addon.localization.rollButton = "Ролл"

Addon.localization.addonName = "Mythic+ Loot Tracker"

Addon.localization.CCImportButton = "Импорт"
Addon.localization.CCImportButtonDesc1 = "Отслеживать предметы из аддона Class Codex"
Addon.localization.CCImportButtonDesc2 = "IcyVeins Guide BIS"
Addon.localization.CCImportButtonDesc3 = "Click - Mythic+"
Addon.localization.CCImportButtonDesc4 = "Shift+Click - Raid"
Addon.localization.CCImportButtonDesc5 = "Alt+Click - Overall"

Addon.localization.compactView = "Компактный вид"
Addon.localization.compactViewExpand = "Полный вид"

Addon.localization.runs = "Прохождений: "
Addon.localization.items = "Предметов: "
Addon.localization.fortuneLabel = "Везение: "

Addon.localization.runsLabel = "Прохожд."
Addon.localization.itemsLabel = "Предметов"
Addon.localization.luckLabel = "Везение"