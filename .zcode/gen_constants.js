const fs = require('fs');

const ref = JSON.parse(fs.readFileSync('.zcode/constants_ref.json', 'utf8'));

const NAMES = {
  2: 'Temple of the Jade Serpent', 161: 'Skyreach', 163: 'Bloodmaul Slag Mines',
  164: 'Auchindoun', 165: 'Shadowmoon Burial Grounds', 166: 'Grimrail Depot',
  167: 'Upper Blackrock Spire', 168: 'The Everbloom', 169: 'Iron Docks',
  197: 'Eye of Azshara', 198: 'Darkheart Thicket', 199: 'Black Rook Hold',
  200: 'Halls of Valor', 206: "Neltharion's Lair", 207: 'Vault of the Wardens',
  208: 'Maw of Souls', 209: 'The Arcway', 210: 'Court of Stars',
  227: 'Lower Karazhan', 233: 'Cathedral of Eternal Night', 234: 'Upper Karazhan',
  239: 'Seat of the Triumvirate', 244: "Atal'Dazar", 245: 'Freehold',
  246: 'Tol Dagor', 247: 'The MOTHERLODE!!', 248: 'Waycrest Manor',
  249: "Kings' Rest", 250: 'Temple of Sethraliss', 251: 'The Underrot',
  252: 'Shrine of the Storm', 353: 'Siege of Boralus', 369: 'Mechagon Junkyard',
  370: 'Mechagon Workshop', 375: 'Mists of Tirna Scithe', 376: 'The Necrotic Wake',
  377: 'De Other Side', 378: 'Halls of Atonement', 379: 'Plaguefall',
  380: 'Sanguine Depths', 381: 'Spires of Ascension', 382: 'Theater of Pain',
  391: 'Tazavesh: Streets of Wonder', 392: "Tazavesh: So'leah's Gambit",
  399: 'Ruby Life Pools', 400: 'The Nokhud Offensive', 401: 'The Azure Vault',
  402: "Algeth'ar Academy", 403: 'Uldaman: Legacy of Tyr', 404: 'Neltharus',
  405: 'Brackenhide Hollow', 406: 'Halls of Infusion', 438: 'The Vortex Pinnacle',
  456: 'Throne of the Tides', 463: 'Dawn of the Infinite: Galakrond\'s Fall',
  464: 'Dawn of the Infinite: Murozond\'s Rise', 499: 'Priory of the Sacred Flame',
  500: 'The Rookery', 501: 'The Stonevault', 502: 'City of Threads',
  503: 'Ara-Kara, City of Echoes', 504: 'Darkflame Cleft', 505: 'The Dawnbreaker',
  506: 'Cinderbrew Meadery', 507: 'Grim Batol', 525: 'Operation: Floodgate',
  542: "Eco-Dome Al'dani", 556: 'Pit of Saron', 557: 'Windrunner Spire',
  558: "Magisters' Terrace", 559: 'Nexus-Point Xenas', 560: 'Maisara Caverns',
  584: 'The Blinding Vale', 585: 'Voidscar Arena', 586: 'Den of Nalorakk',
  587: 'Murder Row', 588: 'Altar of Fangs',
};

