const DATA = require('./data.js');
console.log('DATA loaded, soldiers:', DATA.soldiers.length);
console.log('heroes:', DATA.heroes.length);
const soldier = DATA.soldiers.find(s=>s.id==="longspearman");
console.log('soldier:', soldier.name);