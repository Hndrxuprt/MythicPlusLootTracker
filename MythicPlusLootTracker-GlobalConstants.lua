local AddonName, Addon = ...

--C_MythicPlus.GetCurrentSeason()
Addon.currentSeason = 18

-- Dungeon data keyed by mapID (MapChallengeMode).
-- name = dungeon name, journalInstanceID = EJ_GetInstanceByIndex, activityIDs = LFG activity IDs, encounters = boss IDs.
-- IDs from https://wago.tools/db2/JournalEncounter and https://wago.tools/db2/MapChallengeMode
-- Activity IDs from https://github.com/0xbs/premade-groups-filter-helper
Addon.Dungeons = {
    [2] = { name = "Temple of the Jade Serpent", journalInstanceID = 313, activityIDs = { 1192 }, encounters = {
        672, --Wise Mari
        664, --Lorewalker Stonestep
        658, --Liu Flameheart
        335, --Sha of Doubt
    } },
    [161] = { name = "Skyreach", journalInstanceID = 476, activityIDs = { 182 }, encounters = {
        965, --Ranjit
        966, --Araknath
        967, --Rukhran
        968, --High Sage Viryx
    } },
    [163] = { name = "Bloodmaul Slag Mines", activityIDs = { 179 } },
    [164] = { name = "Auchindoun", activityIDs = { 181 } },
    [165] = { name = "Shadowmoon Burial Grounds", journalInstanceID = 537, activityIDs = { 1193 }, encounters = {
        1139, --Sadana Bloodfury
        1168, --Nhallish
        1140, --Bonemaw
        1160, --Ner'zhul
    } },
    [166] = { name = "Grimrail Depot", journalInstanceID = 536, activityIDs = { 183 }, encounters = {
        1138, --Rocketspark and Borka
        1163, --Nitrogg Thundertower
        1133, --Skylord Tovra
    } },
    [167] = { name = "Upper Blackrock Spire", activityIDs = { 186 } },
    [168] = { name = "The Everbloom", journalInstanceID = 556, activityIDs = { 184 }, encounters = {
        1214, --Witherbark
        1207, --Ancient Protectors
        1208, --Archmage Sol
        1209, --Xeri'tac
        1210, --Yalnu
    } },
    [169] = { name = "Iron Docks", journalInstanceID = 558, activityIDs = { 180 }, encounters = {
        1235, --Fleshrender Nok'gar
        1236, --Grimrail Enforcers
        1237, --Oshir
        1238, --Skulloc
    } },
    [197] = { name = "Eye of Azshara", journalInstanceID = 716, activityIDs = { 459 }, encounters = {
        1480, --Warlord Parjesh
        1490, --Lady Hatecoil
        1491, --King Deepbeard
        1479, --Serpentrix
        1492, --Wrath of Azshara
    } },
    [198] = { name = "Darkheart Thicket", journalInstanceID = 762, activityIDs = { 460 }, encounters = {
        1654, --Archdruid Glaidalis
        1655, --Oakheart
        1656, --Dresaron
        1657, --Shade of Xavius
    } },
    [199] = { name = "Black Rook Hold", journalInstanceID = 740, activityIDs = { 463 }, encounters = {
        1518, --The Amalgam of Souls
        1653, --Illysanna Ravencrest
        1664, --Smashspite the Hateful
        1672, --Lord Kur'talos Ravencrest
    } },
    [200] = { name = "Halls of Valor", activityIDs = { 461 } },
    [206] = { name = "Neltharion's Lair", journalInstanceID = 767, activityIDs = { 462 }, encounters = {
        1662, --Rokmora
        1665, --Ularogg Cragshaper
        1673, --Naraxas
        1687, --Dargrul the Underking
    } },
    [207] = { name = "Vault of the Wardens", journalInstanceID = 707, activityIDs = { 464, 1795 }, encounters = {
        1467, --Tirathon Saltheril
        1695, --Inquisitor Tormentorum
        1468, --Ash'golm
        1469, --Glazer
        1470, --Cordana Felsong
    } },
    [208] = { name = "Maw of Souls", activityIDs = { 465 } },
    [209] = { name = "The Arcway", activityIDs = { 467 } },
    [210] = { name = "Court of Stars", journalInstanceID = 800, activityIDs = { 466 }, encounters = {
        1718, --Patrol Captain Gerdo
        1719, --Talixae Flamewreath
        1720, --Advisor Melandrus
    } },
    [227] = { name = "Lower Karazhan", activityIDs = { 471 }, encounters = {
        1820, --Opera Hall: Wikket
        1826, --Opera Hall: Westfall Story
        1827, --Opera Hall: Beautiful Beast
        1825, --Maiden of Virtue
        1835, --Attumen the Huntsman
        1837, --Moroes
    } },
    [233] = { name = "Cathedral of Eternal Night", activityIDs = { 476, 1945 } },
    [234] = { name = "Upper Karazhan", activityIDs = { 473 }, encounters = {
        1836, --The Curator
        1817, --Shade of Medivh
        1818, --Mana Devourer
        1838, --Viz'aduum the Watcher
    } },
    [239] = { name = "Seat of the Triumvirate", journalInstanceID = 945, activityIDs = { 486 }, encounters = {
        1979, --Zuraal the Ascended
        1980, --Saprish
        1981, --Viceroy Nezhar
        1982, --L'ura
    } },
    [244] = { name = "Atal'Dazar", journalInstanceID = 968, activityIDs = { 502 }, encounters = {
        2082, --Priestess Alun'za
        2036, --Vol'kaal
        2083, --Rezan
        2030, --Yazma
    } },
    [245] = { name = "Freehold", journalInstanceID = 1001, activityIDs = { 518 }, encounters = {
        2093, --Council o' Captains
        2094, --Ring of Booty
        2095, --Harlan Sweete
        2102, --Skycap'n Kragg
    } },
    [246] = { name = "Tol Dagor", activityIDs = { 526 } },
    [247] = { name = "The MOTHERLODE!!", journalInstanceID = 1012, activityIDs = { 510 }, encounters = {
        2109, --Coin-Operated Crowd Pummeler
        2114, --Azerokk
        2115, --Rixxa Fluxflame
        2116, --Mogul Razdunk
    } },
    [248] = { name = "Waycrest Manor", journalInstanceID = 1021, activityIDs = { 530 }, encounters = {
        2125, --Heartsbane Triad
        2126, --Soulbound Goliath
        2127, --Raal the Gluttonous
        2128, --Lord and Lady Waycrest
        2129, --Gorak Tul
    } },
    [249] = { name = "Kings' Rest", journalInstanceID = 1041, activityIDs = { 514, 661 }, encounters = {
        2165, --The Golden Serpent
        2171, --Mchimba the Embalmer
        2170, --The Council of Tribes
        2172, --Dazar, The First King
    } },
    [250] = { name = "Temple of Sethraliss", journalInstanceID = 1030, activityIDs = { 504 }, encounters = {
        2142, --Adderis and Aspix
        2143, --Merektha
        2144, --Galvazzt
        2145, --Avatar of Sethraliss
    } },
    [251] = { name = "The Underrot", journalInstanceID = 1022, activityIDs = { 507 }, encounters = {
        2130, --Sporecaller Zancha
        2131, --Cragmaw the Infested
        2157, --Elder Leaxa
        2158, --Unbound Abomination
    } },
    [252] = { name = "Shrine of the Storm", activityIDs = { 522 } },
    [353] = { name = "Siege of Boralus", journalInstanceID = 1023, activityIDs = { 534, 659 }, encounters = {
        2132, --Chopper Redhook
        2133, --Sergeant Bainbridge
        2134, --Hadal Darkfathom
        2140, --Viq'Goth
        2173, --Dread Captain Lockwood
    } },
    [369] = { name = "Mechagon Junkyard", activityIDs = { 679 }, encounters = {
        2357, --King Gobbamak
        2358, --Gunker
        2360, --Trixie & Naeno
        2355, --HK-8 Aerial Oppression Unit
    } },
    [370] = { name = "Mechagon Workshop", journalInstanceID = 1178, activityIDs = { 683 }, encounters = {
        2336, --Tussle Tonks
        2339, --K.U.-J.0.
        2348, --Machinist's Garden
        2331, --King Mechagon
    } },
    [375] = { name = "Mists of Tirna Scithe", journalInstanceID = 1184, activityIDs = { 703 }, encounters = {
        2400, --Ingra Maloch
        2402, --Mistcaller
        2405, --Tred'ova
    } },
    [376] = { name = "The Necrotic Wake", journalInstanceID = 1182, activityIDs = { 713 }, encounters = {
        2391, --Amarth, The Harvester
        2392, --Surgeon Stitchflesh
        2395, --Blightbone
        2396, --Nalthor the Rimebinder
    } },
    [377] = { name = "De Other Side", activityIDs = { 695 } },
    [378] = { name = "Halls of Atonement", journalInstanceID = 1185, activityIDs = { 699 }, encounters = {
        2406, --Halkias, the Sin-Stained Goliath
        2387, --Echelon
        2411, --High Adjudicator Aleez
        2413, --Lord Chamberlain
    } },
    [379] = { name = "Plaguefall", activityIDs = { 691 } },
    [380] = { name = "Sanguine Depths", activityIDs = { 705 } },
    [381] = { name = "Spires of Ascension", activityIDs = { 709 } },
    [382] = { name = "Theater of Pain", journalInstanceID = 1187, activityIDs = { 717 }, encounters = {
        2389, --Kul'tharok
        2390, --Xav the Unfallen
        2397, --An Affront of Challengers
        2401, --Gorechop
        2417, --Mordretha, the Endless Empress
    } },
    [391] = { name = "Tazavesh: Streets of Wonder", journalInstanceID = 1194, activityIDs = { 1016 }, encounters = {
        2437, --Zo'phex the Sentinel
        2454, --The Grand Menagerie
        2436, --Mailroom Mayhem
        2452, --Myza's Oasis
        2451, --So'azmi
    } },
    [392] = { name = "Tazavesh: So'leah's Gambit", journalInstanceID = 1194, activityIDs = { 1017 }, encounters = {
        2448, --Hylbrande
        2449, --Timecap'n Hooktail
        2455, --So'leah
    } },
    [399] = { name = "Ruby Life Pools", journalInstanceID = 1202, activityIDs = { 1176 }, encounters = {
        2488, --Melidrussa Chillworn
        2485, --Kokia Blazehoof
        2503, --Kyrakka and Erkhart Stormvein
    } },
    [400] = { name = "The Nokhud Offensive", journalInstanceID = 1198, activityIDs = { 1184 }, encounters = {
        2498, --Granyth
        2497, --The Raging Tempest
        2478, --Teera and Maruuk
        2477, --Balakar Khan
    } },
    [401] = { name = "The Azure Vault", journalInstanceID = 1203, activityIDs = { 1180 }, encounters = {
        2492, --Leymor
        2505, --Azureblade
        2483, --Telash Greywing
        2508, --Umbrelskul
    } },
    [402] = { name = "Algeth'ar Academy", journalInstanceID = 1201, activityIDs = { 1160 }, encounters = {
        2509, --Vexamus
        2512, --Overgrown Ancient
        2495, --Crawth
        2514, --Echo of Doragosa
    } },
    [403] = { name = "Uldaman: Legacy of Tyr", journalInstanceID = 1197, activityIDs = { 1188 }, encounters = {
        2475, --The Lost Dwarves
        2476, --Emberon
        2479, --Chrono-Lord Deios
        2484, --Sentinel Talondras
        2487, --Bromach
    } },
    [404] = { name = "Neltharus", journalInstanceID = 1199, activityIDs = { 1172 }, encounters = {
        2489, --Forgemaster Gorek
        2490, --Chargath, Bane of Scales
        2494, --Magmatusk
        2501, --Warlord Sargha
    } },
    [405] = { name = "Brackenhide Hollow", journalInstanceID = 1196, activityIDs = { 1164 }, encounters = {
        2471, --Hackclaw's War-Band
        2472, --Gutshot
        2473, --Treemouth
        2474, --Decatriarch Wratheye
    } },
    [406] = { name = "Halls of Infusion", journalInstanceID = 1204, activityIDs = { 1168 }, encounters = {
        2504, --Watcher Irideus
        2507, --Gulping Goliath
        2510, --Khajin the Unyielding
        2511, --Primal Tsunami
    } },
    [438] = { name = "The Vortex Pinnacle", journalInstanceID = 68, activityIDs = { 1195 }, encounters = {
        114, --Grand Vizier Ertan
        115, --Altairus
        116, --Asaad, Caliph of Zephyrs
    } },
    [456] = { name = "Throne of the Tides", journalInstanceID = 65, activityIDs = { 1274 }, encounters = {
        101, --Lady Naz'jar
        102, --Commander Ulthok, the Festering Prince
        103, --Mindbender Ghur'sha
        104, --Ozumat
    } },
    [463] = { name = "Dawn of the Infinite: Galakrond's Fall", activityIDs = { 1247 }, encounters = {
        2521, --Chronikar
        2528, --Manifested Timeways
        2535, --Blight of Galakrond
        2537, --Iridikron the Stonescaled
    } },
    [464] = { name = "Dawn of the Infinite: Murozond's Rise", activityIDs = { 1248 }, encounters = {
        2526, --Tyr, the Infinite Keeper
        2536, --Morchie
        2533, --Time-Lost Battlefield
        2538, --Chrono-Lord Deios
    } },
    [499] = { name = "Priory of the Sacred Flame", journalInstanceID = 1267, activityIDs = { 1281 }, encounters = {
        2570, --Baron Braunpyke
        2571, --Captain Dailcry
        2573, --Prioress Murrpray
    } },
    [500] = { name = "The Rookery", journalInstanceID = 1268, activityIDs = { 1283 }, encounters = {
        2566, --Kyrioss
        2567, --Stormguard Gorren
        2568, --Voidstone Monstrosity
    } },
    [501] = { name = "The Stonevault", journalInstanceID = 1269, activityIDs = { 1287 }, encounters = {
        2572, --E.D.N.A.
        2579, --Skarmorak
        2582, --Void Speaker Eirich
        2590, --Master Machinists
    } },
    [502] = { name = "City of Threads", journalInstanceID = 1274, activityIDs = { 1288 }, encounters = {
        2594, --Orator Krix'vizk
        2595, --Fangs of the Queen
        2596, --Izo, the Grand Splicer
        2600, --The Coaglamation
    } },
    [503] = { name = "Ara-Kara, City of Echoes", journalInstanceID = 1271, activityIDs = { 1284 }, encounters = {
        2583, --Avanoxx
        2584, --Anub'zekt
        2585, --Ki'katal the Harvester
    } },
    [504] = { name = "Darkflame Cleft", journalInstanceID = 1210, activityIDs = { 1282 }, encounters = {
        2559, --Blazikon
        2560, --The Candle King
        2561, --The Darkness
        2569, --Ol' Waxbeard
    } },
    [505] = { name = "The Dawnbreaker", journalInstanceID = 1270, activityIDs = { 1285 }, encounters = {
        2580, --Speaker Shadowcrown
        2581, --Anub'ikkaj
        2593, --Rasha'nan
    } },
    [506] = { name = "Cinderbrew Meadery", journalInstanceID = 1272, activityIDs = { 1286 }, encounters = {
        2586, --Brew Master Aldryr
        2587, --I'pa
        2588, --Benk Buzzbee
        2589, --Goldie Baronbottom
    } },
    [507] = { name = "Grim Batol", journalInstanceID = 71, activityIDs = { 1290 }, encounters = {
        2617, --General Umbriss
        2618, --Drahga Shadowburner
        2619, --Erudax, the Duke of Below
        2627, --Forgemaster Throngus
    } },
    [525] = { name = "Operation: Floodgate", journalInstanceID = 1298, activityIDs = { 1550 }, encounters = {
        2648, --Big M.O.M.M.A.
        2649, --Demolition Duo
        2650, --Swampface
        2651, --Geezle Gigazap
    } },
    [542] = { name = "Eco-Dome Al'dani", journalInstanceID = 1303, activityIDs = { 1694 }, encounters = {
        2675, --Azhiccar
        2676, --Taah'bat and A'wazj
        2677, --Soul-Scribe
    } },
    [556] = { name = "Pit of Saron", journalInstanceID = 278, activityIDs = { 1770 }, encounters = {
        608, --Forgemaster Garfrost
        609, --Ick and Krick
        610, --Scourgelord Tyrannus
    } },
    [557] = { name = "Windrunner Spire", journalInstanceID = 1299, activityIDs = { 1542 }, encounters = {
        2657, --Commander Kroluk
        2656, --Derelict Duo
        2655, --Emberdawn
        2658, --The Restless Heart
    } },
    [558] = { name = "Magisters' Terrace", journalInstanceID = 1300, activityIDs = { 1760 }, encounters = {
        2659, --Arcanotron Custos
        2662, --Degentrius
        2660, --Gemellus
        2661, --Seranel Sunlash
    } },
    [559] = { name = "Nexus-Point Xenas", journalInstanceID = 1316, activityIDs = { 1768 }, encounters = {
        2813, --Chief Corewright Kasreth
        2814, --Corewarden Nysarra
        2815, --Lothraxion
    } },
    [560] = { name = "Maisara Caverns", journalInstanceID = 1315, activityIDs = { 1764 }, encounters = {
        2810, --Muro'jin and Nekraxx
        2812, --Rak'tul, Vessel of Souls
        2811, --Vordaza
    } },
    [584] = { name = "The Blinding Vale", journalInstanceID = 1309, activityIDs = { 1949 }, encounters = {
        2769, --Lightblossom Trinity
        2770, --Ikuzz the Light Hunter
        2771, --Lightwarden Ruia
        2772, --Ziekket
    } },
    [585] = { name = "Voidscar Arena", journalInstanceID = 1313, activityIDs = { 1951 }, encounters = {
        2791, --Taz'Rah
        2792, --Atroxus
        2793, --Charonus
    } },
    [586] = { name = "Den of Nalorakk", journalInstanceID = 1311, activityIDs = { 1952 }, encounters = {
        2776, --The Hoardmonger
        2777, --Sentinel of Winter
        2778, --Nalorakk
    } },
    [587] = { name = "Murder Row", journalInstanceID = 1304, activityIDs = { 1950 }, encounters = {
        2679, --Kystia Manaheart
        2680, --Zaen Bladesorrow
        2681, --Xathuux the Annihilator
        2682, --Lithiel Cinderfury
    } },
    [588] = { name = "Altar of Fangs", journalInstanceID = 1322, activityIDs = { 1933 }, encounters = {
        2878, --Rav'i
        2879, --The Writhing Coil
        2880, --Zul'jan
    } },
}

Addon.currentSeasonEncounters = {}
Addon.EJInstanceIDToMapID = {}
Addon.ActivityID = {}

local mapIDs = {}
for mapID in pairs(Addon.Dungeons) do
    tinsert(mapIDs, mapID)
end
table.sort(mapIDs)
for _, mapID in ipairs(mapIDs) do
    local dungeon = Addon.Dungeons[mapID]
    Addon.currentSeasonEncounters[mapID] = dungeon.encounters
    if dungeon.activityIDs then
        for _, activityID in ipairs(dungeon.activityIDs) do
            Addon.ActivityID[activityID] = mapID
        end
    end
    if dungeon.journalInstanceID then
        Addon.EJInstanceIDToMapID[dungeon.journalInstanceID] = mapID
    end
end

-- Populated at runtime by MythicPlusLootTracker-ClassCodexImport.lua (EJ_GetInstanceByIndex)
Addon.MapIDToEJInstanceID = {}
Addon.RaidEJInstanceID = {}
