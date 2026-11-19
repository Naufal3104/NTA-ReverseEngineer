
// Debug script to test the game initialization
window.onload = function() {
  setTimeout(function() {
    // Check if game is initialized
    if (typeof Game !== 'undefined' && typeof UI !== 'undefined') {
      console.log('Game and UI are loaded');
      
      // Create game state
      const gs = new Game.GameState();
      console.log('Game state created');
      console.log('Tiles:', gs.land.tiles.size);
      
      // Get first tile
      const tiles = Array.from(gs.land.tiles.values());
      if (tiles.length > 0) {
        console.log('First tile:', tiles[0].id, 'pos:', tiles[0].x, tiles[0].y, 'owner:', tiles[0].owner);
      }
      
      // Initialize UI
      UI.init(gs);
      console.log('UI initialized');
      
      // Check canvas
      const canvas = document.getElementById('mapCanvas');
      console.log('Canvas dimensions:', canvas.width, canvas.height);
      
      // Check container
      const container = document.getElementById('mapContainer');
      console.log('Container dimensions:', container.clientWidth, container.clientHeight);
      
      // Render map
      UI.renderMap();
      console.log('Map rendered');
      
      // Check neutral adjacent
      const neutrals = UI.getNeutralAdjacentTiles();
      console.log('Neutral adjacent tiles:', neutrals.length);
    } else {
      console.log('Game or UI not loaded');
      console.log('Game:', typeof Game);
      console.log('UI:', typeof UI);
    }
  }, 100);
};
