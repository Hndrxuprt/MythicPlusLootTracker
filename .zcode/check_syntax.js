const luaparse = require('luaparse');
const fs = require('fs');

const files = [
  'MythicPlusLootTracker-Core.lua',
  'MythicPlusLootTracker-LootSniffer.lua',
  'MythicPlusLootTracker-RollFrame.lua',
  'MythicPlusLootTracker-AltManager.lua',
  'MythicPlusLootTracker-ClassCodexImport.lua',
  'MythicPlusLootTracker-Luck.lua',
  'MythicPlusLootTracker-Tracking.lua',
  'MythicPlusLootTracker-LFG.lua',
  'MythicPlusLootTracker-GlobalConstants.lua',
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
