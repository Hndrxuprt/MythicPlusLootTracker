const luaparse = require('luaparse');
const fs = require('fs');

const files = [
  'MythicPlusLootTracker-GlobalConstants.lua',
  'MythicPlusLootTracker-Constants.lua',
  'MythicPlusLootTracker-Helpers.lua',
  'MythicPlusLootTracker-SavedVariables.lua',
  'MythicPlusLootTracker-ItemLink.lua',
  'MythicPlusLootTracker-LootProcessing.lua',
  'MythicPlusLootTracker-CharacterData.lua',
  'MythicPlusLootTracker-EncounterJournal.lua',
  'MythicPlusLootTracker-MainWindow.lua',
  'MythicPlusLootTracker-LDBIcon.lua',
  'MythicPlusLootTracker-EventDispatcher.lua',
  'MythicPlusLootTracker-Luck.lua',
  'MythicPlusLootTracker-Tracking.lua',
  'MythicPlusLootTracker-AltManager.lua',
  'MythicPlusLootTracker-LFG.lua',
  'MythicPlusLootTracker-LootSniffer.lua',
  'MythicPlusLootTracker-RollFrame.lua',
  'MythicPlusLootTracker-ClassCodexImport.lua',
];

let ok = true;
for (const f of files) {
  const src = fs.readFileSync(f, 'utf8');
  try {
    luaparse.parse(src, { luaVersion: '5.1' });
    console.log(`OK: ${f}`);
  } catch (e) {
    ok = false;
    console.log(`FAIL: ${f}: ${e.message}`);
  }
}
process.exit(ok ? 0 : 1);