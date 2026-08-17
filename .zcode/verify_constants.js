const luaparse = require('luaparse');
const fs = require('fs');

const ref = JSON.parse(fs.readFileSync('.zcode/constants_ref.json', 'utf8'));

function evalExpr(node) {
  switch (node.type) {
    case 'NumericLiteral':
      return node.value;
    case 'StringLiteral':
      return node.value;
    case 'TableConstructorExpression': {
      const t = {};
      const arr = [];
      let hasArrayKeys = false;
      for (const f of node.fields) {
        if (f.type === 'TableValue') {
          arr.push(evalExpr(f.value));
          hasArrayKeys = true;
        } else if (f.type === 'TableKey') {
          t[evalExpr(f.key)] = evalExpr(f.value);
        } else if (f.type === 'TableKeyString') {
          t[f.key.name] = evalExpr(f.value);
        }
      }
      if (hasArrayKeys) {
        for (let i = 0; i < arr.length; i++) t[i + 1] = arr[i];
      }
      return t;
    }
    case 'UnaryExpression':
      return -evalExpr(f.argument);
    default:
      throw new Error('unsupported node: ' + node.type);
  }
}

const src = fs.readFileSync('MythicPlusLootTracker-GlobalConstants.lua', 'utf8');
const ast = luaparse.parse(src, { luaVersion: '5.1' });
let dungeons = null;
for (const stmt of ast.body) {
  if (stmt.type === 'AssignmentStatement') {
    for (let i = 0; i < stmt.variables.length; i++) {
      const v = stmt.variables[i];
      if (v.type === 'MemberExpression' && v.base.type === 'Identifier' && v.base.name === 'Addon' && v.identifier.name === 'Dungeons') {
        dungeons = evalExpr(stmt.init[i]);
      }
    }
  }
}
if (!dungeons) { console.error('Dungeons table not found'); process.exit(1); }

const mapIDs = Object.keys(dungeons).map(Number).sort((a, b) => a - b);
const encounters = {};
const ejMap = {};
const activityMap = {};
for (const mapID of mapIDs) {
  const d = dungeons[mapID];
  if (d.encounters) {
    encounters[mapID] = Object.keys(d.encounters).map((k) => d.encounters[k]);
  }
  if (d.activityIDs) {
    for (const a of Object.values(d.activityIDs)) activityMap[a] = mapID;
  }
  if (d.journalInstanceID) {
    ejMap[d.journalInstanceID] = mapID;
  }
}

let ok = true;
function fail(msg) { ok = false; console.error('FAIL: ' + msg); }

const DUPLICATE_FIXES = { 353: [2654], 464: [2534] };

for (const k of Object.keys(ref.encounters)) {
  const m = Number(k);
  const expected = Object.keys(ref.encounters[m]).map((k) => ref.encounters[m][k]).filter((id) => !(DUPLICATE_FIXES[m] || []).includes(id));
  const actual = encounters[m] || [];
  if (JSON.stringify(expected) !== JSON.stringify(actual)) {
    fail(`encounters[${m}] expected=${JSON.stringify(expected)} actual=${JSON.stringify(actual)}`);
  }
}
for (const m of Object.keys(encounters)) {
  if (!ref.encounters[m]) fail(`encounters extra key ${m}`);
}

for (const k of Object.keys(ref.ejMap)) {
  const expected = ref.ejMap[k];
  const actual = ejMap[k];
  if (expected !== actual) fail(`ejMap[${k}] expected=${expected} actual=${actual}`);
}
for (const k of Object.keys(ejMap)) {
  if (ref.ejMap[k] === undefined) fail(`ejMap extra key ${k}`);
}

for (const k of Object.keys(ref.activityMap)) {
  const expected = ref.activityMap[k];
  const actual = activityMap[k];
  if (expected !== actual) fail(`activityMap[${k}] expected=${expected} actual=${actual}`);
}
for (const k of Object.keys(activityMap)) {
  if (ref.activityMap[k] === undefined) fail(`activityMap extra key ${k}`);
}

console.log('dungeons:', mapIDs.length);
console.log('encounters:', Object.keys(encounters).length, 'ejMap:', Object.keys(ejMap).length, 'activityMap:', Object.keys(activityMap).length);
console.log(ok ? 'ALL CHECKS PASSED' : 'CHECKS FAILED');
process.exit(ok ? 0 : 1);