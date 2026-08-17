const luaparse = require('luaparse');
const fs = require('fs');

function evalExpr(node) {
  switch (node.type) {
    case 'NumericLiteral':
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
      if (f.operator === '-') return -evalExpr(f.argument);
      return evalExpr(f.argument);
    default:
      throw new Error('unsupported node: ' + node.type);
  }
}

function extract(file) {
  const src = fs.readFileSync(file, 'utf8');
  const ast = luaparse.parse(src, { luaVersion: '5.1' });
  const out = { encounters: {}, ejMap: {}, activityMap: {} };
  for (const stmt of ast.body) {
    if (stmt.type !== 'AssignmentStatement') continue;
    for (let i = 0; i < stmt.variables.length; i++) {
      const v = stmt.variables[i];
      if (v.type !== 'MemberExpression' || v.base.type !== 'Identifier' || v.base.name !== 'Addon') continue;
      const name = v.identifier.name;
      const value = evalExpr(stmt.init[i]);
      if (name === 'currentSeasonEncounters') {
        for (const k of Object.keys(value)) out.encounters[Number(k)] = value[k];
      } else if (name === 'EJInstanceIDToMapID') {
        for (const k of Object.keys(value)) out.ejMap[Number(k)] = value[k];
      } else if (name === 'ActivityID') {
        for (const k of Object.keys(value)) out.activityMap[Number(k)] = value[k];
      }
    }
  }
  return out;
}

const target = process.argv[2] || 'MythicPlusLootTracker-GlobalConstants.lua';
const out = extract(target);
if (process.argv[3] === 'dump') {
  fs.writeFileSync('.zcode/constants_ref.json', JSON.stringify(out, null, 0));
  console.log('dumped reference');
} else {
  console.log('encounters:', Object.keys(out.encounters).length);
  console.log('ejMap:', Object.keys(out.ejMap).length, 'ejMap[1194]=', out.ejMap[1194]);
  console.log('activityMap:', Object.keys(out.activityMap).length);
}