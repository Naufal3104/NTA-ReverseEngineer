// -*- coding: utf-8 -*-
/**
 * Core Game Loop for NTA Demo
 * Manages game state: resources, buildings, troops, land, seasons, unions
 * Integrates with Battle engine for combat resolution
 */
(function(global){
"use strict";

// Lazy DATA accessor (same pattern as battle.js)
function getDATA(){
  return (typeof global.DATA !== "undefined") ? global.DATA : 
         (typeof module !== "undefined" && module.exports && require("./data.js")) || {};
}

// ============================================================
// UTILITIES
// ============================================================
function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
function sum(arr, fn){ return arr.reduce((a,b)=>a+(fn?fn(b):b),0); }
function deepClone(obj){ return JSON.parse(JSON.stringify(obj)); }

// ============================================================
// GAME CONSTANTS (from data.js configs)
// ============================================================
const SEASONS = ["spring", "summer", "autumn", "winter"];
const SEASON_DAYS = 3; // real-time days per season (demo: turns)
const MAX_SEASONS = 4;
const MAX_UNION_MEMBERS = 50;
const REMAINS_TYPES = ["altar", "tower", "shrine", "ruins"]; // landmark types
const VICTORY_CONDITIONS = {
  remains_l20: "Control 1 remains at Lv20",
  remains_3x12: "Control 3 remains at Lv12",
  remains_all: "Control all 4 remains",
  remains_winter: "Most remains + highest level at Winter start"
};

// ============================================================
// RESOURCE SYSTEM
// ============================================================
class ResourceManager {
  constructor(){
    this.resources = {crop: 0, wood: 0, stone: 0};
    this.production = {crop: 0, wood: 0, stone: 0}; // per tick
    this.storage = {crop: 10000, wood: 10000, stone: 10000};
  }

  add(type, amount){
    const val = Math.floor(amount);
    this.resources[type] = Math.min(this.storage[type], this.resources[type] + val);
  }

  spend(type, amount){
    if(this.resources[type] < amount) return false;
    this.resources[type] -= amount;
    return true;
  }

  canAfford(cost){
    return Object.entries(cost).every(([k,v]) => this.resources[k] >= v);
  }

  applyProduction(){
    for(const k of Object.keys(this.resources)){
      this.resources[k] = Math.min(this.storage[k], this.resources[k] + this.production[k]);
    }
  }

  setProduction(prod){ this.production = {...prod}; }
  getState(){ return {...this.resources, production: {...this.production}, storage: {...this.storage} }; }
}

// ============================================================
// BUILDING SYSTEM
// ============================================================
class Building {
  constructor(data, level=1){
    this.id = data.id;
    this.name = data.name;
    this.type = data.type; // farm, lumber, quarry, barracks, wall, remains, etc.
    this.level = level;
    this.maxLevel = data.maxLevel || 10;
    this.cost = data.cost || {}; // base cost per level
    this.production = data.production || {}; // resource production per level
    this.effects = data.effects || {}; // bonuses (troop cap, defense, etc.)
    this.buildTime = data.buildTime || 0; // seconds (demo: instant)
    this.isConstructing = false;
    this.constructEndTurn = 0;
  }

  getCurrentCost(){
    const mult = Math.pow(1.5, this.level - 1);
    const cost = {};
    for(const [k,v] of Object.entries(this.cost)){
      cost[k] = Math.floor(v * mult);
    }
    return cost;
  }

  getCurrentProduction(){
    const prod = {};
    for(const [k,v] of Object.entries(this.production)){
      prod[k] = v * this.level;
    }
    return prod;
  }

  canUpgrade(){ return this.level < this.maxLevel; }

  upgrade(){
    if(!this.canUpgrade()) return false;
    this.level++;
    return true;
  }

  getEffects(){
    const eff = {};
    for(const [k,v] of Object.entries(this.effects)){
      eff[k] = v * this.level; // linear scaling
    }
    return eff;
  }
}

class BuildingManager {
  constructor(){
    this.buildings = new Map(); // plotId -> Building
    this.plots = new Map(); // plotId -> {x, y, type, owner, building}
  }

  addPlot(plotId, data){
    this.plots.set(plotId, {...data, building: null, owner: "neutral"});
  }

  build(plotId, buildingData, resources){
    const cost = buildingData.cost || {};
    if(!resources.canAfford(cost)) return {success: false, reason: "Insufficient resources"};
    
    resources.spend("crop", cost.crop||0);
    resources.spend("wood", cost.wood||0);
    resources.spend("stone", cost.stone||0);
    
    const building = new Building(buildingData, 1);
    this.buildings.set(plotId, building);
    const plot = this.plots.get(plotId);
    if(plot) plot.building = building;
    return {success: true, building};
  }

  upgrade(plotId, resources){
    const building = this.buildings.get(plotId);
    if(!building || !building.canUpgrade()) return {success: false, reason: "Cannot upgrade"};
    
    const cost = building.getCurrentCost();
    if(!resources.canAfford(cost)) return {success: false, reason: "Insufficient resources"};
    
    resources.spend("crop", cost.crop||0);
    resources.spend("wood", cost.wood||0);
    resources.spend("stone", cost.stone||0);
    
    building.upgrade();
    return {success: true, building};
  }

  getBuilding(plotId){ return this.buildings.get(plotId); }
  getAllBuildings(){ return Array.from(this.buildings.values()); }
  getBuildingsByType(type){ return this.getAllBuildings().filter(b=>b.type===type); }
  
  calculateTotalProduction(){
    const total = {crop: 0, wood: 0, stone: 0};
    for(const b of this.buildings.values()){
      const prod = b.getCurrentProduction();
      total.crop += prod.crop||0;
      total.wood += prod.wood||0;
      total.stone += prod.stone||0;
    }
    return total;
  }

  getRemains(){
    return this.getBuildingsByType("remains");
  }
}

// ============================================================
// TROOP SYSTEM
// ============================================================
class TroopManager {
  constructor(){
    this.troops = []; // {soldierId, level, count, heroId, equipIds, expertiseIds, location}
    this.recruitQueue = []; // {soldierId, count, endTurn}
  }

  recruit(soldierData, count, resources, heroId=null, equipIds=[], expertiseIds=[]){
      // soldierData.cost is a number (crop cost) in NTA data
      const cropCost = typeof soldierData.cost === 'number' ? soldierData.cost : (soldierData.cost?.crop || 10);
      const totalCost = {crop: cropCost * count, wood: 0, stone: 0};
    
      if(!resources.canAfford(totalCost)) return {success: false, reason: "Insufficient resources"};
    
      resources.spend("crop", totalCost.crop);
    
    const troop = {
      soldierId: soldierData.id,
      name: soldierData.name,
      level: 1,
      count: count,
      heroId: heroId,
      equipIds: equipIds,
      expertiseIds: expertiseIds,
      location: "city", // city, marching, garrison, remains
      hp: 0, atk: 0 // will be computed by battle engine
    };
    this.troops.push(troop);
    return {success: true, troop};
  }

  upgradeTroop(index, resources){
    const troop = this.troops[index];
    if(!troop) return {success: false};
    // Simplified: cost to level up
    const cost = {crop: 50 * troop.level, wood: 20 * troop.level, stone: 10 * troop.level};
    if(!resources.canAfford(cost)) return {success: false, reason: "Insufficient resources"};
    resources.spend("crop", cost.crop);
    resources.spend("wood", cost.wood);
    resources.spend("stone", cost.stone);
    troop.level = Math.min(6, troop.level + 1);
    return {success: true, troop};
  }

  assignHero(troopIndex, heroId){
    const troop = this.troops[troopIndex];
    if(troop){ troop.heroId = heroId; return true; }
    return false;
  }

  equipItems(troopIndex, equipIds){
    const troop = this.troops[troopIndex];
    if(troop){ troop.equipIds = equipIds; return true; }
    return false;
  }

  setExpertise(troopIndex, expertiseIds){
    const troop = this.troops[troopIndex];
    if(troop){ troop.expertiseIds = expertiseIds; return true; }
    return false;
  }

  moveTroop(troopIndex, location){
    const troop = this.troops[troopIndex];
    if(troop){ troop.location = location; return true; }
    return false;
  }

  getTroops(location=null){
    return location ? this.troops.filter(t=>t.location===location) : [...this.troops];
  }

  getTotalTroopCount(){
    return sum(this.troops, t=>t.count);
  }

  removeTroop(index){
    this.troops.splice(index, 1);
  }
}

// ============================================================
// LAND / MAP SYSTEM
// ============================================================
class LandManager {
  constructor(onCaptureCallback=null){
    this.tiles = new Map(); // tileId -> {x, y, type, level, owner, garrison, remains}
    this.remains = new Map(); // remainsId -> {type, level, owner, bonuses}
    this.onCaptureCallback = onCaptureCallback;
  }

  addTile(tileId, data){
    this.tiles.set(tileId, {
      id: tileId,
      x: data.x, y: data.y,
      type: data.type || "plain", // plain, forest, mountain, river, remains
      level: data.level || 1,
      owner: data.owner || "neutral",
      garrison: data.garrison || [],
      remains: data.remains || null
    });
  }

  addRemains(remainsId, data){
    this.remains.set(remainsId, {
      id: remainsId,
      type: data.type, // altar, tower, shrine, ruins
      level: data.level || 1,
      owner: data.owner || "neutral",
      bonuses: data.bonuses || {},
      connectedTiles: data.connectedTiles || []
    });
  }

  captureTile(tileId, newOwner, battleResult){
    const tile = this.tiles.get(tileId);
    if(!tile) return false;
    tile.owner = newOwner;
    if(battleResult && battleResult.attackerSurvivors){
      tile.garrison = battleResult.attackerSurvivors.map(u=>({soldierId: u.base.id, count: u.count, hp: u.hp}));
    }
    // If tile has remains, capture it too
    if(tile.remains){
      this.captureRemains(tile.remains, newOwner);
    }
      // Callback to update production
      if(this.onCaptureCallback){
        this.onCaptureCallback(newOwner);
      }
      return true;
    }

  captureRemains(remainsId, newOwner){
    const rem = this.remains.get(remainsId);
    if(rem){
      rem.owner = newOwner;
      return true;
    }
    return false;
  }

  getPlayerTiles(owner){
    return Array.from(this.tiles.values()).filter(t=>t.owner===owner);
  }

  getPlayerRemains(owner){
    return Array.from(this.remains.values()).filter(r=>r.owner===owner);
  }

  checkVictory(owner){
    const myRemains = this.getPlayerRemains(owner);
    if(myRemains.length === 0) return false;
    
    // Condition 1: 1 remains at Lv20
    if(myRemains.some(r=>r.level >= 20)) return {type: "remains_l20", remains: myRemains};
    
    // Condition 2: 3 remains at Lv12
    if(myRemains.filter(r=>r.level >= 12).length >= 3) return {type: "remains_3x12", remains: myRemains};
    
    // Condition 3: All 4 remains
    if(myRemains.length >= 4) return {type: "remains_all", remains: myRemains};
    
    return false;
  }
}

// ============================================================
// SEASON SYSTEM
// ============================================================
class SeasonManager {
  constructor(){
    this.currentSeason = 0; // 0=spring, 1=summer, 2=autumn, 3=winter
    this.dayInSeason = 1; // 1-3
    this.totalDays = 1;
    this.isWinter = false;
  }

  getSeasonName(){ return SEASONS[this.currentSeason]; }
  getSeasonIndex(){ return this.currentSeason; }
  getDayInSeason(){ return this.dayInSeason; }
  getTotalDays(){ return this.totalDays; }

  nextDay(){
    this.totalDays++;
    this.dayInSeason++;
    if(this.dayInSeason > SEASON_DAYS){
      this.dayInSeason = 1;
      this.currentSeason = (this.currentSeason + 1) % MAX_SEASONS;
      this.isWinter = (this.currentSeason === 3);
      return {seasonChanged: true, newSeason: this.getSeasonName(), isWinter: this.isWinter};
    }
    return {seasonChanged: false, season: this.getSeasonName()};
  }

  getSeasonBonus(){
    // Spring: +crop, Summer: +troop speed, Autumn: +wood/stone, Winter: +defense
    const bonuses = {
      spring: {cropPct: 20},
      summer: {marchSpeedPct: 15},
      autumn: {woodPct: 15, stonePct: 15},
      winter: {defensePct: 25}
    };
    return bonuses[this.getSeasonName()] || {};
  }
}

// ============================================================
// UNION SYSTEM
// ============================================================
class UnionManager {
  constructor(){
    this.unions = new Map(); // unionId -> {name, leader, members, points, remains}
    this.playerUnion = null; // player's unionId
  }

  createUnion(unionId, name, leaderId){
    this.unions.set(unionId, {
      id: unionId,
      name: name,
      leader: leaderId,
      members: [leaderId],
      points: 0,
      remains: [],
      createdDay: 1
    });
    return this.unions.get(unionId);
  }

  joinUnion(unionId, playerId){
    const union = this.unions.get(unionId);
    if(!union || union.members.length >= MAX_UNION_MEMBERS) return false;
    if(!union.members.includes(playerId)) union.members.push(playerId);
    return true;
  }

  leaveUnion(unionId, playerId){
    const union = this.unions.get(unionId);
    if(!union) return false;
    union.members = union.members.filter(m=>m!==playerId);
    if(union.leader === playerId && union.members.length > 0){
      union.leader = union.members[0];
    }
    return true;
  }

  addRemains(unionId, remainsId){
    const union = this.unions.get(unionId);
    if(union && !union.remains.includes(remainsId)){
      union.remains.push(remainsId);
    }
  }

  getUnion(unionId){ return this.unions.get(unionId); }
  getPlayerUnion(){ return this.playerUnion ? this.unions.get(this.playerUnion) : null; }
  setPlayerUnion(unionId){ this.playerUnion = unionId; }
}

// ============================================================
// MAIN GAME STATE
// ============================================================
class GameState {
  constructor(){
    this.resources = new ResourceManager();
    this.buildings = new BuildingManager();
    this.troops = new TroopManager();
    this.land = new LandManager((owner) => this.updateProductionFromPlots());
    this.season = new SeasonManager();
    this.unions = new UnionManager();
    this.turn = 1;
    this.playerId = "player1";
    this.victory = null;
    this.defeated = false;
    this.log = [];
    
    // Initialize from data.js
    this.initFromData();
  }

  initFromData(){
    const D = getDATA();
    // Initialize map plots from DATA.map.plots
      // In NTA, plots ARE the buildings (resource nodes: crop/wood/stone)
      if(D.map && D.map.plots){
        for(const plot of D.map.plots){
          // Add as land tile
          this.land.addTile(plot.id, {
            x: plot.col || 0, 
            y: plot.row || 0, 
            type: plot.res || "plain", // crop, wood, stone
            level: plot.level || 1,
            owner: "neutral",
            garrison: []
          });
          // Also register as a "building" (resource node)
          this.buildings.addPlot(plot.id, plot);
        }
      }
      // Add capital tile for player (not in plots - it's the main base)
      if(D.map && D.map.playerCapital){
        const cap = D.map.playerCapital;
        this.land.addTile("capital_player", {
          x: cap.col, y: cap.row,
          type: "capital",
          level: 1,
          owner: this.playerId,
          garrison: []
        });
      }
      if(D.map && D.map.enemyCapital){
        const cap = D.map.enemyCapital;
        this.land.addTile("capital_enemy", {
          x: cap.col, y: cap.row,
          type: "capital",
          level: 1,
          owner: "enemy",
          garrison: []
        });
      }
      // Starting resources
      this.resources.add("crop", 500);
      this.resources.add("wood", 300);
      this.resources.add("stone", 200);
    
      // Initialize production from owned plots (capital gives base production)
      this.updateProductionFromPlots();
    }

    updateProductionFromPlots(){
      const D = getDATA();
      // Calculate production based on owned plots
      const ownedPlots = this.land.getPlayerTiles(this.playerId);
      const prod = {crop: 0, wood: 0, stone: 0};
      for(const plot of ownedPlots){
        const baseProd = this.getPlotBaseProduction(plot.type, plot.level);
        prod.crop += baseProd.crop;
        prod.wood += baseProd.wood;
        prod.stone += baseProd.stone;
      }
      this.resources.setProduction(prod);
    }

    getPlotBaseProduction(type, level){
      // Base production per level per resource type
      const base = {crop: 10, wood: 8, stone: 6}; // per level
      const mult = level;
      if(type === "capital"){
        return {crop: 50, wood: 30, stone: 20}; // capital base production
      }
      return {
        crop: (type==="crop" ? base.crop : 0) * mult,
        wood: (type==="wood" ? base.wood : 0) * mult,
        stone: (type==="stone" ? base.stone : 0) * mult
      };
    }

  // ============================================================
  // MAIN TICK / TURN PROCESSING
  // ============================================================
  nextTurn(){
    this.turn++;
    const seasonResult = this.season.nextDay();
    
      // 1. Resource production (from owned plots)
      this.updateProductionFromPlots();
      this.resources.applyProduction();
    
      const prod = this.resources.production;
    
    // 2. Building construction completion (instant in demo)
    
    // 3. Troop training completion
    
    // 4. Season effects
    const seasonBonus = this.season.getSeasonBonus();
    if(seasonBonus.cropPct){
      this.resources.resources.crop = Math.floor(this.resources.resources.crop * (1 + seasonBonus.cropPct/100));
    }
    
    // 5. Check victory
    this.victory = this.land.checkVictory(this.playerId);
    
    // 6. Check defeat (no troops, no resources, all land lost)
    const myTiles = this.land.getPlayerTiles(this.playerId);
    const myTroops = this.troops.getTotalTroopCount();
    if(myTiles.length === 0 && myTroops === 0){
      this.defeated = true;
      this.victory = {type: "defeat"};
    }
    
    this.log.push({
      turn: this.turn,
      season: this.season.getSeasonName(),
      day: this.season.getDayInSeason(),
      resources: this.resources.getState(),
      tiles: myTiles.length,
      troops: myTroops,
      victory: this.victory,
      defeated: this.defeated
    });
    
    return {
      turn: this.turn,
      season: seasonResult,
      resources: this.resources.getState(),
      production: prod,
      victory: this.victory,
      defeated: this.defeated
    };
  }

  // ============================================================
  // BATTLE INTEGRATION
  // ============================================================
  resolveBattle(attackerTroopIndices, defenderTileId, plotId, diffIdx=0){
    const Battle = global.Battle;
    if(!Battle) return {success: false, reason: "Battle engine not loaded"};
    
    const attackerTroops = attackerTroopIndices.map(i => this.troops.troops[i]).filter(t=>t);
    if(attackerTroops.length === 0) return {success: false, reason: "No attacker troops"};
    
    const defenderTile = this.land.tiles.get(defenderTileId);
    if(!defenderTile) return {success: false, reason: "Invalid tile"};
    
    // Build attacker teams
    const attackerTeams = attackerTroops.map((t, idx) => ({
      teamId: idx + 1,
      units: [this.createBattleUnit(t)]
    }));
    
    // Build defender teams from garrison
    const defenderUnits = (defenderTile.garrison || []).map((g, idx) => {
      const soldier = getDATA().soldiers.find(s=>s.id===g.soldierId);
      if(!soldier) return null;
      const unit = new Battle.Unit(soldier, "enemy", idx+1, null, [], [], 1, g.count);
      unit.hp = g.hp || unit.hp;
      return unit;
    }).filter(u=>u);
    
    const defenderTeams = defenderUnits.length > 0 ? [{teamId: 1, units: defenderUnits}] : [{teamId: 1, units: []}];
    
    // Run battle
    const result = Battle.run(attackerTeams, defenderTeams, plotId, diffIdx);
    
    // Apply results
    if(result.victory === "player"){
      this.land.captureTile(defenderTileId, this.playerId, result);
      // Update attacker troop counts from survivors
      attackerTroopIndices.forEach((idx, i) => {
        const survivor = result.attackerSurvivors[i];
        if(survivor && this.troops.troops[idx]){
          this.troops.troops[idx].count = survivor.count;
          this.troops.troops[idx].hp = survivor.hp;
        }
      });
    }else{
      // Defeat: attacker troops lost
      attackerTroopIndices.forEach(idx => {
        if(this.troops.troops[idx]){
          this.troops.troops[idx].count = 0;
        }
      });
      // Remove dead troops
      this.troops.troops = this.troops.troops.filter(t=>t.count > 0);
    }
    
    return {success: true, result};
  }

  createBattleUnit(troop){
    const D = getDATA();
    const soldier = D.soldiers.find(s=>s.id===troop.soldierId);
    const hero = troop.heroId ? D.heroes.find(h=>h.id===troop.heroId) : null;
    return new Battle.Unit(
      soldier, "player", 1, 
      troop.heroId, 
      troop.equipIds, 
      troop.expertiseIds, 
      troop.level, 
      troop.count
    );
  }

  // ============================================================
  // SERIALIZATION
  // ============================================================
  serialize(){
    return {
      turn: this.turn,
      playerId: this.playerId,
      resources: this.resources.getState(),
      buildings: Array.from(this.buildings.buildings.entries()).map(([k,v])=>[k, {
        id: v.id, name: v.name, type: v.type, level: v.level,
        maxLevel: v.maxLevel, cost: v.cost, production: v.production, effects: v.effects
      }]),
      troops: this.troops.troops,
      land: {
        tiles: Array.from(this.land.tiles.entries()),
        remains: Array.from(this.land.remains.entries())
      },
      season: {
        currentSeason: this.season.currentSeason,
        dayInSeason: this.season.dayInSeason,
        totalDays: this.season.totalDays
      },
      unions: {
        unions: Array.from(this.unions.unions.entries()),
        playerUnion: this.unions.playerUnion
      },
      victory: this.victory,
      defeated: this.defeated,
      log: this.log.slice(-50) // last 50 turns
    };
  }

  static deserialize(data){
    const state = new GameState();
    state.turn = data.turn;
    state.playerId = data.playerId;
    state.victory = data.victory;
    state.defeated = data.defeated;
    state.log = data.log || [];
    
    // Resources
    state.resources.resources = data.resources;
    state.resources.production = data.resources.production || {};
    state.resources.storage = data.resources.storage || {};
    
    // Buildings
    for(const [k,v] of data.buildings){
      const b = new Building(v, v.level);
      state.buildings.buildings.set(k, b);
    }
    
    // Troops
    state.troops.troops = data.troops || [];
    
    // Land
    for(const [k,v] of data.land.tiles){
      state.land.tiles.set(k, v);
    }
    for(const [k,v] of data.land.remains){
      state.land.remains.set(k, v);
    }
    
    // Season
    state.season.currentSeason = data.season.currentSeason;
    state.season.dayInSeason = data.season.dayInSeason;
    state.season.totalDays = data.season.totalDays;
    state.season.isWinter = (data.season.currentSeason === 3);
    
    // Unions
    for(const [k,v] of data.unions.unions){
      state.unions.unions.set(k, v);
    }
    state.unions.playerUnion = data.unions.playerUnion;
    
    return state;
  }
}

// ============================================================
// PUBLIC API
// ============================================================
global.Game = {
  GameState: GameState,
  ResourceManager: ResourceManager,
  BuildingManager: BuildingManager,
  Building: Building,
  TroopManager: TroopManager,
  LandManager: LandManager,
  SeasonManager: SeasonManager,
  UnionManager: UnionManager,
  SEASONS: SEASONS,
  SEASON_DAYS: SEASON_DAYS,
  VICTORY_CONDITIONS: VICTORY_CONDITIONS
};

})(typeof window!=="undefined"?window:global);