import re

files = ['MythicPlusLootTracker-GlobalConstants.lua', 'MythicPlusLootTracker-Constants.lua', 'MythicPlusLootTracker-Helpers.lua', 'MythicPlusLootTracker-SavedVariables.lua', 'MythicPlusLootTracker-ItemLink.lua', 'MythicPlusLootTracker-LootProcessing.lua', 'MythicPlusLootTracker-CharacterData.lua', 'MythicPlusLootTracker-EncounterJournal.lua', 'MythicPlusLootTracker-MainWindow.lua', 'MythicPlusLootTracker-LDBIcon.lua', 'MythicPlusLootTracker-EventDispatcher.lua', 'MythicPlusLootTracker-Luck.lua', 'MythicPlusLootTracker-Tracking.lua', 'MythicPlusLootTracker-AltManager.lua', 'MythicPlusLootTracker-LFG.lua', 'MythicPlusLootTracker-LootSniffer.lua', 'MythicPlusLootTracker-RollFrame.lua', 'MythicPlusLootTracker-ClassCodexImport.lua']
for f in files:
    src = open(f, encoding='utf-8', errors='replace').read()
    s = re.sub(r'--\[\[.*?\]\]', '', src, flags=re.S)
    s = re.sub(r'--[^\n]*', '', s)
    s = re.sub(r'"(?:[^"\\]|\\.)*"', '""', s)
    s = re.sub(r"'(?:[^'\\]|\\.)*'", "''", s)
    for a, b in [('function', 'end'), ('if', 'end'), ('for', 'end'), ('while', 'end'), ('do', 'end')]:
        opens = len(re.findall(r'\b' + a + r'\b', s))
        closes = len(re.findall(r'\b' + b + r'\b', s))
        print(f'{f}: {a}={opens} {b}={closes}')