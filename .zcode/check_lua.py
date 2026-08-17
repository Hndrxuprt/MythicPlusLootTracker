import re

files = ['MythicPlusLootTracker-Core.lua', 'MythicPlusLootTracker-LootSniffer.lua', 'MythicPlusLootTracker-RollFrame.lua', 'MythicPlusLootTracker-AltManager.lua', 'MythicPlusLootTracker-ClassCodexImport.lua', 'MythicPlusLootTracker-Luck.lua', 'MythicPlusLootTracker-Tracking.lua', 'MythicPlusLootTracker-LFG.lua']
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
