// Smoke test for battle engine
const fs = require('fs');
const DATA = require('./data.js');
eval(fs.readFileSync('battle.js', 'utf8'));

// Build a simple player team: 20 Longspearman Lv1 + Chen Dao hero
const soldier = DATA.soldiers.find(s=>s.id==="longspearman");
const hero = DATA.heroes.find(h=>h.id==="chendaoshuzhi");

const playerTeam = [{
  teamId: 1,
  units: [
    new Battle.Unit(soldier, "player", 1, "chendaoshuzhi", [], [], 1, 20)
  ]
}];

// Enemy: plot p1 garrison (wolf, wolf, leopard)
const enemyUnits = DATA.garrisons.p1.map(id=>{
  const b = DATA.bestiary.find(x=>x.id===id);
  return new Battle.Unit(b, "enemy", 1, null, [], [], b.level, 1);
});
const enemyTeam = [{teamId: 1, units: enemyUnits}];

console.log("=== Starting Battle ===");
console.log("Player:", playerTeam[0].units[0].name, "x", playerTeam[0].units[0].count, "HP:", playerTeam[0].units[0].hp, "ATK:", playerTeam[0].units[0].atk);
console.log("Enemy:", enemyUnits.map(u=>u.name+"x"+u.count).join(", "));

const result = Battle.run(playerTeam, enemyTeam, "p1", 0);
console.log("\n=== RESULT ===");
console.log("Victory:", result.victory);
console.log("Turns:", result.turn);
console.log("Rewards:", JSON.stringify(result.rewards));
console.log("\n=== LOG (last 30) ===");
result.log.slice(-30).forEach(l=>console.log(l));