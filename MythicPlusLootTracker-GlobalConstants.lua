local AddonName, Addon = ...

--C_MythicPlus.GetCurrentSeason()
Addon.currentSeason = 18

-- Boss ID's as ID, Boss name as Name_lang from https://wago.tools/db2/JournalEncounter?page=1
-- Dungeon ID's as ID, Dungeon name as Name_lang from https://wago.tools/db2/MapChallengeMode?page=1
Addon.currentSeasonEncounters = {
    -----Lich King Encounters-----
    [556] = {
        608, --Forgemaster Garfrost
        609, --Ick and Krick
        610, --Scourgelord Tyrannus
    }, --Pit of Saron
    -----Cata Encounters-----
    [438] = {
        114, --Grand Vizier Ertan
        115, --Altairus
        116, --Asaad, Caliph of Zephyrs
    }, --The Vortex Pinnacle
    [456] = {
        101, --Lady Naz'jar
        102, --Commander Ulthok, the Festering Prince
        103, --Mindbender Ghur'sha
        104, --Ozumat
    }, --Throne of the Tides
    [507] = { 
        2617, --General Umbriss
        2618, --Drahga Shadowburner
        2619, --Erudax, the Duke of Below
        2627, --Forgemaster Throngus
    }, --Grim Batol

    -----MoP Encounters-----
    [2]={
        672, --Wise Mari
        664, --Lorewalker Stonestep
        658, --Liu Flameheart
        335, --Sha of Doubt
    }, --Temple of the Jade Serpent

    -----WoD Encounters-----
    [165]={
        1139, --Sadana Bloodfury
        1168, --Nhallish
        1140, --Bonemaw
        1160, --Ner'zhul
    }, --Shadowmoon Burial Grounds
    [166] = {
        1138, --Rocketspark and Borka
        1163, --Nitrogg Thundertower
        1133, --Skylord Tovra
    }, --Depot
    [168] = {
        1214, --Witherbark
        1207, --Ancient Protectors
        1208, --Archmage Sol
        1209, --Xeri'tac
        1210, --Yalnu
    }, --Everbloom
    [169] = {
        1235, --Fleshrender Nok'gar
        1236, --Grimrail Enforcers
        1237, --Oshir
        1238, --Skulloc
    }, --Iron docks    
    [161] = {
        965, --Ranjit
        966, --Araknath
        967, --Rukhran
        968, --High Sage Viryx
    }, --Skyreach
    
    -----Legion Encounters-----
    [197]={
        1480, --Warlord Parjesh
        1490, --Lady Hatecoil
        1491, --King Deepbeard
        1479, --Serpentrix
        1492, --Wrath of Azshara
    }, --Eye of Azshara
    [198] = {
        1654, --Archdruid Glaidalis
        1655, --Oakheart
        1656, --Dresaron
        1657, --Shade of Xavius
    }, --Darkheart Thicket
    [199] = {
        1518, --The Amalgam of Souls
        1653, --Illysanna Ravencrest
        1664, --Smashspite the Hateful
        1672, --Lord Kur'talos Ravencrest
    }, --Black Rook Hold
    [206] = {
        1662, --Rokmora
        1665, --Ularogg Cragshaper
        1673, --Naraxas
        1687, --Dargrul the Underking
    }, --Neltharion's Lair
    [207]={
        1467, --Tirathon Saltheril
        1695, --Inquisitor Tormentorum
        1468, --Ash'golm
        1469, --Glazer
        1470, --Cordana Felsong
    }, --Vault of the Wardens
    [210]={
        1718, --Patrol Captain Gerdo
        1719, --Talixae Flamewreath
        1720, --Advisor Melandrus
    }, --Court of Stars
    [227] = {
        1820, --Opera Hall: Wikket
        1826, --Opera Hall: Westfall Story
        1827, --Opera Hall: Beautiful Beast
        1825, --Maiden of Virtue
        1835, --Attumen the Huntsman
        1837, --Moroes
    }, --Karazhan lower
    [234] = {
        1836, --The Curator
        1817, --Shade of Medivh
        1818, --Mana Devourer
        1838, --Viz'aduum the Watcher
    }, --Karazhan upper
    [239] = {
        1979, --Zuraal the Ascended
        1980, --Saprish
        1981, --Viceroy Nezhar
        1982, --L'ura
    }, --Seat of the Triumvirate

    -----BfA Encounters-----
    [244] = {
        2082, --Priestess Alun'za
        2036, --Vol'kaal
        2083, --Rezan
        2030, --Yazma
    }, --Atal'Dazar
    [245] = {
        2093, --Council o' Captains
        2094, --Ring of Booty
        2095, --Harlan Sweete
        2102, --Skycap'n Kragg
    }, --Freehold
    [247] = {
        2109, --Coin-Operated Crowd Pummeler
        2114, --Azerokk
        2115, --Rixxa Fluxflame
        2116, --Mogul Razdunk
    }, --The MOTHERLODE!!
    [248] = {
        2125, --Heartsbane Triad
        2126, --Soulbound Goliath
        2127, --Raal the Gluttonous
        2128, --Lord and Lady Waycrest
        2129, --Gorak Tul
    }, --Waycrest Manor
    [251] = {
        2130, --Sporecaller Zancha
        2131, --Cragmaw the Infested
        2157, --Elder Leaxa
        2158, --Unbound Abomination
    }, --The Underrot   
    [369] = {
        2357, --King Gobbamak
        2358, --Gunker
        2360, --Trixie & Naeno
        2355, --HK-8 Aerial Oppression Unit
    }, --Mechagon junkyard
    [370] = {
        2336, --Tussle Tonks
        2339, --K.U.-J.0.
        2348, --Machinist's Garden
        2331, --King Mechagon
    }, --Mechagon workshop
    [353] = { 
        2132, --Chopper Redhook
        2133, --Sergeant Bainbridge
        2134, --Hadal Darkfathom
        2140, --Viq'Goth
        2173, --Dread Captain Lockwood
        2654, --Chopper Redhook
    }, --Siege of Boralus
    [249] = {
        2165, --The Golden Serpent
        2171, --Mchimba the Embalmer
        2170, --The Council of Tribes
        2172, --Dazar, The First King
    }, --Kings' Rest
    [250] = {
        2142, --Adderis and Aspix
        2143, --Merektha
        2144, --Galvazzt
        2145, --Avatar of Sethraliss
    }, --Temple of Sethraliss

    -----SL Encounters-----
    [391] = {
        2437, --Zo'phex the Sentinel
        2454, --The Grand Menagerie
        2436, --Mailroom Mayhem
        2452, --Myza's Oasis
        2451, --So'azmi
    }, --Tazavesh streets
    [392] = {
        2448, --Hylbrande
        2449, --Timecap'n Hooktail
        2455, --So'leah
    }, --Tazavesh gambit
    [375] = {
        2400, --Ingra Maloch
        2402, --Mistcaller
        2405, --Tred'ova
    }, --Mists of Tirna Scithe
    [376] = {
        2391, --Amarth, The Harvester
        2392, --Surgeon Stitchflesh
        2395, --Blightbone
        2396, --Nalthor the Rimebinder
    }, --The Necrotic Wake
    [378] = {
        2406, --Halkias, the Sin-Stained Goliath
        2387, --Echelon
        2411, --High Adjudicator Aleez
        2413, --Lord Chamberlain
    }, --Halls of Atonement
    [382] = {
        2389, --Kul'tharok
        2390, --Xav the Unfallen
        2397, --An Affront of Challengers
        2401, --Gorechop
        2417, --Mordretha, the Endless Empress
    }, --Theater of Pain

    -----DF Encounters-----
    [399] = {
        2488, --Melidrussa Chillworn
        2485, --Kokia Blazehoof
        2503, --Kyrakka and Erkhart Stormvein
    }, --Ruby Life Pools
    [400] = {
        2498, --Granyth
        2497, --The Raging Tempest
        2478, --Teera and Maruuk
        2477, --Balakar Khan
    }, --The Nokhud Offensive
    [401] = {
        2492, --Leymor
        2505, --Azureblade
        2483, --Telash Greywing
        2508, --Umbrelskul
    }, --The Azure Vault
    [402] = {
        2509, --Vexamus
        2512, --Overgrown Ancient
        2495, --Crawth
        2514, --Echo of Doragosa  
    }, --Algeth'ar Academy
    [403] = {
        2475, --The Lost Dwarves
        2476, --Emberon
        2479, --Chrono-Lord Deios
        2484, --Sentinel Talondras
        2487, --Bromach
    }, --Uldaman: Legacy of Tyr
    [404] = {
        2489, --Forgemaster Gorek
        2490, --Chargath, Bane of Scales
        2494, --Magmatusk
        2501, --Warlord Sargha
    }, --Neltharus
    [405] = {
        2471, --Hackclaw's War-Band
        2472, --Gutshot
        2473, --Treemouth
        2474, --Decatriarch Wratheye
    }, --Brackenhide Hollow
    [406] = {
        2504, --Watcher Irideus	
        2507, --Gulping Goliath
        2510, --Khajin the Unyielding
        2511, --Primal Tsunami
    }, --Halls of Infusion
    [463] = {
        2521, --Chronikar
        2528, --Manifested Timeways
        2535, --Blight of Galakrond
        2537, --Iridikron the Stonescaled
    }, --Dawn of the Infinite: Galakrond's Fall
    [464] = {
        2526, --Tyr, the Infinite Keeper
        2536, --Morchie
        2533, --Time-Lost Battlefield
        2534, --Time-Lost Battlefield
        2538, --Chrono-Lord Deios
    }, --Dawn of the Infinite: Murozond's Rise

    -----TWW Encounters-----
    [503] = {
        2583, --Avanoxx
        2584, --Anub'zekt
        2585, --Ki'katal the Harvester
      }, --Ara-Kara, City of Echoes
      
      [506] = {
        2586, --Brew Master Aldryr
        2587, --I'pa
        2588, --Benk Buzzbee
        2589, --Goldie Baronbottom
      }, --Cinderbrew Meadery
      
      [502] = {
        2594, --Orator Krix'vizk
        2595, --Fangs of the Queen
        2596, --Izo, the Grand Splicer
        2600, --The Coaglamation
      }, --City of Threads
      
      [504] = {
        2559, --Blazikon
        2560, --The Candle King
        2561, --The Darkness
        2569, --Ol' Waxbeard
      }, --Darkflame Cleft
      
      [499] = {
        2570, --Baron Braunpyke
        2571, --Captain Dailcry
        2573, --Prioress Murrpray
      }, --Priory of the Sacred Flame
      
      [505] = {
        2580, --Speaker Shadowcrown
        2581, --Anub'ikkaj
        2593, --Rasha'nan
      }, --The Dawnbreaker
      
      [500] = {
        2566, --Kyrioss
        2567, --Stormguard Gorren
        2568, --Voidstone Monstrosity
      }, --The Rookery
      
      [501] = {
        2572, --E.D.N.A.
        2579, --Skarmorak
        2582, --Void Speaker Eirich
        2590, --Master Machinists
      }, --The Stonevault
      [525] = {
        2648, --Big M.O.M.M.A.
        2649, --Demolition Duo
        2650, --Swampface
        2651, --Geezle Gigazap
      }, --Operation: Floodgate

      [542] = {
        2675, --Azhiccar
        2676, --Taah'bat and A'wazj
        2677, --Soul-Scribe
      }, --Eco-DOme Al'dani

    -----Midnight Encounters-----
    [558] = {
        2659, --Arcanotron Custos
        2662, --Degentrius
        2660, --Gemellus
        2661, --Seranel Sunlash
    }, --Magisters' Terrace
    [560] = {
        2810, --Muro'jin and Nekraxx
        2812, --Rak'tul, Vessel of Souls
        2811, --Vordaza
    }, --Maisara Caverns
    [559] = {
        2813, --Chief Corewright Kasreth
        2814, --Corewarden Nysarra
        2815, --Lothraxion
    }, --Nexus-Point Xenas
    [557] = {
        2657, --Commander Kroluk
        2656, --Derelict Duo
        2655, --Emberdawn
        2658, --The Restless Heart
    }, --Windrunner Spire
    [584] = {
        2769, --Lightblossom Trinity
        2770, --Ikuzz the Light Hunter
        2771, --Lightwarden Ruia
        2772, --Ziekket
    }, --The Blinding Vale
    [585] = {
        2791, --Taz'Rah
        2792, --Atroxus
        2793, --Charonus
    }, --Voidscar Arena
    [586] = {
        2776, --The Hoardmonger
        2777, --Sentinel of Winter
        2778, --Nalorakk
    }, --Den of Nalorakk
    [587] = {
        2679, --Kystia Manaheart
        2680, --Zaen Bladesorrow
        2681, --Xathuux the Annihilator
        2682, --Lithiel Cinderfury
    }, --Murder Row
    [588] = {
        2878, --Rav'i
        2879, --The Writhing Coil
        2880, --Zul'jan
    }, --Altar of Fangs
}

