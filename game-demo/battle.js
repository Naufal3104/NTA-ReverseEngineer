// -*- coding: utf-8 -*-
/**
 * Battle Engine for NTA Demo
 * Auto-resolve simulation with detailed log (tactical grid movement planned for later)
 * Uses DATA from data.js - must be loaded first via <script src="data.js"></script>
 */
(function(global){
"use strict";

// Lazy DATA accessor - supports both browser global and Node module
function getDATA(){
  return (typeof global.DATA !== "undefined") ? global.DATA : 
         (typeof module !== "undefined" && module.exports && require("./data.js")) || {};
}

// ============================================================
// UTILITIES
// ============================================================
function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
function lerp(min, max, t){ return min + (max - min) * t; }
function roll(pct){ return Math.random() * 100 < pct; }
function pick(arr){ return arr[Math.floor(Math.random() * arr.length)]; }
function sum(arr, fn){ return arr.reduce((a,b)=>a+(fn?fn(b):b),0); }

// per-level stat interpolation (Lv1..Lv6 from documented brackets)
function statAtLevel(unit, level){
  if(!unit.hp || unit.hp.length < 2) return {hp:unit.hp?unit.hp[0]:0, atk:unit.atk?unit.atk[0]:0};
  const t = clamp((level-1)/5, 0, 1);
  let hp = Math.round(lerp(unit.hp[0], unit.hp[1], t));
  let atk;
  if(unit.atkRandom){
    atk = Math.round(lerp(unit.atkRandom[0], unit.atkRandom[1], t));
  }else if(unit.atk && unit.atk.length >= 2){
    atk = Math.round(lerp(unit.atk[0], unit.atk[1], t));
  }else{
    atk = unit.atk ? unit.atk[0] : 0;
  }
  return {hp, atk};
}

// type triangle: counter gets +40% ATK & ignores 20% DMG Reduction; attacked by counter gets -40% ATK
function getTYPE_TRI(){
  const D = getDATA();
  return D.typeTriangle || {spear:"cavalry", cavalry:"shield", shield:"bow", bow:"spear"};
}
function isCounter(attType, defType){ return getTYPE_TRI()[attType] === defType; }
function isCounteredBy(attType, defType){ return getTYPE_TRI()[defType] === attType; }

// ============================================================
// EFFECT VOCABULARY (simplified for demo)
// Keys match COMMON_FX and exclusive mod implementations
// ============================================================
const FX = {
  // flat / pct stats
  atkPct: (ctx, v)=> ctx.atkPct = (ctx.atkPct||0) + v,
  hpPct: (ctx, v)=> ctx.hpPct = (ctx.hpPct||0) + v,
  atkFlat: (ctx, v)=> ctx.atkFlat = (ctx.atkFlat||0) + v,
  hpFlat: (ctx, v)=> ctx.hpFlat = (ctx.hpFlat||0) + v,
  // damage modifiers
  dmgOut: (ctx, v)=> ctx.dmgOut = (ctx.dmgOut||0) + v,
  dmgIn: (ctx, v)=> ctx.dmgIn = (ctx.dmgIn||0) + v,
  meleeRed: (ctx, v)=> ctx.meleeRed = (ctx.meleeRed||0) + v,
  rangedRed: (ctx, v)=> ctx.rangedRed = (ctx.rangedRed||0) + v,
  ignoreDR: (ctx, v)=> ctx.ignoreDR = (ctx.ignoreDR||0) + v,
  earlyDR: (ctx, v)=> ctx.earlyDR = (ctx.earlyDR||0) + v,
  stackDR: (ctx, v)=> ctx.stackDR = (ctx.stackDR||0) + v,
  below50Atk: (ctx, v)=> ctx.below50Atk = (ctx.below50Atk||0) + v,
  // crit / true dmg
  crit: (ctx, v)=> ctx.critChance = Math.min(100, (ctx.critChance||0) + v),
  critMult: (ctx, v)=> ctx.critMult = Math.max(100, (ctx.critMult||100) + v),
  truePct: (ctx, v)=> ctx.truePct = (ctx.truePct||0) + v,
  trueProc: (ctx, v)=> ctx.trueProc = (ctx.trueProc||0) + v,
  trueProcPct: (ctx, v)=> ctx.trueProcPct = (ctx.trueProcPct||0) + v,
  curHpPct: (ctx, v)=> ctx.curHpPct = (ctx.curHpPct||0) + v,
  atkBasedPct: (ctx, v)=> ctx.atkBasedPct = (ctx.atkBasedPct||0) + v,
  // leech / heal / regen
  leech: (ctx, v)=> ctx.leech = Math.min(100, (ctx.leech||0) + v),
  regen: (ctx, v)=> ctx.regen = (ctx.regen||0) + v,
  regenPct: (ctx, v)=> ctx.regenPct = (ctx.regenPct||0) + v,
  healOnDmg: (ctx, v)=> ctx.healOnDmg = (ctx.healOnDmg||0) + v,
  atkHeal: (ctx, v)=> ctx.atkHeal = (ctx.atkHeal||0) + v,
  castHeal: (ctx, v)=> ctx.castHeal = (ctx.castHeal||0) + v,
  // dodge / shield / reflect
  dodge: (ctx, v)=> ctx.dodge = Math.min(100, (ctx.dodge||0) + v),
  ignoreDodge: (ctx, v)=> ctx.ignoreDodge = Math.min(100, (ctx.ignoreDodge||0) + v),
  reflect: (ctx, v)=> ctx.reflect = (ctx.reflect||0) + v,
  shieldOnLow: (ctx, v)=> ctx.shieldOnLow = (ctx.shieldOnLow||0) + v,
  shieldOnHit: (ctx, v)=> ctx.shieldOnHit = (ctx.shieldOnHit||0) + v,
  shieldPeriodic: (ctx, v)=> ctx.shieldPeriodic = (ctx.shieldPeriodic||0) + v,
  allyShield: (ctx, v)=> ctx.allyShield = (ctx.allyShield||0) + v,
  // rage
  ragePerAtk: (ctx, v)=> ctx.ragePerAtk = (ctx.ragePerAtk||0) + v,
  rageOnHit: (ctx, v)=> ctx.rageOnHit = (ctx.rageOnHit||0) + v,
  maxRageMinus: (ctx, v)=> ctx.maxRageMinus = (ctx.maxRageMinus||0) + v,
  rageKeep: (ctx, v)=> ctx.rageKeep = (ctx.rageKeep||0) + v,
  // special procs
  execute: (ctx, v)=> ctx.execute = (ctx.execute||0) + v,
  dmgFlatRed: (ctx, v)=> ctx.dmgFlatRed = (ctx.dmgFlatRed||0) + v,
  killAoe: (ctx, v)=> ctx.killAoe = (ctx.killAoe||0) + v,
  burn: (ctx, v)=> ctx.burn = (ctx.burn||0) + v,
  stunOnTrue: (ctx, v)=> ctx.stunOnTrue = (ctx.stunOnTrue||0) + v,
  doubleAct: (ctx, v)=> ctx.doubleAct = (ctx.doubleAct||0) + v,
  rangePlus: (ctx, v)=> ctx.rangePlus = (ctx.rangePlus||0) + v,
  newTargetDmg: (ctx, v)=> ctx.newTargetDmg = (ctx.newTargetDmg||0) + v,
  newTargetTrue: (ctx, v)=> ctx.newTargetTrue = (ctx.newTargetTrue||0) + v,
  dmgCap: (ctx, v)=> ctx.dmgCap = (ctx.dmgCap||0) + v,
  aoeTrue: (ctx, v)=> ctx.aoeTrue = (ctx.aoeTrue||0) + v,
  roundTrue: (ctx, v)=> ctx.roundTrue = (ctx.roundTrue||0) + v,
  // exclusive mod placeholders (implemented per-mod in applyExclMod)
  stab_dodge:0, project_count:0, disarm_aoe:0, steady_attack:0, whirlwind_heal:0,
  dance_parry:0, shield_maxhp:0, stance_perenemy:0, charge_maxhp:0, earthshaker_rage:0,
  guardian_counter:0, whirl_bounce:0, scatter_multi:0, dexterity:0, poison_paralysis:0,
  inspire_heal:0, anchor_kb:0, wildfire:0, leap_repeat:0, sweep_leech:0,
  chop_keep:0, collide_stun:0, guerrilla:0, cleave_shield:0
};

function applyFX(ctx, fxArr){
  if(!fxArr) return;
  for(const [k,v] of fxArr){
    if(FX[k] && typeof FX[k]==="function") FX[k](ctx, v);
  }
}

// ============================================================
// STATUS EFFECTS
// ============================================================
const STATUS = {
  // name: {type, maxStack?, onApply?, onRemove?, onRoundStart?, onRoundEnd?, onHit?, onDealDmg?}
  bleed: {type:"debuff", maxStack:99, onRoundStart:(u,ctx)=> { u.hp -= Math.round(ctx.dmg||0); u.hp = Math.max(0,u.hp); log(ctx, `${u.name} bleeds for ${ctx.dmg} HP`); }},
  poison: {type:"debuff", maxStack:99, onRoundStart:(u,ctx)=> { u.hp -= Math.round(u.maxHp * 0.01 * ctx.pct); u.hp = Math.max(0,u.hp); log(ctx, `${u.name} takes ${ctx.pct}% max HP poison`); }},
  pestilence: {type:"debuff", maxStack:99, onRoundStart:(u,ctx)=> { u.hp -= Math.round(u.maxHp * 0.05 * ctx.stacks); u.hp = Math.max(0,u.hp); log(ctx, `${u.name} suffers pestilence x${ctx.stacks}`); }},
  stun: {type:"debuff", maxStack:1, disableAct:true},
  silence: {type:"debuff", maxStack:1, disableSkill:true},
  shield: {type:"buff", maxStack:99, // shield value stored in ctx.value
    onHit:(u,ctx,dmg)=>{ const absorb=Math.min(ctx.value,dmg); ctx.value-=absorb; return dmg-absorb; },
    onRoundEnd:(u,ctx)=>{ if(--ctx.turns<=0) ctx.value=0; }
  },
  dodge: {type:"buff", maxStack:1, // chance in ctx.value
    onHit:(u,ctx,dmg)=>{ if(roll(ctx.value)){ log(ctx, `${u.name} dodges!`); return 0; } return dmg; },
    onRoundEnd:(u,ctx)=>{ if(--ctx.turns<=0) ctx.value=0; }
  },
  dr: {type:"buff", maxStack:99, // dmg reduction %
    onHit:(u,ctx,dmg)=>{ return Math.round(dmg * (100-ctx.value)/100); },
    onRoundEnd:(u,ctx)=>{ if(--ctx.turns<=0) ctx.value=0; }
  },
  atkBuff: {type:"buff", maxStack:99, // flat or pct in ctx.value
    onRoundEnd:(u,ctx)=>{ if(--ctx.turns<=0) ctx.value=0; }
  },
  leechBuff: {type:"buff", maxStack:1},
  inspire: {type:"buff", maxStack:1},
  fire: {type:"debuff", maxStack:3, onRoundStart:(u,ctx)=>{ u.hp -= Math.round(u.atk * ctx.level * 0.5); u.hp=Math.max(0,u.hp); log(ctx, `${u.name} burns for ${Math.round(u.atk*ctx.level*0.5)}`); }},
  armorBreak: {type:"debuff", maxStack:10, onRoundEnd:(u,ctx)=>{ if(--ctx.turns<=0) ctx.stacks=0; }},
  paralysis: {type:"debuff", maxStack:1, disableAct:true},
  knockback: {type:"debuff", maxStack:1}, // instant
  obsession: {type:"debuff", maxStack:1, disableAct:true}, // attacks allies
  petrify: {type:"debuff", maxStack:1, disableAct:true},
  leap: {type:"buff", maxStack:100}, // sword&shield passive stacks
};

// ============================================================
// UNIT WRAPPER
// ============================================================
function Unit(data, side, teamId, heroId, equipIds, expertiseIds, level, count){
  this.side = side; // "player" or "enemy"
  this.teamId = teamId;
  this.heroId = heroId;
  this.equipIds = equipIds || [];
  this.expertiseIds = expertiseIds || [];
  this.level = clamp(level||1, 1, 6);
  this.count = Math.max(1, count||1);
  this.base = data; // soldier or bestiary entry
  const st = statAtLevel(data, this.level);
  // base stats BEFORE equipment/hero bonuses
  this.maxHp = st.hp;
  this.atk = st.atk;
  // initial HP (will be recalculated in resolveUnitBuild)
  this.hp = this.maxHp * this.count;
  this.range = data.range || 1;
  this.move = data.move || 1;
  this.spd = data.spd || 62;
  this.rage = 0;
  this.rageMax = data.rage ? data.rage[1] : 10;
  this.name = data.name || data.id;
  this.type = data.cat || (data.kind==="beast"?"beast":"bandit");
  this.isPlayer = side==="player";
  this.status = {}; // active status effects
  this.skill = data.skill ? {...data.skill} : null;
  this.passives = data.passives ? [...data.passives] : [];
  this.hero = null; // resolved in resolveUnitBuild
  this.exclusive = null;
  this.equipCommon = [];
  this.expertise = [];
  this.logTag = `[T${teamId}] ${this.name}`;
  this.dead = false;
  this.actedThisTurn = false;
  this.enteredTurn = 0;
  this.leapStacks = 0;
  // bonus accumulators (applied in resolveUnitBuild)
  this.hpPct = 0; this.hpFlat = 0;
  this.atkPct = 0; this.atkFlat = 0;
  this.dmgOut = 0; this.dmgIn = 0;
  this.meleeRed = 0; this.rangedRed = 0;
  this.ignoreDR = 0; this.earlyDR = 0; this.stackDR = 0; this.below50Atk = 0;
  this.critChance = 0; this.critMult = 150;
  this.truePct = 0; this.trueProc = 0; this.trueProcPct = 0;
  this.curHpPct = 0; this.atkBasedPct = 0;
  this.leech = 0; this.regen = 0; this.regenPct = 0;
  this.healOnDmg = 0; this.atkHeal = 0; this.castHeal = 0;
  this.dodge = 0; this.ignoreDodge = 0;
  this.reflect = 0; this.shieldOnLow = 0; this.shieldOnHit = 0;
  this.shieldPeriodic = 0; this.allyShield = 0;
  this.ragePerAtk = 0; this.rageOnHit = 0; this.maxRageMinus = 0; this.rageKeep = 0;
  this.execute = 0; this.dmgFlatRed = 0; this.killAoe = 0;
  this.burn = 0; this.stunOnTrue = 0; this.doubleAct = 0;
  this.rangePlus = 0; this.newTargetDmg = 0; this.newTargetTrue = 0;
  this.dmgCap = 0; this.aoeTrue = 0; this.roundTrue = 0;
}

Unit.prototype.isAlive = function(){ return this.hp > 0 && this.count > 0; };
Unit.prototype.hpPct = function(){ return this.maxHp ? this.hp / (this.maxHp * this.count) * 100 : 0; };
Unit.prototype.heal = function(amt){ this.hp = Math.min(this.maxHp * this.count, this.hp + amt); };
Unit.prototype.takeDmg = function(dmg, ctx){
  dmg = Math.max(0, dmg);
  this.hp = Math.max(0, this.hp - dmg);
  if(this.hp <= 0){
    this.count = 0;
    this.dead = true;
    log(ctx, `${this.logTag} destroyed!`);
  }
  return dmg;
};
Unit.prototype.gainRage = function(amt, ctx){
  this.rage = Math.min(this.rageMax, this.rage + amt);
  if(this.rage >= this.rageMax && this.skill && !this.skill.used){
    this.castSkill(ctx);
  }
};

// ============================================================
// BATTLE CONTEXT
// ============================================================
function BattleContext(attackerTeams, defenderTeams, plotId, diffIdx){
  this.attacker = attackerTeams; // array of Unit[] (each team is array of units, but demo uses 1 unit per team)
  this.defender = defenderTeams;
  this.plotId = plotId;
  this.diffIdx = diffIdx;
  this.turn = 1;
  this.phase = "deploy"; // deploy, player, enemy, end
  this.log = [];
  this.round = 0;
  this.playerGroups = []; // deployment order groups 1..5
  this.enemyGroups = [];
  this.victory = null;
}

function log(ctx, msg){ ctx.log.push(`[T${ctx.turn}] ${msg}`); }

// ============================================================
// EQUIPMENT / HERO / EXPERTISE RESOLUTION
// ============================================================
function resolveUnitBuild(u){
  // hero
  if(u.hero){
    u.maxHp = Math.round(u.maxHp * (1 + u.hero.hp[1]/100)); // simplified: use max hp bonus
    u.atk = Math.round(u.atk * (1 + u.hero.atk[1]/100));
    // hero skill archetype (demo: keyword match)
    u.heroArchetype = guessHeroArchetype(u.hero);
  }
  // common equipment
  for(const eid of u.equipIds){
      const eq = getDATA().commonEquipment.find(e=>e.id===eid);
    if(eq){
      u.equipCommon.push(eq);
      applyFX(u, eq.fx);
    }
  }
  // exclusive equipment
  if(u.base.id && u.exclusiveId){
      const ex = getDATA().exclusiveEquipment.find(e=>e.id===u.exclusiveId);
    if(ex && ex.subId === u.base.id){
      u.exclusive = ex;
      // modKey effect applied during battle
    }
  }
  // expertise
    if(u.expertiseIds && getDATA().expertise){
      for(const cat of Object.keys(getDATA().expertise)){
        for(const tier of Object.keys(getDATA().expertise[cat])){
          for(const exp of getDATA().expertise[cat][tier]){
          if(u.expertiseIds.includes(exp.text)){ // match by text (demo)
            u.expertise.push(exp);
            applyFX(u, exp.fx);
          }
        }
      }
    }
  }
  // recalc stats after all bonuses
  u.maxHp = Math.round(u.maxHp * (1 + (u.hpPct||0)/100)) + (u.hpFlat||0);
  u.hp = u.maxHp * u.count;
  u.atk = Math.round(u.atk * (1 + (u.atkPct||0)/100)) + (u.atkFlat||0);
}

function guessHeroArchetype(hero){
  const txt = (hero.skillName + " " + hero.desc + " " + hero.unique).toLowerCase();
  if(/heal|restore|hp/.test(txt)) return "heal";
  if(/rage/.test(txt)) return "rage";
  if(/shield|defend|protect|reduce|guard/.test(txt)) return "defense";
  return "damage";
}

// ============================================================
// EXCLUSIVE MOD IMPLEMENTATIONS (simplified)
// ============================================================
function applyExclMod(attacker, defender, ctx, modKey, isHit){
  if(!modKey) return;
  switch(modKey){
    case "stab_dodge":
      if(isHit && attacker.skill && attacker.skill.name==="Stabs"){
        attacker.gainStatus("dodge", 15, 3, ctx);
      } break;
    case "project_count":
      if(isHit && attacker.skill && attacker.skill.name==="Project"){
        ctx.extraDmg = (attacker.count * attacker.level) * Math.min(40, 1); // simplified
      } break;
    case "disarm_aoe":
      if(isHit && attacker.skill && attacker.skill.name==="Disarm"){
        ctx.aoeTargets = 4;
      } break;
    case "steady_attack":
      if(attacker.base.id==="modao") attacker.steadyCount = (attacker.steadyCount||0)+1; break;
    case "whirlwind_heal":
      if(isHit && attacker.skill && attacker.skill.name==="Whirlwind"){
        attacker.heal(Math.round(0.4 * (ctx.bleedDmg||0)));
      } break;
    case "dance_parry":
      if(attacker.skill && attacker.skill.name==="Unbridled Dance"){
        attacker.danceParryTurns = 2; // +1 round
      } break;
    case "shield_maxhp":
      if(isHit && attacker.skill && /Shield/.test(attacker.skill.name)){
        ctx.shieldBonus = Math.round(attacker.maxHp * 0.05);
      } break;
    case "stance_perenemy":
      // handled in dmg calculation
      break;
    case "charge_maxhp":
      if(isHit && attacker.skill && attacker.skill.name==="Charge"){
        ctx.extraDmg = Math.round(attacker.maxHp * 0.05);
      } break;
    case "earthshaker_rage":
      if(isHit && attacker.skill && attacker.skill.name==="Earthshaker"){
        // allies in range gain rage - simplified
      } break;
    case "guardian_counter":
      if(!isHit){ // taking dmg
        attacker.guardianStacks = (attacker.guardianStacks||0)+1;
        attacker.atk = Math.round(attacker.atk * (1 + 0.03 * attacker.guardianStacks));
      } break;
    case "whirl_bounce":
      if(attacker.skill && attacker.skill.name==="Whirling Axe"){
        attacker.whirlBounces = 3; // +2
        attacker.shieldBashStunChance = (attacker.shieldBashStunChance||0)+20;
      } break;
    case "scatter_multi":
      if(isHit && attacker.skill && attacker.skill.name==="Scatter"){
        ctx.scatterTargets = 4;
      } break;
    case "dexterity":
      if(!isHit){
        const dist = ctx.distance||1;
        const chance = Math.max(0, 30 - (dist-1)*10);
        if(roll(chance)){
          log(ctx, `${attacker.logTag} dexterity dodges!`);
          return 0; // dodge
        }
      } break;
    case "poison_paralysis":
      if(isHit && attacker.skill && attacker.skill.name==="Poison Arrow"){
        const chance = 10 * attacker.level;
        if(roll(chance)) defender.gainStatus("paralysis", 1, 1, ctx);
      } break;
    case "inspire_heal":
      if(attacker.skill && attacker.skill.name==="Inspire"){
        ctx.healAllies = 1 + attacker.level;
      } break;
    case "anchor_kb":
      if(isHit && attacker.skill && attacker.skill.name==="Rapid Fire"){
        // knockback handled in movement (demo: skip)
      } break;
    case "wildfire":
      // fire spread - simplified
      break;
    case "leap_repeat":
      if(isHit && attacker.skill && attacker.skill.name==="Leap Slash" && ctx.killed){
        if(roll(85)) ctx.extraAction = true;
      } break;
    case "sweep_leech":
      if(isHit && attacker.skill && attacker.skill.name==="Sweep"){
        attacker.leech = 20;
      } break;
    case "chop_keep":
      if(attacker.skill && attacker.skill.name==="Chop"){
        attacker.chopReserve = 0.5;
      } break;
    case "collide_stun":
      if(isHit && attacker.skill && attacker.skill.name==="Collide"){
        ctx.stunTargets = 4;
      } break;
    case "guerrilla":
      if(isHit && ctx.targetType==="shield") attacker.atk = Math.round(attacker.atk * 1.2); break;
    case "cleave_shield":
      if(isHit && attacker.skill && attacker.skill.name==="Cleave"){
        attacker.gainStatus("shield", 6*ctx.hitCount, 1, ctx);
      }else{
        attacker.atk = Math.round(attacker.atk * 1.3);
      } break;
  }
}

// ============================================================
// STATUS HELPERS
// ============================================================
Unit.prototype.gainStatus = function(name, value, turns, ctx){
  const def = STATUS[name];
  if(!def) return;
  const cur = this.status[name];
  if(cur){
    cur.value = Math.max(cur.value, value);
    cur.turns = Math.max(cur.turns, turns);
    if(def.maxStack && cur.stacks) cur.stacks = Math.min(def.maxStack, cur.stacks+1);
  }else{
    this.status[name] = {value, turns, stacks:1};
  }
  log(ctx, `${this.logTag} gains ${name} ${value} for ${turns}t`);
};
Unit.prototype.hasStatus = function(name){ return !!this.status[name]; };
Unit.prototype.canAct = function(){
  if(this.dead) return false;
  for(const [k,v] of Object.entries(this.status)){
    const def = STATUS[k];
    if(def && def.disableAct) return false;
  }
  return true;
};
Unit.prototype.canCastSkill = function(){
  if(this.dead) return false;
  for(const [k,v] of Object.entries(this.status)){
    const def = STATUS[k];
    if(def && def.disableSkill) return false;
  }
  return true;
};
Unit.prototype.tickStatus = function(ctx){
  for(const [name, st] of Object.entries(this.status)){
    const def = STATUS[name];
    if(def.onRoundEnd) def.onRoundEnd(this, st);
    if(def.onRoundStart) def.onRoundStart(this, st);
    st.turns--;
    if(st.turns <= 0) delete this.status[name];
  }
};

// ============================================================
// DAMAGE CALCULATION
// ============================================================
function calcDamage(attacker, defender, skillMult, ctx){
  // base
  let dmg = Math.round(attacker.atk * (skillMult || 1));
  // crit
  if(roll(attacker.critChance||0)){
    dmg = Math.round(dmg * (attacker.critMult||150) / 100);
    ctx.crit = true;
  }
  // true dmg portion
  let trueDmg = 0;
  if(attacker.truePct) trueDmg += Math.round(dmg * attacker.truePct / 100);
  if(attacker.trueProc && roll(attacker.trueProc)){
    trueDmg += Math.round(dmg * (attacker.trueProcPct||100) / 100);
  }
  if(attacker.curHpPct) trueDmg += Math.round(defender.hp / defender.count * attacker.curHpPct / 100);
  if(attacker.atkBasedPct) trueDmg += Math.round(attacker.atk * attacker.atkBasedPct / 100);
  if(attacker.aoeTrue) trueDmg += Math.round(attacker.aoeTrue * attacker.atk / 100);
  if(attacker.roundTrue) trueDmg += Math.round(attacker.roundTrue * attacker.atk / 100);
  // leech
  let leechAmt = 0;
  if(attacker.leech) leechAmt = Math.round(dmg * attacker.leech / 100);
  // type triangle
  let atkMult = 1, defMult = 1;
  if(isCounter(attacker.type, defender.type)){
    atkMult = 1.4; defMult = 0.8;
    log(ctx, `${attacker.logTag} COUNTERS ${defender.logTag}!`);
  }else if(isCounteredBy(attacker.type, defender.type)){
    atkMult = 0.6;
    log(ctx, `${attacker.logTag} is COUNTERED by ${defender.logTag}!`);
  }
  dmg = Math.round(dmg * atkMult);
  // defense reductions
  let dr = (defender.meleeRed||0) + (defender.rangedRed||0) + (defender.earlyDR||0) + (defender.stackDR * (defender.armorStacks||0)) + (defender.below50Atk * (defender.hpPct()<50?1:0));
  if(attacker.ignoreDR) dr = Math.max(0, dr - attacker.ignoreDR);
  dmg = Math.round(dmg * (100 - dr) / 100);
  dmg -= (defender.dmgFlatRed||0);
  // dmg taken modifiers
  dmg = Math.round(dmg * (100 + (defender.dmgIn||0)) / 100);
  // attacker dmg out
  dmg = Math.round(dmg * (100 + (attacker.dmgOut||0)) / 100);
  // dmg cap
  if(attacker.dmgCap) dmg = Math.min(dmg, attacker.dmgCap);
  // status: dodge
  if(defender.hasStatus("dodge")){
    const sd = defender.status.dodge;
    if(roll(sd.value) && !attacker.ignoreDodge){
      log(ctx, `${defender.logTag} DODGES!`);
      return {dmg:0, trueDmg:0, leech:0, dodged:true};
    }
  }
  // status: shield
  if(defender.hasStatus("shield")){
    const sd = defender.status.shield;
    const absorb = Math.min(sd.value, dmg);
    sd.value -= absorb;
    dmg -= absorb;
    log(ctx, `${defender.logTag} shield absorbs ${absorb}`);
    if(sd.value <= 0) delete defender.status.shield;
  }
  // reflect
  if(defender.reflect && !trueDmg){
    const ref = Math.round(dmg * defender.reflect / 100);
    attacker.takeDmg(ref, ctx);
    log(ctx, `${attacker.logTag} reflects ${ref} dmg`);
  }
  // exclusive mod
  applyExclMod(attacker, defender, ctx, attacker.exclusive?.modKey, true);
  // stance_perenemy (heavy shield exclusive)
  if(defender.exclusive?.modKey==="stance_perenemy"){
    const enemies = countAdjacentEnemies(defender, ctx);
    dmg = Math.round(dmg * (100 - enemies*5) / 100);
  }
  return {dmg:Math.max(0,dmg), trueDmg:Math.max(0,trueDmg), leech:leechAmt, dodged:false};
}

function countAdjacentEnemies(unit, ctx){
  // simplified: count all alive enemy units
  const enemies = unit.isPlayer ? ctx.defender.flat() : ctx.attacker.flat();
  return enemies.filter(u=>u.isAlive()).length;
}

// ============================================================
// SKILL CASTING (simplified archetype implementation)
// ============================================================
function castSkill(attacker, targets, ctx){
  if(!attacker.skill || !attacker.canCastSkill()) return;
  const name = attacker.skill.name;
  log(ctx, `${attacker.logTag} casts ${name}!`);
  attacker.skill.used = true;
  attacker.rage = 0;
  // simplified: apply skill as multi-target attack with effect
  const skillMult = 1.0; // base multiplier, skills have their own in desc but demo approximates
  for(const target of targets){
    const res = calcDamage(attacker, target, skillMult, ctx);
    const dealt = target.takeDmg(res.dmg + res.trueDmg, ctx);
    if(res.leech) attacker.heal(res.leech);
    if(res.leech && attacker.healOnDmg) attacker.heal(attacker.healOnDmg);
    if(attacker.castHeal) attacker.heal(attacker.castHeal);
    if(attacker.skillPassive === "leech") attacker.heal(Math.round(dealt * attacker.skillPassiveVal/100));
    // on-hit effects
    if(attacker.rageOnHit) attacker.gainRage(attacker.rageOnHit, ctx);
    if(attacker.killAoe && target.dead){
      // aoe to nearby
      for(const t2 of targets){ if(t2!==target && t2.isAlive()) t2.takeDmg(attacker.killAoe, ctx); }
    }
    if(attacker.stunOnTrue && res.trueDmg > 0 && roll(attacker.stunOnTrue)) target.gainStatus("stun", 1, 1, ctx);
  }
  // hero archetype bonus
  if(attacker.heroArchetype==="heal"){
    const ally = attacker.isPlayer ? ctx.attacker.flat() : ctx.defender.flat();
    const hurt = ally.filter(u=>u.isAlive()).sort((a,b)=>a.hpPct()-b.hpPct())[0];
    if(hurt) hurt.heal(Math.round(hurt.maxHp * 0.2));
  }
  if(attacker.heroArchetype==="rage"){
    const ally = attacker.isPlayer ? ctx.attacker.flat() : ctx.defender.flat();
    for(const a of ally) if(a.isAlive()) a.gainRage(1, ctx);
  }
  if(attacker.heroArchetype==="defense"){
    attacker.gainStatus("dr", 30, 2, ctx);
  }
  if(attacker.heroArchetype==="damage"){
    attacker.atk = Math.round(attacker.atk * 1.2);
  }
}

// ============================================================
// TARGET SELECTION
// ============================================================
function selectTargets(attacker, enemies, skill){
  const alive = enemies.filter(u=>u.isAlive());
  if(!alive.length) return [];
  // simplified: prioritize lowest HP, then closest (demo ignores grid)
  if(skill && /lowest HP/.test(skill.desc)) return [alive.sort((a,b)=>a.hpPct()-b.hpPct())[0]];
  if(skill && /furthest/.test(skill.desc)) return [alive.sort((a,b)=>b.maxHp-a.maxHp)[0]];
  if(skill && /most enemies/.test(skill.desc)) return alive.slice(0, Math.min(8, alive.length));
  return [alive[0]]; // single target default
}

// ============================================================
// TURN ORDER & DEPLOYMENT (per user rules)
// ============================================================
function prepareDeployment(ctx){
  // attacker teams are grouped 1..5 by teamId order
  // turn 1: group 1 attacks, then enemy
  // turn 2: groups 2..5 attack, then group 1 attacks last, then enemy
  // turn 3+: all groups attack, then enemy
  ctx.playerGroups = [];
  for(let i=1;i<=5;i++){
    const g = ctx.attacker.filter(t=>t.teamId===i);
    if(g.length) ctx.playerGroups.push(g);
  }
  ctx.enemyGroups = [ctx.defender.filter(u=>u.isAlive())];
  ctx.turn = 1;
  ctx.phase = "player";
}

function getActiveAttackers(ctx){
  if(ctx.turn === 1){
    return ctx.playerGroups[0] || [];
  }else if(ctx.turn === 2){
    const groups = ctx.playerGroups.slice(1);
    const last = ctx.playerGroups[0] || [];
    return [...groups.flat(), ...last];
  }else{
    return ctx.playerGroups.flat();
  }
}

// ============================================================
// MAIN BATTLE LOOP
// ============================================================
function runBattle(attackerTeams, defenderTeams, plotId, diffIdx){
  const ctx = new BattleContext(attackerTeams, defenderTeams, plotId, diffIdx);
  // flatten teams into unit arrays
  const atkUnits = attackerTeams.flatMap(t=>t.units).filter(u=>u.isAlive());
  const defUnits = defenderTeams.flatMap(t=>t.units).filter(u=>u.isAlive());
  ctx.attacker = atkUnits;
  ctx.defender = defUnits;
  // resolve builds
  [...atkUnits, ...defUnits].forEach(resolveUnitBuild);
  prepareDeployment(ctx);
  const maxTurns = 50;
  while(ctx.turn <= maxTurns && !ctx.victory){
    // player phase
    if(ctx.phase === "player"){
      const actors = getActiveAttackers(ctx);
      for(const atk of actors){
        if(!atk.isAlive() || !atk.canAct()) continue;
        atk.actedThisTurn = true;
        // gain rage per attack (simplified: +1 per attack action)
        atk.gainRage(1, ctx);
        // select targets
        const targets = selectTargets(atk, ctx.defender, atk.skill);
        if(targets.length){
          // basic attack or skill
          if(atk.rage >= atk.rageMax && atk.skill && !atk.skill.used){
            castSkill(atk, targets, ctx);
          }else{
            for(const target of targets){
              const res = calcDamage(atk, target, 1.0, ctx);
              const dealt = target.takeDmg(res.dmg + res.trueDmg, ctx);
              if(res.leech) atk.heal(res.leech);
              if(atk.rageOnHit) atk.gainRage(atk.rageOnHit, ctx);
            }
          }
        }
      }
      // check victory
      if(!ctx.defender.some(u=>u.isAlive())){ ctx.victory = "player"; break; }
      ctx.phase = "enemy";
    }
    // enemy phase
    if(ctx.phase === "enemy"){
      for(const def of ctx.defender){
        if(!def.isAlive() || !def.canAct()) continue;
        const targets = selectTargets(def, ctx.attacker, def.skill);
        if(targets.length){
          if(def.rage >= def.rageMax && def.skill && !def.skill.used){
            castSkill(def, targets, ctx);
          }else{
            for(const target of targets){
              const res = calcDamage(def, target, 1.0, ctx);
              target.takeDmg(res.dmg + res.trueDmg, ctx);
            }
          }
        }
      }
      if(!ctx.attacker.some(u=>u.isAlive())){ ctx.victory = "enemy"; break; }
      // end of turn: tick status
      [...ctx.attacker, ...ctx.defender].forEach(u=>u.tickStatus(ctx));
      ctx.turn++;
      ctx.phase = "player";
    }
  }
  // rewards
    const D = getDATA();
    let rewards = {chests: [], rewardPoints: 0, resources: {crop:0, wood:0, stone:0}};
    if(ctx.victory === "player"){
      const plot = D.map.plots.find(p=>p.id===ctx.plotId);
      if(plot){
        const lvl = plot.level;
        // chest by level
        if(lvl <= 2) rewards.chests.push("wood");
        else if(lvl === 3) rewards.chests.push("silver");
        else if(lvl === 4) rewards.chests.push("gold");
        else { rewards.chests.push("gold"); rewards.chests.push("special"); }
        // reward points cost (first conquest only - demo always gives)
        rewards.rewardPoints = -D.reward.firstCost[lvl];
      }
    }
  return {victory: ctx.victory, turn: ctx.turn, log: ctx.log, rewards, attackerSurvivors: ctx.attacker.filter(u=>u.isAlive()), defenderSurvivors: ctx.defender.filter(u=>u.isAlive())};
}

// ============================================================
// PUBLIC API
// ============================================================
global.Battle = {
  run: runBattle,
  Unit: Unit,
  statAtLevel: statAtLevel,
  TYPE_TRI: getTYPE_TRI(),
  FX: FX,
  STATUS: STATUS
};

})(typeof window!=="undefined"?window:global);