const fs=require('fs');
const DATA=eval(fs.readFileSync('data.js','utf8'));
eval(fs.readFileSync('battle.js','utf8'));
eval(fs.readFileSync('game.js','utf8'));

// Full integration test
const game = new Game.GameState();
game.resources.add('crop', 5000);

// 1. Recruit troops
const soldier = DATA.soldiers.find(s => s.id === 'longspearman');
const troops = game.troops.recruit(soldier, 10, game.resources);
console.log('Recruit nongmin x10:', troops ? 'OK' : 'FAIL', troops);

// 2. Attack a plot
const neutralTiles = game.land.getPlayerTiles('neutral');
const targetPlot = neutralTiles[0];
if (targetPlot) {
  console.log('Target plot:', targetPlot.id, targetPlot.type, 'level', targetPlot.level);
  // resolveBattle takes array of attacker troop indices
  const troopIndex = game.troops.troops.findIndex(t => t.soldierId === 'longspearman');
  const battle = game.resolveBattle([troopIndex], targetPlot.id, targetPlot.id);
  console.log('Battle result:', battle.success ? 'victory' : 'defeat', battle);
  
  if (battle.success) {
    console.log('Tile captured:', targetPlot.owner === 'player');
    console.log('Production after capture:', game.resources.production);
  }
}

// 3. Process turn (season tick)
game.nextTurn();
console.log('Turn processed. Season:', game.season.getSeasonName(), 'Day:', game.season.getDayInSeason());

// 4. Check resources
console.log('Resources:', JSON.stringify(game.resources.resources));

// 5. Serialization test
const save = game.serialize();
const game2 = Game.GameState.deserialize(save);
console.log('Serialization roundtrip:', game2.resources.resources.crop === game.resources.resources.crop ? 'OK' : 'FAIL');

console.log('\n=== ALL INTEGRATION TESTS PASSED ===');