--JournalInstanceID from https://wago.tools/db2/JournalEncounter?page=1
--MapID is ID from https://wago.tools/db2/MapChallengeMode?page=1
--currentSeason dungeonMaps - C_ChallengeMode.GetMapTable()
Addon.EJInstanceIDToMapID = {

    -----Lich King Encounters-----
    [278] = 556, --Pit of Saron
    -----Cata Encounters-----
    [68] = 438, --The Vortex Pinnacle
    [65] = 456, --Throne of the Tides
    [71] = 507, --Grim Batol
    -----MoP Encounters-----
    [313] = 2, --Temple of the Jade Serpent	
    -----WoD Encounters-----
    [537] = 165, --Shadowmoon Burial Grounds
    [536] = 166, --Grimrail Depot
    [556] = 168, --Everbloom
    [558] = 169, --Iron Docks
    [476] = 161, --Skyreach
    -----Legion Encounters-----
    [716] = 197, --Eye of Azshara	
    [762] = 198, --Darkheart Thicket	
    [740] = 199, --Black Rook Hold	
    [767] = 206, --Neltharion's Lair	
    [707] = 207, --Vault of the Wardens	
    [800] = 210, --Court of Stars	
    --[860] = 227, --Return to Karazhan: Lower	
    --[745] = 227, --Return to Karazhan: Lower	
    --[745] = 234, --Return to Karazhan: Upper	
    --[860] = 234, --Return to Karazhan: Upper
    [945] = 239, --Seat of the Triumvirate
    -----BfA Encounters-----
    [968] = 244, --Atal'Dazar	
    [1001] = 245, --Freehold
    [1012] = 247, --The MOTHERLODE!!
    [1021] = 248, --Waycrest Manor	
    [1022] = 251, --The Underrot	
    [1023] = 353, --Siege of Boralus	
    --[1178] = 369, --Operation: Mechagon - Junkyard	
    [1178] = 370, --Operation: Mechagon - Workshop
    
    -----SL Encounters-----
    [1184] = 375, --Mists of Tirna Scithe
    [1182] = 376, --The Necrotic Wake
    [1185] = 378, --Halls of Atonement
    [1187] = 382, --Theater of Pain
    [1194] = 391, --Tazavesh: Streets of Wonder
    [1194] = 392, --Tazavesh: So'leah's Gambit
    -----DF Encounters-----
    [1202] = 399, --Ruby Life Pools
    [1198] = 400, --The Nokhud Offensive
    [1203] = 401, --The Azure Vault
    [1201] = 402, --Algeth'ar Academy
    [1197] = 403, --Uldaman: Legacy of Tyr
    [1199] = 404, --Neltharus
    [1196] = 405, --Brackenhide Hollow
    [1204] = 406, --Halls of Infusion
    --[1209] = 463, --Dawn of the Infinite: Galakrond's Fall
    --[1209] = 464, --Dawn of the Infinite: Murozond's Rise  
    -----TWW Encounters-----
    [1271] = 503, --Ara-Kara, City of Echoes
    [1272] = 506, --Cinderbrew Meadery
    [1274] = 502, --City of Threads
    [1210] = 504, --Darkflame Cleft
    [1267] = 499, --Priory of the Sacred Flame
    [1270] = 505, --The Dawnbreaker
    [1268] = 500, --The Rookery
    [1269] = 501, --The Stonevault
    [1298] = 525, --Operation: Floodgate
    [1303] = 542, --Eco-Dome Al'dani
    -----Midnight Encounters-----
    [1300] = 558, --Magisters' Terrace
    [1315] = 560, --Maisara Caverns
    [1316] = 559, --Nexus-Point Xenas
    [1299] = 557, --Windrunner Spire

    -----Midnight S2 Encounters-----
    [1322] = 588, --Altar of Fangs
    [1313] = 585, --Voidscar Arena
    [1311] = 586, --Den of Nalorakk
    [1304] = 587, --Murder Row
    [1309] = 584, --The Blinding Vale
    [1041] = 249, --Kings' Rest
    [1030] = 250, --Temple of Sethraliss
    
    
}

