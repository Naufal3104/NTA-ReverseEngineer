// -*- coding: utf-8 -*-
/**
 * NTA Demo - UI Controller
 * Handles all UI rendering and user interactions
 */
(function(global){
"use strict";

// ============================================================
// UI STATE
// ============================================================
const UI = {
  game: null,
  selectedTileId: null,
  mapZoom: 1,
  mapOffset: {x: 0, y: 0},
  isDragging: false,
  lastMousePos: {x: 0, y: 0},
  canvas: null,
  ctx: null,
  tileSize: 40,
  
  // Initialize UI
  init(gameState){
    this.game = gameState;
    this.canvas = document.getElementById('mapCanvas');
    this.ctx = this.canvas.getContext('2d');
    this.setupEventListeners();
      this.hideLoading();  // Must show gameScreen FIRST so mapContainer has size
      this.resizeCanvas(); // Now container has proper dimensions
      this.renderAll();
  },

  hideLoading(){
    document.getElementById('loading').classList.remove('active');
    document.getElementById('gameScreen').classList.add('active');
  },

  // ============================================================
  // EVENT LISTENERS
  // ============================================================
  setupEventListeners(){
    // Window resize
    window.addEventListener('resize', () => this.resizeCanvas());

    // Next Turn Button
    document.getElementById('nextTurnBtn').addEventListener('click', () => this.nextTurn());

    // Tab Navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
      btn.addEventListener('click', () => this.switchTab(btn.dataset.tab));
    });

    // Map Controls
    document.getElementById('zoomIn').addEventListener('click', () => this.zoomMap(1.2));
    document.getElementById('zoomOut').addEventListener('click', () => this.zoomMap(0.8));
    document.getElementById('resetView').addEventListener('click', () => this.resetMapView());

    // Map Canvas Events
    this.canvas.addEventListener('mousedown', (e) => this.onMapMouseDown(e));
    this.canvas.addEventListener('mousemove', (e) => this.onMapMouseMove(e));
    this.canvas.addEventListener('mouseup', () => this.onMapMouseUp());
    this.canvas.addEventListener('mouseleave', () => this.onMapMouseUp());
    this.canvas.addEventListener('wheel', (e) => this.onMapWheel(e), {passive: false});
    this.canvas.addEventListener('click', (e) => this.onMapClick(e));

    // Touch events for mobile
    this.canvas.addEventListener('touchstart', (e) => this.onTouchStart(e), {passive: false});
    this.canvas.addEventListener('touchmove', (e) => this.onTouchMove(e), {passive: false});
    this.canvas.addEventListener('touchend', () => this.onTouchEnd());

    // Battle Modal
    document.getElementById('closeBattleModal').addEventListener('click', () => this.hideModal('battleModal'));
    document.getElementById('startBattleBtn').addEventListener('click', () => this.startBattle());
    document.getElementById('closeBattleResult').addEventListener('click', () => this.hideBattleResult());
    document.getElementById('addAttackerBtn').addEventListener('click', () => this.openRecruitModal(true));

    // Recruit Modal
    document.getElementById('closeRecruitModal').addEventListener('click', () => this.hideModal('recruitModal'));
    document.getElementById('confirmRecruitBtn').addEventListener('click', () => this.confirmRecruit());
    document.getElementById('recruitSoldierType').addEventListener('change', () => this.updateRecruitCost());

    // Action Buttons (delegated)
    document.getElementById('actionButtons').addEventListener('click', (e) => {
      const btn = e.target.closest('.action-btn');
      if(btn) this.handleAction(btn.dataset.action, btn.dataset.tileId);
    });

    // Create Union
    document.getElementById('createUnionBtn').addEventListener('click', () => this.createUnion());

    // Close modals on background click
    document.querySelectorAll('.modal').forEach(modal => {
      modal.addEventListener('click', (e) => {
        if(e.target === modal) this.hideModal(modal.id);
      });
    });
  },

  // ============================================================
  // CANVAS / MAP RENDERING
  // ============================================================
  resizeCanvas(){
    const container = document.getElementById('mapContainer');
    const rect = container.getBoundingClientRect();
    this.canvas.width = rect.width * window.devicePixelRatio;
    this.canvas.height = rect.height * window.devicePixelRatio;
    this.canvas.style.width = rect.width + 'px';
    this.canvas.style.height = rect.height + 'px';
    this.ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    this.renderMap();
  },

  getTileScreenPos(tile){
    const container = document.getElementById('mapContainer');
    const centerX = container.clientWidth / 2;
    const centerY = container.clientHeight / 2;
    // Isometric projection
    const isoX = (tile.x - tile.y) * (this.tileSize / 2) * this.mapZoom;
    const isoY = (tile.x + tile.y) * (this.tileSize / 4) * this.mapZoom;
    return {
      x: centerX + isoX + this.mapOffset.x,
      y: centerY + isoY + this.mapOffset.y
    };
  },

  renderMap(){
    if(!this.game || !this.ctx) return;
    
    const ctx = this.ctx;
    const container = document.getElementById('mapContainer');
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    // Clear
    ctx.clearRect(0, 0, width, height);
    
    // Draw tiles
    const tiles = Array.from(this.game.land.tiles.values());
    tiles.forEach(tile => this.drawTile(tile));
    
    // Draw selection highlight
    if(this.selectedTileId){
      const tile = this.game.land.tiles.get(this.selectedTileId);
      if(tile) this.drawSelection(tile);
    }
    
    // Update legend
    this.renderLegend();
  },

  drawTile(tile){
    const ctx = this.ctx;
    const pos = this.getTileScreenPos(tile);
    const size = this.tileSize * this.mapZoom;
    const halfSize = size / 2;
    
    // Skip if off-screen (rough culling)
    if(pos.x < -size || pos.x > this.canvas.clientWidth + size ||
       pos.y < -size || pos.y > this.canvas.clientHeight + size) return;
    
    // Tile colors based on type
    const colors = {
      crop: {base: '#2d5a2d', border: '#4ade80', label: '🌾'},
      wood: {base: '#4a3728', border: '#fb923c', label: '🪵'},
      stone: {base: '#3d3d3d', border: '#9ca3af', label: '🪨'},
      capital: {base: '#5a2d2d', border: '#ffd700', label: '🏰'},
      plain: {base: '#1f1f2e', border: '#3a3a5a', label: '🟫'}
    };
    const color = colors[tile.type] || colors.plain;
    
    // Diamond shape (isometric tile)
    ctx.beginPath();
    ctx.moveTo(pos.x, pos.y - halfSize);
    ctx.lineTo(pos.x + halfSize, pos.y);
    ctx.lineTo(pos.x, pos.y + halfSize);
    ctx.lineTo(pos.x - halfSize, pos.y);
    ctx.closePath();
    
    // Fill
    ctx.fillStyle = color.base;
    ctx.fill();
    
    // Border based on owner
    ctx.strokeStyle = tile.owner === 'player1' ? color.border : 
                      tile.owner === 'enemy' ? '#f87171' : '#3a3a5a';
    ctx.lineWidth = tile.owner !== 'neutral' ? 3 : 1;
    ctx.stroke();
    
    // Level indicator
    if(tile.level > 1){
      ctx.fillStyle = 'rgba(0,0,0,0.5)';
      ctx.beginPath();
      ctx.arc(pos.x + halfSize - 8, pos.y - halfSize + 8, 8, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 11px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(tile.level, pos.x + halfSize - 8, pos.y - halfSize + 8);
    }
    
    // Resource icon
    ctx.font = `${Math.max(10, size * 0.3)}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(color.label, pos.x, pos.y);
    
    // Garrison indicator
    if(tile.garrison && tile.garrison.length > 0){
      ctx.fillStyle = tile.owner === 'player1' ? '#4ade80' : '#f87171';
      ctx.beginPath();
      ctx.arc(pos.x + halfSize - 6, pos.y + halfSize - 6, 6, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 9px sans-serif';
      ctx.fillText(tile.garrison.length, pos.x + halfSize - 6, pos.y + halfSize - 6);
    }
  },

  drawSelection(tile){
    const ctx = this.ctx;
    const pos = this.getTileScreenPos(tile);
    const size = this.tileSize * this.mapZoom;
    const halfSize = size / 2;
    
    ctx.strokeStyle = '#ffd700';
    ctx.lineWidth = 3;
    ctx.setLineDash([8, 4]);
    ctx.beginPath();
    ctx.moveTo(pos.x, pos.y - halfSize - 2);
    ctx.lineTo(pos.x + halfSize + 2, pos.y);
    ctx.lineTo(pos.x, pos.y + halfSize + 2);
    ctx.lineTo(pos.x - halfSize - 2, pos.y);
    ctx.closePath();
    ctx.stroke();
    ctx.setLineDash([]);
  },

  renderLegend(){
    const legend = document.getElementById('mapLegend');
    if(!legend) return;
    
    const types = [
      {type: 'crop', label: 'Sawah', color: '#2d5a2d', border: '#4ade80'},
      {type: 'wood', label: 'Hutan', color: '#4a3728', border: '#fb923c'},
      {type: 'stone', label: 'Tambang', color: '#3d3d3d', border: '#9ca3af'},
      {type: 'capital', label: 'Ibukota', color: '#5a2d2d', border: '#ffd700'},
    ];
    
    legend.innerHTML = types.map(t => `
      <div class="legend-item">
        <div class="legend-color" style="background:${t.color}; border-color:${t.border}"></div>
        <span>${t.label}</span>
      </div>
    `).join('');
  },

  // ============================================================
  // MAP INTERACTIONS
  // ============================================================
  getTileFromScreenPos(clientX, clientY){
    const container = document.getElementById('mapContainer');
    const rect = container.getBoundingClientRect();
    const x = clientX - rect.left;
    const y = clientY - rect.top;
    
    const centerX = container.clientWidth / 2;
    const centerY = container.clientHeight / 2;
    
    // Reverse isometric projection
    const relX = (x - centerX - this.mapOffset.x) / this.mapZoom;
    const relY = (y - centerY - this.mapOffset.y) / this.mapZoom;
    
    const tileX = Math.round((relX / (this.tileSize/2) + relY / (this.tileSize/4)) / 2);
    const tileY = Math.round((relY / (this.tileSize/4) - relX / (this.tileSize/2)) / 2);
    
    // Find closest tile
    let closest = null, minDist = Infinity;
    for(const [id, tile] of this.game.land.tiles){
      const dist = Math.abs(tile.x - tileX) + Math.abs(tile.y - tileY);
      if(dist < minDist){
        minDist = dist;
        closest = tile;
      }
    }
    return closest;
  },

  onMapMouseDown(e){
    if(e.button === 1 || e.button === 2){ // Middle or right click = pan
      this.isDragging = true;
      this.lastMousePos = {x: e.clientX, y: e.clientY};
      this.canvas.style.cursor = 'grabbing';
    }
  },

  onMapMouseMove(e){
    if(this.isDragging){
      const dx = e.clientX - this.lastMousePos.x;
      const dy = e.clientY - this.lastMousePos.y;
      this.mapOffset.x += dx;
      this.mapOffset.y += dy;
      this.lastMousePos = {x: e.clientX, y: e.clientY};
      this.renderMap();
    }else{
      // Hover tooltip
      const tile = this.getTileFromScreenPos(e.clientX, e.clientY);
      this.showTooltip(e.clientX, e.clientY, tile);
    }
  },

  onMapMouseUp(){
    this.isDragging = false;
    this.canvas.style.cursor = 'default';
    this.hideTooltip();
  },

  onMapWheel(e){
    e.preventDefault();
    const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
    this.zoomMap(zoomFactor, e.clientX, e.clientY);
  },

  onMapClick(e){
    if(this.isDragging) return;
    const tile = this.getTileFromScreenPos(e.clientX, e.clientY);
    if(tile) this.selectTile(tile.id);
  },

  onTouchStart(e){
    e.preventDefault();
    if(e.touches.length === 1){
      this.isDragging = true;
      this.lastMousePos = {x: e.touches[0].clientX, y: e.touches[0].clientY};
    }else if(e.touches.length === 2){
      // Pinch zoom - simplified
      this.isDragging = false;
    }
  },

  onTouchMove(e){
    e.preventDefault();
    if(this.isDragging && e.touches.length === 1){
      const dx = e.touches[0].clientX - this.lastMousePos.x;
      const dy = e.touches[0].clientY - this.lastMousePos.y;
      this.mapOffset.x += dx;
      this.mapOffset.y += dy;
      this.lastMousePos = {x: e.touches[0].clientX, y: e.touches[0].clientY};
      this.renderMap();
    }
  },

  onTouchEnd(){
    this.isDragging = false;
  },

  zoomMap(factor, centerX=null, centerY=null){
    const oldZoom = this.mapZoom;
    this.mapZoom = Math.max(0.3, Math.min(3, this.mapZoom * factor));
    
    if(centerX !== null && centerY !== null){
      // Zoom towards cursor
      const container = document.getElementById('mapContainer');
      const rect = container.getBoundingClientRect();
      const relX = centerX - rect.left - container.clientWidth / 2;
      const relY = centerY - rect.top - container.clientHeight / 2;
      this.mapOffset.x = relX - (relX - this.mapOffset.x) * (this.mapZoom / oldZoom);
      this.mapOffset.y = relY - (relY - this.mapOffset.y) * (this.mapZoom / oldZoom);
    }
    this.renderMap();
  },

  resetMapView(){
    this.mapZoom = 1;
    this.mapOffset = {x: 0, y: 0};
    this.renderMap();
  },

  showTooltip(clientX, clientY, tile){
    const tooltip = document.getElementById('mapTooltip');
    if(!tile || !tooltip) { tooltip.classList.remove('visible'); return; }
    
    const ownerNames = {player1: 'Anda', enemy: 'Musuh', neutral: 'Netral'};
    const typeNames = {crop: 'Sawah', wood: 'Hutan', stone: 'Tambang', capital: 'Ibukota', plain: 'Dataran'};
    
    tooltip.innerHTML = `
      <h5>${tile.id} - ${typeNames[tile.type] || tile.type} Lv.${tile.level}</h5>
      <div class="tile-info">
        <div>Pemilik: ${ownerNames[tile.owner] || tile.owner}</div>
        <div>Garnisun: ${tile.garrison?.length || 0} unit</div>
        <div>Koordinat: (${tile.x}, ${tile.y})</div>
      </div>
    `;
    
    const container = document.getElementById('mapContainer');
    const rect = container.getBoundingClientRect();
    tooltip.style.left = (clientX - rect.left + 16) + 'px';
    tooltip.style.top = (clientY - rect.top - 80) + 'px';
    tooltip.classList.add('visible');
  },

  hideTooltip(){
    document.getElementById('mapTooltip').classList.remove('visible');
  },

  selectTile(tileId){
    this.selectedTileId = tileId;
    this.renderMap();
    this.updateTileInfo(tileId);
    this.updateActionButtons(tileId);
  },

  // ============================================================
  // UI UPDATES
  // ============================================================
  renderAll(){
    this.updateTopBar();
    this.updateTabs();
    this.renderMap();
    if(this.selectedTileId) this.updateTileInfo(this.selectedTileId);
  },

  updateTopBar(){
    if(!this.game) return;
    
    // Season
    const seasonIcons = {spring: '🌱', summer: '☀️', autumn: '🍂', winter: '❄️'};
    document.getElementById('seasonIcon').textContent = seasonIcons[this.game.season.getSeasonName()] || '🌱';
    document.getElementById('seasonText').textContent = 
      `${this.game.season.getSeasonName().charAt(0).toUpperCase() + this.game.season.getSeasonName().slice(1)} Day ${this.game.season.getDayInSeason()}`;
    
    // Resources
    const res = this.game.resources.getState();
    document.getElementById('resCrop').textContent = this.formatNumber(res.crop);
    document.getElementById('resWood').textContent = this.formatNumber(res.wood);
    document.getElementById('resStone').textContent = this.formatNumber(res.stone);
    
    // Turn
    document.getElementById('turnNum').textContent = this.game.turn;
  },

  updateTabs(){
    this.updateCityTab();
    this.updateTroopsTab();
    this.updateHeroesTab();
    this.updateUnionTab();
    this.updateLogTab();
  },

  updateCityTab(){
    // Production
    const prod = this.game.resources.production;
    document.getElementById('productionList').innerHTML = `
      <div class="prod-item">
        <div class="prod-label">Crop</div>
        <div class="prod-value">${this.formatNumber(this.game.resources.resources.crop)}</div>
        <div class="prod-per-turn">+${prod.crop}/turn</div>
      </div>
      <div class="prod-item">
        <div class="prod-label">Wood</div>
        <div class="prod-value">${this.formatNumber(this.game.resources.resources.wood)}</div>
        <div class="prod-per-turn">+${prod.wood}/turn</div>
      </div>
      <div class="prod-item">
        <div class="prod-label">Stone</div>
        <div class="prod-value">${this.formatNumber(this.game.resources.resources.stone)}</div>
        <div class="prod-per-turn">+${prod.stone}/turn</div>
      </div>
    `;
    
    // Buildings (plots owned)
    const myTiles = this.game.land.getPlayerTiles(this.game.playerId);
    document.getElementById('buildingList').innerHTML = myTiles.map(tile => `
      <div class="building-card">
        <div class="building-info">
          <span class="building-name">${tile.id} - ${this.getTileTypeName(tile.type)}</span>
          <span class="building-level">Level ${tile.level}</span>
          <span class="building-production">${this.getTileProductionText(tile)}</span>
        </div>
        <div class="building-actions">
          ${tile.owner === this.game.playerId && tile.type !== 'capital' ? 
            `<button class="btn-secondary btn-small" onclick="UI.upgradeTile('${tile.id}')">Upgrade</button>` : ''}
        </div>
      </div>
    `).join('') || '<div class="empty-state">Tidak ada bangunan</div>';
    
    // Build options (neutral tiles adjacent to owned)
    const neutralAdjacent = this.getNeutralAdjacentTiles();
    document.getElementById('buildOptions').innerHTML = neutralAdjacent.map(tile => `
      <div class="build-option">
        <div class="build-option-info">
          <span class="build-option-name">${tile.id} - ${this.getTileTypeName(tile.type)} Lv.${tile.level}</span>
          <span class="build-option-cost">Biaya: ${this.getCaptureCost(tile).crop} 🌾</span>
        </div>
        <button class="btn-primary btn-small" onclick="UI.captureTile('${tile.id}')">Kirim Pasukan</button>
      </div>
    `).join('') || '<div class="empty-state">Tidak ada tile yang bisa diserang</div>';
  },

  updateTroopsTab(){
    const troops = this.game.troops.getTroops();
    document.getElementById('troopList').innerHTML = troops.map((troop, idx) => `
      <div class="troop-card">
        <div class="troop-info">
          <span class="troop-name">${troop.name}</span>
          <div class="troop-details">
            <span class="troop-count">Jumlah: ${troop.count}</span>
            <span class="troop-level">Lv.${troop.level}</span>
            ${troop.heroId ? `<span class="troop-hero">Pahlawan: ${this.getHeroName(troop.heroId)}</span>` : ''}
          </div>
        </div>
        <div class="troop-actions">
          <button class="btn-secondary btn-small" onclick="UI.upgradeTroop(${idx})">Naik Lv</button>
          <button class="btn-secondary btn-small" onclick="UI.assignHeroToTroop(${idx})">Pahlawan</button>
        </div>
      </div>
    `).join('') || '<div class="empty-state">Belum ada pasukan</div>';
    
    // Recruit options
    const DATA = global.DATA;
    const soldiers = DATA?.soldiers || [];
    document.getElementById('recruitOptions').innerHTML = soldiers.map(s => `
      <div class="recruit-option">
        <div class="recruit-option-info">
          <span class="recruit-option-name">${s.name} (${s.cat})</span>
          <span class="recruit-option-stats">HP: ${s.hp[0]} ATK: ${s.atkRandom ? s.atkRandom[0]+'-'+s.atkRandom[1] : s.atk[0]} Cost: ${s.crop} 🌾</span>
        </div>
        <button class="btn-primary btn-small" onclick="UI.openRecruitModal(false, '${s.id}')">Rekrut</button>
      </div>
    `).join('');
  },

  updateHeroesTab(){
    const DATA = global.DATA;
    const heroes = DATA?.heroes || [];
    document.getElementById('heroGrid').innerHTML = heroes.slice(0, 20).map(h => `
      <div class="hero-card">
        <div class="hero-name">${h.name}</div>
        <div class="hero-skill">${h.skill || 'Tidak ada skill'}</div>
        <div class="hero-stats">
          <span>HP +${h.hp?h.hp[1]:0}%</span>
          <span>ATK +${h.atk?h.atk[1]:0}%</span>
        </div>
      </div>
    `).join('');
  },

  updateUnionTab(){
    const union = this.game.unions.getPlayerUnion();
    if(union){
      document.getElementById('unionInfo').innerHTML = `
        <div><strong>${union.name}</strong></div>
        <div class="tile-info">Anggota: ${union.members.length}/${global.MAX_UNION_MEMBERS || 50}</div>
        <div class="tile-info">Remains: ${union.remains.length}</div>
        <div class="tile-info">Poin: ${union.points}</div>
      `;
    }
  },

  updateLogTab(){
    const logs = this.game.log.slice(-20).reverse();
    document.getElementById('logContainer').innerHTML = logs.map(entry => `
      <div class="log-entry ${entry.victory ? 'victory' : ''} ${entry.defeated ? 'battle' : ''}">
        [Turn ${entry.turn}] ${entry.season} Day ${entry.day} - 
        🌾${entry.resources.crop} 🪵${entry.resources.wood} 🪨${entry.resources.stone} - 
        Tile: ${entry.tiles} Pasukan: ${entry.troops}
        ${entry.victory ? ` 🏆 ${entry.victory.type}` : ''}
        ${entry.defeated ? ` ☠️ KALAH` : ''}
      </div>
    `).join('');
  },

  updateTileInfo(tileId){
    const tile = this.game.land.tiles.get(tileId);
    if(!tile) return;
    
    const ownerNames = {player1: 'Anda', enemy: 'Musuh', neutral: 'Netral'};
    const typeNames = {crop: 'Sawah', wood: 'Hutan', stone: 'Tambang', capital: 'Ibukota', plain: 'Dataran'};
    
    document.getElementById('selectedTileInfo').innerHTML = `
      <strong>${tile.id}</strong> - ${typeNames[tile.type]} Level ${tile.level} - 
      Pemilik: ${ownerNames[tile.owner]} - Garnisun: ${tile.garrison?.length || 0} unit
    `;
  },

  updateActionButtons(tileId){
    const tile = this.game.land.tiles.get(tileId);
    const container = document.getElementById('actionButtons');
    if(!tile || !container) { container.innerHTML = ''; return; }
    
    const myTroops = this.game.troops.getTroops('city').filter(t => t.count > 0);
    const hasTroops = myTroops.length > 0;
    
    if(tile.owner === 'neutral' || tile.owner === 'enemy'){
      // Attack button
      container.innerHTML = hasTroops ? `
        <button class="action-btn attack" data-action="attack" data-tile-id="${tileId}">
          ⚔️ Serang (${myTroops.length} pasukan)
        </button>
      ` : '<button class="action-btn attack" disabled>⚔️ Serang (butuh pasukan di kota)</button>';
    }else if(tile.owner === 'player1'){
      // Garrison / Upgrade
      container.innerHTML = `
        ${tile.type !== 'capital' ? 
          `<button class="action-btn upgrade" data-action="upgrade" data-tile-id="${tileId}">⬆️ Upgrade Tile</button>` : ''}
        <button class="action-btn garrison" data-action="garrison" data-tile-id="${tileId}">
          🛡️ Pasang Garnisun
        </button>
      `;
    }else{
      container.innerHTML = '';
    }
  },

  // ============================================================
  // ACTIONS
  // ============================================================
  nextTurn(){
    const result = this.game.nextTurn();
    this.showToast(`Turn ${result.turn} - ${result.season.season || result.season.newSeason}`, 'info');
    if(result.season.seasonChanged){
      this.showToast(`Musim berganti ke ${result.season.newSeason}!`, 'success');
    }
    if(result.victory){
      this.showToast(`KEMENANGAN! ${result.victory.type}`, 'success');
    }
    if(result.defeated){
      this.showToast('KALAH! Semua wilayah hilang.', 'error');
    }
    this.renderAll();
  },

  captureTile(tileId){
    const myTroops = this.game.troops.getTroops('city').filter(t => t.count > 0);
    if(myTroops.length === 0){
      this.showToast('Tidak ada pasukan di kota!', 'error');
      return;
    }
    
    // Use first available troop
    const troopIdx = this.game.troops.troops.findIndex(t => t === myTroops[0]);
    const result = this.game.resolveBattle([troopIdx], tileId, tileId, 0);
    
    if(result.success){
      if(result.result.victory === 'player'){
        this.showToast(`Berhasil merebut ${tileId}!`, 'success');
      }else{
        this.showToast(`Gagal merebut ${tileId}!`, 'error');
      }
      this.renderAll();
    }
  },

  upgradeTile(tileId){
    const tile = this.game.land.tiles.get(tileId);
    if(!tile) return;
    
    // In NTA, upgrading a tile means capturing it at higher level or building on it
    // Simplified: just increase level
    tile.level = Math.min(5, tile.level + 1);
    this.showToast(`${tile.id} naik ke Level ${tile.level}`, 'success');
    this.renderAll();
  },

  upgradeTroop(idx){
    const troop = this.game.troops.troops[idx];
    if(!troop) return;
    
    const result = this.game.troops.upgradeTroop(idx, this.game.resources);
    if(result.success){
      this.showToast(`${troop.name} naik Level ${troop.level}`, 'success');
      this.renderAll();
    }else{
      this.showToast(result.reason || 'Gagal naik level', 'error');
    }
  },

  assignHeroToTroop(idx){
    // Simplified - just show toast
    this.showToast('Fitur assign hero: pilih di modal rekrut', 'info');
  },

  handleAction(action, tileId){
    switch(action){
      case 'attack': this.captureTile(tileId); break;
      case 'garrison': this.garrisonTroop(tileId); break;
      case 'upgrade': this.upgradeTile(tileId); break;
    }
  },

  garrisonTroop(tileId){
    this.showToast('Fitur garnisun: drag troop ke tile', 'info');
  },

  // ============================================================
  // MODALS
  // ============================================================
  openRecruitModal(forBattle, soldierId=null){
    const modal = document.getElementById('recruitModal');
    modal.dataset.forBattle = forBattle;
    
    const DATA = global.DATA;
    const soldiers = DATA?.soldiers || [];
    const heroes = DATA?.heroes || [];
    const equipments = DATA?.commonEquipment || [];
    
    // Populate soldier types
    const select = document.getElementById('recruitSoldierType');
    select.innerHTML = soldiers.map(s => 
      `<option value="${s.id}" ${s.id === soldierId ? 'selected' : ''}>${s.name} (${s.cat}) - Cost: ${s.crop} 🌾</option>`
    ).join('');
    
    // Populate heroes
    document.getElementById('recruitHero').innerHTML = 
      '<option value="">Tanpa Pahlawan</option>' +
      heroes.map(h => `<option value="${h.id}">${h.name}</option>`).join('');
    
    // Populate equipment
    document.getElementById('recruitEquip').innerHTML = 
      equipments.map(e => `<option value="${e.id}">${e.name}</option>`).join('');
    
    // Expertise - simplified
    document.getElementById('recruitExpertise').innerHTML = 
      '<option value="">Pilih expertise...</option>';
    
    this.updateRecruitCost();
    modal.classList.remove('hidden');
  },

  updateRecruitCost(){
    const soldierId = document.getElementById('recruitSoldierType').value;
    const count = parseInt(document.getElementById('recruitCount').value) || 1;
    const DATA = global.DATA;
    const soldier = DATA?.soldiers?.find(s => s.id === soldierId);
    
    if(soldier){
      const cost = soldier.crop * count;
      const canAfford = this.game.resources.canAfford({crop: cost});
      document.getElementById('recruitCost').innerHTML = `
        Biaya: ${cost} 🌾 ${canAfford ? '<span style="color:#4ade80">(Mampu)</span>' : '<span style="color:#f87171">(Tidak cukup)</span>'}
      `;
    }
  },

  confirmRecruit(){
    const soldierId = document.getElementById('recruitSoldierType').value;
    const count = parseInt(document.getElementById('recruitCount').value) || 1;
    const heroId = document.getElementById('recruitHero').value || null;
    const equipIds = Array.from(document.getElementById('recruitEquip').selectedOptions).map(o => o.value);
    const expertiseIds = Array.from(document.getElementById('recruitExpertise').selectedOptions).map(o => o.value);
    
    const DATA = global.DATA;
    const soldier = DATA?.soldiers?.find(s => s.id === soldierId);
    
    if(!soldier) return;
    
    const result = this.game.troops.recruit(soldier, count, this.game.resources, heroId, equipIds, expertiseIds);
    
    if(result.success){
      this.showToast(`Berhasil merekrut ${count}x ${soldier.name}!`, 'success');
      this.hideModal('recruitModal');
      this.renderAll();
    }else{
      this.showToast(result.reason || 'Gagal merekrut', 'error');
    }
  },

  showModal(id){
    document.getElementById(id).classList.remove('hidden');
  },

  hideModal(id){
    document.getElementById(id).classList.add('hidden');
  },

  startBattle(){
    // Get selected attacker units
    const attackerUnits = Array.from(document.querySelectorAll('#attackerUnits .battle-unit.selected'))
      .map(el => el.dataset.troopIndex);
    
    if(attackerUnits.length === 0){
      this.showToast('Pilih minimal 1 pasukan penyerang', 'error');
      return;
    }
    
    const tileId = document.getElementById('battleModal').dataset.targetTile;
    if(!tileId) return;
    
    const result = this.game.resolveBattle(attackerUnits.map(i => parseInt(i)), tileId, tileId, 0);
    
    // Show result
    document.getElementById('battleSetup').classList.add('hidden');
    document.getElementById('startBattleBtn').classList.add('hidden');
    document.getElementById('battleResult').classList.remove('hidden');
    
    const outcome = document.getElementById('battleOutcome');
    outcome.textContent = result.result.victory === 'player' ? 'KEMENANGAN' : 'KEKALAHAN';
    outcome.className = result.result.victory === 'player' ? 'victory' : 'defeat';
    
    document.getElementById('battleLog').innerHTML = result.result.log.slice(-10).map(l => 
      `<div>${l}</div>`
    ).join('');
    
    const rewards = result.result.rewards;
    document.getElementById('battleRewards').innerHTML = `
      ${rewards.chests.map(c => `<div class="reward-item">📦 ${c}</div>`).join('')}
      <div class="reward-item">Poin: ${rewards.rewardPoints}</div>
    `;
  },

  hideBattleResult(){
    document.getElementById('battleSetup').classList.remove('hidden');
    document.getElementById('startBattleBtn').classList.remove('hidden');
    document.getElementById('battleResult').classList.add('hidden');
    this.hideModal('battleModal');
    this.renderAll();
  },

  switchTab(tabName){
    document.querySelectorAll('.tab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === tabName);
    });
    document.querySelectorAll('.tab-pane').forEach(pane => {
      pane.classList.toggle('active', pane.id === 'tab' + tabName.charAt(0).toUpperCase() + tabName.slice(1));
    });
  },

  createUnion(){
    const name = prompt('Nama Union:');
    if(name){
      this.game.unions.createUnion('player_union', name, this.game.playerId);
      this.game.unions.setPlayerUnion('player_union');
      this.showToast(`Union "${name}" dibuat!`, 'success');
      this.renderAll();
    }
  },

  // ============================================================
  // UTILITIES
  // ============================================================
  formatNumber(num){
    if(num >= 1000000) return (num/1000000).toFixed(1) + 'M';
    if(num >= 1000) return (num/1000).toFixed(1) + 'K';
    return num.toString();
  },

  getTileTypeName(type){
    const names = {crop: 'Sawah', wood: 'Hutan', stone: 'Tambang', capital: 'Ibukota', plain: 'Dataran'};
    return names[type] || type;
  },

  getTileProductionText(tile){
    const base = {crop: 10, wood: 8, stone: 6};
    const mult = tile.level;
    if(tile.type === 'capital') return '🌾50 🪵30 🪨20';
    return (tile.type === 'crop' ? `🌾${base.crop*mult}` : '') +
           (tile.type === 'wood' ? ` 🪵${base.wood*mult}` : '') +
           (tile.type === 'stone' ? ` 🪨${base.stone*mult}` : '');
  },

  getCaptureCost(tile){
    return {crop: tile.level * 50};
  },

  getHeroName(heroId){
    const DATA = global.DATA;
    const hero = DATA?.heroes?.find(h => h.id === heroId);
    return hero ? hero.name : heroId;
  },

  getNeutralAdjacentTiles(){
    const myTiles = this.game.land.getPlayerTiles(this.game.playerId);
    const adjacent = new Set();
    
    for(const myTile of myTiles){
      for(const [id, tile] of this.game.land.tiles){
        if(tile.owner !== 'neutral') continue;
          // Check if adjacent (Manhattan distance <= 6 - increased from 2 for demo map)
        const dist = Math.abs(tile.x - myTile.x) + Math.abs(tile.y - myTile.y);
          if(dist <= 6) adjacent.add(tile);
      }
    }
    return Array.from(adjacent);
  },

  showToast(message, type='info'){
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
  }
};

// Export
global.UI = UI;

})(typeof window!=="undefined"?window:global);