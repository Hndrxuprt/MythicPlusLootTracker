const fs = require('fs');
const src = fs.readFileSync('MythicPlusLootTracker-AltManager.xml', 'utf8');
const order = [];
const re = /<Frame parentKey="ItemFrame(\d+)"[\s\S]*?<Anchors>([\s\S]*?)<\/Anchors>/g;
let m;
while ((m = re.exec(src))) {
  const n = Number(m[1]);
  const anchor = m[2].match(/relativeKey="\$parent\.([^"]+)"/);
  order.push({ n, prev: anchor ? anchor[1] : 'CharacterFrame' });
}
for (const o of order) console.log('ItemFrame' + o.n, '->', o.prev);