const BOSS_NAMES = {
  608: 'Forgemaster Garfrost', 609: 'Ick and Krick', 610: 'Scourgelord Tyrannus',
  114: 'Grand Vizier Ertan', 115: 'Altairus', 116: 'Asaad, Caliph of Zephyrs',
  101: "Lady Naz'jar", 102: 'Commander Ulthok, the Festering Prince', 103: "Mindbender Ghur'sha", 104: 'Ozumat',
  2617: 'General Umbriss', 2618: 'Drahga Shadowburner', 2619: 'Erudax, the Duke of Below', 2627: 'Forgemaster Throngus',
  672: 'Wise Mari', 664: 'Lorewalker Stonestep', 658: 'Liu Flameheart', 335: 'Sha of Doubt',
  1139: 'Sadana Bloodfury', 1168: 'Nhallish', 1140: 'Bonemaw', 1160: "Ner'zhul",
  1138: 'Rocketspark and Borka', 1163: 'Nitrogg Thundertower', 1133: 'Skylord Tovra',
  1214: 'Witherbark', 1207: 'Ancient Protectors', 1208: 'Archmage Sol', 1209: "Xeri'tac", 1210: 'Yalnu',
  1235: "Fleshrender Nok'gar", 1236: 'Grimrail Enforcers', 1237: 'Oshir', 1238: 'Skulloc',
  965: 'Ranjit', 966: 'Araknath', 967: 'Rukhran', 968: 'High Sage Viryx',
  1480: 'Warlord Parjesh', 1490: 'Lady Hatecoil', 1491: 'King Deepbeard', 1479: 'Serpentrix', 1492: 'Wrath of Azshara',
  1654: 'Archdruid Glaidalis', 1655: 'Oakheart', 1656: 'Dresaron', 1657: 'Shade of Xavius',
  1518: 'The Amalgam of Souls', 1653: 'Illysanna Ravencrest', 1664: 'Smashspite the Hateful', 1672: "Lord Kur'talos Ravencrest",
  1662: 'Rokmora', 1665: 'Ularogg Cragshaper', 1673: 'Naraxas', 1687: 'Dargrul the Underking',
  1467: 'Tirathon Saltheril', 1695: 'Inquisitor Tormentorum', 1468: "Ash'golm", 1469: 'Glazer', 1470: 'Cordana Felsong',
  1718: 'Patrol Captain Gerdo', 1719: 'Talixae Flamewreath', 1720: 'Advisor Melandrus',
  1820: 'Opera Hall: Wikket', 1826: 'Opera Hall: Westfall Story', 1827: 'Opera Hall: Beautiful Beast', 1825: 'Maiden of Virtue', 1835: 'Attumen the Huntsman', 1837: 'Moroes',
  1836: 'The Curator', 1817: 'Shade of Medivh', 1818: 'Mana Devourer', 1838: "Viz'aduum the Watcher",
  1979: 'Zuraal the Ascended', 1980: 'Saprish', 1981: 'Viceroy Nezhar', 1982: "L'ura",
  2082: "Priestess Alun'za", 2036: "Vol'kaal", 2083: 'Rezan', 2030: 'Yazma',
  2093: "Council o' Captains", 2094: 'Ring of Booty', 2095: 'Harlan Sweete', 2102: "Skycap'n Kragg",
  2109: 'Coin-Operated Crowd Pummeler', 2114: 'Azerokk', 2115: 'Rixxa Fluxflame', 2116: 'Mogul Razdunk',
  2125: 'Heartsbane Triad', 2126: 'Soulbound Goliath', 2127: 'Raal the Gluttonous', 2128: 'Lord and Lady Waycrest', 2129: 'Gorak Tul',
  2165: 'The Golden Serpent', 2171: 'Mchimba the Embalmer', 2170: 'The Council of Tribes', 2172: 'Dazar, The First King',
  2142: 'Adderis and Aspix', 2143: 'Merektha', 2144: 'Galvazzt', 2145: 'Avatar of Sethraliss',
  2130: 'Sporecaller Zancha', 2131: 'Cragmaw the Infested', 2157: 'Elder Leaxa', 2158: 'Unbound Abomination',
  2132: 'Chopper Redhook', 2133: 'Sergeant Bainbridge', 2134: 'Hadal Darkfathom', 2140: "Viq'Goth", 2173: 'Dread Captain Lockwood', 2654: 'Chopper Redhook',
  2357: 'King Gobbamak', 2358: 'Gunker', 2360: 'Trixie & Naeno', 2355: 'HK-8 Aerial Oppression Unit',
  2336: 'Tussle Tonks', 2339: 'K.U.-J.0.', 2348: "Machinist's Garden", 2331: 'King Mechagon',
  2400: 'Ingra Maloch', 2402: 'Mistcaller', 2405: "Tred'ova",
  2391: 'Amarth, The Harvester', 2392: 'Surgeon Stitchflesh', 2395: 'Blightbone', 2396: 'Nalthor the Rimebinder',
  2406: 'Halkias, the Sin-Stained Goliath', 2387: 'Echelon', 2411: 'High Adjudicator Aleez', 2413: 'Lord Chamberlain',
  2389: "Kul'tharok", 2390: 'Xav the Unfallen', 2397: 'An Affront of Challengers', 2401: 'Gorechop', 2417: 'Mordretha, the Endless Empress',
  2437: "Zo'phex the Sentinel", 2454: 'The Grand Menagerie', 2436: 'Mailroom Mayhem', 2452: "Myza's Oasis", 2451: "So'azmi",
  2448: 'Hylbrande', 2449: "Timecap'n Hooktail", 2455: "So'leah",
  2488: 'Melidrussa Chillworn', 2485: 'Kokia Blazehoof', 2503: 'Kyrakka and Erkhart Stormvein',
  2498: 'Granyth', 2497: 'The Raging Tempest', 2478: 'Teera and Maruuk', 2477: 'Balakar Khan',
  2492: 'Leymor', 2505: 'Azureblade', 2483: 'Telash Greywing', 2508: 'Umbrelskul',
  2509: 'Vexamus', 2512: 'Overgrown Ancient', 2495: 'Crawth', 2514: 'Echo of Doragosa',
  2475: 'The Lost Dwarves', 2476: 'Emberon', 2479: 'Chrono-Lord Deios', 2484: 'Sentinel Talondras', 2487: 'Bromach',
  2489: 'Forgemaster Gorek', 2490: 'Chargath, Bane of Scales', 2494: 'Magmatusk', 2501: 'Warlord Sargha',
  2471: "Hackclaw's War-Band", 2472: 'Gutshot', 2473: 'Treemouth', 2474: 'Decatriarch Wratheye',
  2504: 'Watcher Irideus', 2507: 'Gulping Goliath', 2510: 'Khajin the Unyielding', 2511: 'Primal Tsunami',
  2521: 'Chronikar', 2528: 'Manifested Timeways', 2535: 'Blight of Galakrond', 2537: 'Iridikron the Stonescaled',
  2526: 'Tyr, the Infinite Keeper', 2536: 'Morchie', 2533: 'Time-Lost Battlefield', 2534: 'Time-Lost Battlefield', 2538: 'Chrono-Lord Deios',
  2583: 'Avanoxx', 2584: "Anub'zekt", 2585: "Ki'katal the Harvester",
  2586: 'Brew Master Aldryr', 2587: "I'pa", 2588: 'Benk Buzzbee', 2589: 'Goldie Baronbottom',
  2594: "Orator Krix'vizk", 2595: 'Fangs of the Queen', 2596: 'Izo, the Grand Splicer', 2600: 'The Coaglamation',
  2559: 'Blazikon', 2560: 'The Candle King', 2561: 'The Darkness', 2569: "Ol' Waxbeard",
  2570: 'Baron Braunpyke', 2571: 'Captain Dailcry', 2573: 'Prioress Murrpray',
  2580: 'Speaker Shadowcrown', 2581: "Anub'ikkaj", 2593: "Rasha'nan",
  2566: 'Kyrioss', 2567: 'Stormguard Gorren', 2568: 'Voidstone Monstrosity',
  2572: 'E.D.N.A.', 2579: 'Skarmorak', 2582: 'Void Speaker Eirich', 2590: 'Master Machinists',
  2648: 'Big M.O.M.M.A.', 2649: 'Demolition Duo', 2650: 'Swampface', 2651: 'Geezle Gigazap',
  2675: 'Azhiccar', 2676: "Taah'bat and A'wazj", 2677: 'Soul-Scribe',
  2659: 'Arcanotron Custos', 2662: 'Degentrius', 2660: 'Gemellus', 2661: 'Seranel Sunlash',
  2810: "Muro'jin and Nekraxx", 2812: "Rak'tul, Vessel of Souls", 2811: 'Vordaza',
  2813: 'Chief Corewright Kasreth', 2814: 'Corewarden Nysarra', 2815: 'Lothraxion',
  2657: 'Commander Kroluk', 2656: 'Derelict Duo', 2655: 'Emberdawn', 2658: 'The Restless Heart',
  2769: 'Lightblossom Trinity', 2770: 'Ikuzz the Light Hunter', 2771: 'Lightwarden Ruia', 2772: 'Ziekket',
  2791: "Taz'Rah", 2792: 'Atroxus', 2793: 'Charonus',
  2776: 'The Hoardmonger', 2777: 'Sentinel of Winter', 2778: 'Nalorakk',
  2679: 'Kystia Manaheart', 2680: 'Zaen Bladesorrow', 2681: 'Xathuux the Annihilator', 2682: 'Lithiel Cinderfury',
  2878: "Rav'i", 2879: 'The Writhing Coil', 2880: "Zul'jan",
};