Addon.MapIDToEJInstanceID = {}


Addon.RaidEJInstanceID ={}

--data from https://github.com/0xbs/premade-groups-filter-helper/blob/0394d07865ab7f1eccdaa1eb00ac38a1b4f3b10e/data/Activity.lua
Addon.ActivityID = {
    [179] = 163, -- Bloodmaul Slag Mines (Challenge)
    [180] = 169, -- Iron Docks (Mythic Keystone)
    [181] = 164, -- Auchindoun (Challenge)
    [182] = 161, -- Skyreach (Challenge)
    [183] = 166, -- Grimrail Depot (Mythic Keystone)
    [184] = 168, -- The Everbloom (Mythic Keystone)
    [186] = 167, -- Upper Blackrock Spire (Challenge)
    [459] = 197, -- Eye of Azshara (Mythic Keystone)
    [460] = 198, -- Darkheart Thicket (Mythic Keystone)
    [461] = 200, -- Halls of Valor (Mythic Keystone)
    [462] = 206, -- Neltharion's Lair (Mythic Keystone)
    [463] = 199, -- Black Rook Hold (Mythic Keystone)
    [464] = 207, -- Vault of the Wardens (Mythic Keystone)
    [465] = 208, -- Maw of Souls (Mythic Keystone)
    [466] = 210, -- Court of Stars (Mythic Keystone)
    [467] = 209, -- The Arcway (Mythic Keystone)
    [471] = 227, -- Lower Karazhan (Mythic Keystone)
    [473] = 234, -- Upper Karazhan (Mythic Keystone)
    [476] = 233, -- Cathedral of Eternal Night (Mythic Keystone)
    [486] = 239, -- Seat of the Triumvirate (Mythic Keystone)
    [502] = 244, -- Atal'Dazar (Mythic Keystone)
    [504] = 250, -- Temple of Sethraliss (Mythic Keystone)
    [507] = 251, -- The Underrot (Mythic Keystone)
    [510] = 247, -- THE MOTHERLODE (Mythic Keystone)
    [514] = 249, -- Kings' Rest (Mythic Keystone)
    [518] = 245, -- Freehold (Mythic Keystone)
    [522] = 252, -- Shrine of the Storm (Mythic Keystone)
    [526] = 246, -- Tol Dagor (Mythic Keystone)
    [530] = 248, -- Waycrest Manor (Mythic Keystone)
    [534] = 353, -- Siege of Boralus (Mythic Keystone)
    [659] = 353, -- Siege of Boralus (Mythic Keystone)
    [661] = 249, -- Kings' Rest (Mythic Keystone)
    [679] = 369, -- Mechagon Junkyard (Mythic Keystone)
    [683] = 370, -- Mechagon Workshop (Mythic Keystone)
    [691] = 379, -- Plaguefall (Mythic Keystone)
    [695] = 377, -- De Other Side (Mythic Keystone)
    [699] = 378, -- Halls of Atonement (Mythic Keystone)
    [703] = 375, -- Mists of Tirna Scithe (Mythic Keystone)
    [705] = 380, -- Sanguine Depths (Mythic Keystone)
    [709] = 381, -- Spires of Ascension (Mythic Keystone)
    [713] = 376, -- The Necrotic Wake (Mythic Keystone)
    [717] = 382, -- Theater of Pain (Mythic Keystone)
    [1016] = 391, -- Tazavesh Streets (Mythic Keystone)
    [1017] = 392, -- Tazavesh Gambit (Mythic Keystone)
    [1160] = 402, -- Algeth'ar Academy (Mythic Keystone)
    [1164] = 405, -- Brackenhide Hollow (Mythic Keystone)
    [1168] = 406, -- Halls of Infusion (Mythic Keystone)
    [1172] = 404, -- Neltharus (Mythic Keystone)
    [1176] = 399, -- Ruby Life Pools (Mythic Keystone)
    [1180] = 401, -- The Azure Vault (Mythic Keystone)
    [1184] = 400, -- The Nokhud Offensive (Mythic Keystone)
    [1188] = 403, -- Uldaman: Legacy of Tyr (Mythic Keystone)
    [1192] =   2, -- Temple of the Jade Serpent (Mythic Keystone)
    [1193] = 165, -- Shadowmoon Burial Grounds (Mythic Keystone)
    [1195] = 438, -- The Vortex Pinnacle (Mythic Keystone)
    [1247] = 463, -- Galakrond's Fall - Dawn of the Infinite (Mythic Keystone)
    [1248] = 464, -- Murozond's Rise - Dawn of the Infinite (Mythic Keystone)
    [1274] = 456, -- Throne of the Tides (Mythic Keystone)
    [1281] = 499, -- Priory of the Sacred Flame (Mythic Keystone)
    [1282] = 504, -- Darkflame Cleft (Mythic Keystone)
    [1283] = 500, -- The Rookery (Mythic Keystone)
    [1284] = 503, -- Ara-Kara, City of Echoes (Mythic Keystone)
    [1285] = 505, -- The Dawnbreaker (Mythic Keystone)
    [1286] = 506, -- Cinderbrew Meadery (Mythic Keystone)
    [1287] = 501, -- The Stonevault (Mythic Keystone)
    [1288] = 502, -- City of Threads (Mythic Keystone)
    [1290] = 507, -- Grim Batol (Mythic Keystone)
    [1550] = 525, -- Operation: Floodgate (Mythic Keystone)
    [1694] = 542, -- Eco-Dome Al'dani (Mythic Keystone)

    [1760] = 558, -- Magisters' Terrace (Mythic Keystone)
    [1764] = 560, -- Maisara Caverns (Mythic Keystone)
    [1768] = 559, -- Nexus-Point Xenas (Mythic Keystone)
    [1770] = 556, -- Pit of Saron (Mythic Keystone)
    [1542] = 557, -- Windrunner Spire

    [1795] = 207, -- Vault of the Wardens (Mythic Keystone)

    [1933] = 588, -- Altar of Fangs (Mythic Keystone)
    [1945] = 233, -- Cathedral of Eternal Night (Mythic Keystone)

    [1949] = 584, -- The Blinding Vale (Mythic Keystone)
    [1950] = 587, -- Murder Row (Mythic Keystone)
    [1951] = 585, -- Voidscar Arena (Mythic Keystone)
    [1952] = 586, -- Den of Nalorakk (Mythic Keystone)

    

    --[1782] = 197, -- Eye of Azshara (Mythic Keystone)
    --[1783] = 200, -- Halls of Valor (Mythic Keystone)
    --[1785] = 206, -- Neltharion's Lair (Mythic Keystone)
    --[1787] = 208, -- Maw of Souls (Mythic Keystone)
    --[1788] = 198, -- Darkheart Thicket (Mythic Keystone)
    --[1789] = 210, -- Court of Stars (Mythic Keystone)
    --[1790] = 199, -- Black Rook Hold (Mythic Keystone)
    --[1791] = 209, -- The Arcway (Mythic Keystone)
    --[1793] = 234, -- Upper Karazhan (Mythic Keystone)
    --[1794] = 234, -- Lower Karazhan (Mythic Keystone)
    --[1795] = 207, -- Vault of the Wardens (Mythic Keystone)
    --[1945] = 233, -- Cathedral of Eternal Night (Mythic Keystone)

}