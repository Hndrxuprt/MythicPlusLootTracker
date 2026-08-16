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

Addon.localization.valor = "Доблесть: "
Addon.localization.flux = "Ветер: "
Addon.localization.dinar = "Динары: "

Addon.localization.since = "|cff858585Отслеживается с: "
Addon.localization.attempts = "|cff858585Попыток: "
Addon.localization.chance = "|cff858585Шанс: "
Addon.localization.got1 = "|cff858585Получен "
Addon.localization.got2 = " |cff858585после "
Addon.localization.got3 = " |cff858585попыток"
Addon.localization.gotTraded = "|cffd9d7d7обменом "
Addon.localization.gotChance = " |cff858585с шансом "

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
Addon.localization.helpBox = { x = 300, y = -470, width = 165, height = 40 }
Addon.localization.helpButton = { x = 420,  y = -470 }

Addon.localization.snifferTitle = "Попрошайка"
Addon.localization.snifferW = "Ш"
Addon.localization.snifferP = "П"
Addon.localization.snifferAutoclose = "Автозакрытие"

Addon.localization.rollButton = "Ролл"

Addon.localization.CCImportButton = "Импорт"
Addon.localization.CCImportButtonDesc1 = "Отслеживать предметы из аддона Class Codex"
Addon.localization.CCImportButtonDesc2 = "IcyVeins Guide BIS"
Addon.localization.CCImportButtonDesc3 = "Click - Mythic+"
Addon.localization.CCImportButtonDesc4 = "Shift+Click - Raid"
Addon.localization.CCImportButtonDesc5 = "Alt+Click - Overall"