const DUPLICATE_FIXES = { 353: [2654], 464: [2534] };

const ejByMap = {};
for (const k of Object.keys(ref.ejMap)) ejByMap[ref.ejMap[k]] = Number(k);
const EJ_OVERRIDES = { 391: 1194 };

const order = [];
for (const k of Object.keys(ref.encounters)) order.push(Number(k));
for (const k of Object.keys(ref.activityMap)) {
  const m = ref.activityMap[k];
  if (order.indexOf(m) === -1) order.push(m);
}
order.sort((a, b) => a - b);

let out = '';
out += 'local AddonName, Addon = ...\n\n';
out += '--C_MythicPlus.GetCurrentSeason()\n';
out += 'Addon.currentSeason = 18\n\n';
out += '-- Dungeon data keyed by mapID (MapChallengeMode).\n';
out += '-- name = dungeon name, journalInstanceID = EJ_GetInstanceByIndex, activityIDs = LFG activity IDs, encounters = boss IDs.\n';
out += '-- IDs from https://wago.tools/db2/JournalEncounter and https://wago.tools/db2/MapChallengeMode\n';
out += '-- Activity IDs from https://github.com/0xbs/premade-groups-filter-helper\n';
out += 'Addon.Dungeons = {\n';
for (const m of order) {
  const name = NAMES[m];
  if (!name) throw new Error('missing name for mapID ' + m);
  const ej = EJ_OVERRIDES[m] || ejByMap[m];
  const acts = [];
  for (const k of Object.keys(ref.activityMap)) {
    if (Number(ref.activityMap[k]) === m) acts.push(Number(k));
  }
  acts.sort((a, b) => a - b);
  const enc = (ref.encounters[m] ? Object.keys(ref.encounters[m]).map((k) => ref.encounters[m][k]) : [])
    .filter((id) => !(DUPLICATE_FIXES[m] || []).includes(id));
  let line = '    [' + m + '] = { name = "' + name.replace(/"/g, '\\"') + '"';
  if (ej) line += ', journalInstanceID = ' + ej;
  if (acts.length) line += ', activityIDs = { ' + acts.join(', ') + ' }';
  if (enc.length) {
    line += ', encounters = {\n';
    for (const e of enc) {
      line += '        ' + e + ',' + (BOSS_NAMES[e] ? ' --' + BOSS_NAMES[e] : '') + '\n';
    }
    line += '    } }';
  } else {
    line += ' }';
  }
  out += line + ',\n';
}
out += '}\n\n';
out += 'Addon.currentSeasonEncounters = {}\n';
out += 'Addon.EJInstanceIDToMapID = {}\n';
out += 'Addon.ActivityID = {}\n\n';
out += 'local mapIDs = {}\n';
out += 'for mapID in pairs(Addon.Dungeons) do\n';
out += '    tinsert(mapIDs, mapID)\n';
out += 'end\n';
out += 'table.sort(mapIDs)\n';
out += 'for _, mapID in ipairs(mapIDs) do\n';
out += '    local dungeon = Addon.Dungeons[mapID]\n';
out += '    Addon.currentSeasonEncounters[mapID] = dungeon.encounters\n';
out += '    if dungeon.activityIDs then\n';
out += '        for _, activityID in ipairs(dungeon.activityIDs) do\n';
out += '            Addon.ActivityID[activityID] = mapID\n';
out += '        end\n';
out += '    end\n';
out += '    if dungeon.journalInstanceID then\n';
out += '        Addon.EJInstanceIDToMapID[dungeon.journalInstanceID] = mapID\n';
out += '    end\n';
out += 'end\n\n';
out += '-- Populated at runtime by MythicPlusLootTracker-ClassCodexImport.lua (EJ_GetInstanceByIndex)\n';
out += 'Addon.MapIDToEJInstanceID = {}\n';
out += 'Addon.RaidEJInstanceID = {}\n';

fs.writeFileSync('MythicPlusLootTracker-GlobalConstants.lua', out);
console.log('wrote ' + order.length + ' dungeons');

const allBosses = new Set();
for (const md of Object.keys(ref.encounters)) {
  for (const k of Object.keys(ref.encounters[md])) allBosses.add(Number(ref.encounters[md][k]));
}
const missing = [...allBosses].filter((id) => !BOSS_NAMES[id]).sort((a, b) => a - b);
console.log('missing boss names: ' + missing.join(', '));