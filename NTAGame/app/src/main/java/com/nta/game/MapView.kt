package com.nta.game

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PointF
import android.util.AttributeSet
import android.util.Log
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import android.view.ViewTreeObserver
import java.util.Random

class MapView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    // Tile configuration - 6x6 grid with isometric diamond tiles
    private val TILE_WIDTH = 80f  // Diamond width
    private val TILE_HEIGHT = 40f // Diamond height
    private val GRID_SIZE = 6
    
    // Camera/transform
    private var scale = 1.0f
    private var offsetX = 0f
    private var offsetY = 0f
    private val minScale = 0.5f
    private val maxScale = 3.0f
    
    // Game data
    private val tiles = mutableListOf<MapTile>()
    private val playerCapital = PointF(2f, 0f)  // col 2, row 0 (top)
    private val enemyCapital = PointF(3f, 5f)   // col 3, row 5 (bottom)
    private val random = Random()
    
    // Paint objects
    private val tilePaint = Paint().apply { style = Paint.Style.FILL; isAntiAlias = true }
    private val tileBorderPaint = Paint().apply { style = Paint.Style.STROKE; strokeWidth = 2f; isAntiAlias = true; color = Color.WHITE }
    private val capitalPaint = Paint().apply { style = Paint.Style.FILL; isAntiAlias = true }
    private val textPaint = Paint().apply { textSize = 14f; isAntiAlias = true; color = Color.WHITE; textAlign = Paint.Align.CENTER }
    private val debugPaint = Paint().apply { textSize = 10f; isAntiAlias = true; color = Color.YELLOW; textAlign = Paint.Align.CENTER }
    
    // Touch handling
    private val gestureDetector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onScroll(e1: MotionEvent, e2: MotionEvent, distanceX: Float, distanceY: Float): Boolean {
                offsetX -= distanceX
                offsetY -= distanceY
                invalidate()
                return true
            }
        
            override fun onDown(e: MotionEvent): Boolean = true
    })
    
    private val scaleGestureDetector = ScaleGestureDetector(context, object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
            override fun onScale(detector: ScaleGestureDetector): Boolean {
                val newScale = (scale * detector.scaleFactor).coerceIn(minScale, maxScale)
                // Scale around the focal point
                val focusX = detector.focusX
                val focusY = detector.focusY
                offsetX = focusX - (focusX - offsetX) * (newScale / scale)
                offsetY = focusY - (focusY - offsetY) * (newScale / scale)
                scale = newScale
                invalidate()
                return true
            }
    })

    init {
                Log.d("NTA", "MapView init called")
                generateMap()
                Log.d("NTA", "MapView init done, tiles: ${tiles.size}")
                // Force layout and draw
                setWillNotDraw(false)
                isClickable = true
                // Force hardware acceleration
                setLayerType(LAYER_TYPE_HARDWARE, null)
                // Set background to verify drawing
                setBackgroundColor(Color.BLACK)
            }
    
    private fun generateMap() {
            tiles.clear()
        
            // Generate 6x6 grid with randomized terrain
            for (row in 0 until GRID_SIZE) {
                for (col in 0 until GRID_SIZE) {
                    val isPlayerCapital = (col == playerCapital.x.toInt() && row == playerCapital.y.toInt())
                    val isEnemyCapital = (col == enemyCapital.x.toInt() && row == enemyCapital.y.toInt())
                
                    var tileType: TileType
                    if (isPlayerCapital) {
                        tileType = TileType.PLAYER_CAPITAL
                    } else if (isEnemyCapital) {
                        tileType = TileType.ENEMY_CAPITAL
                    } else {
                        // Randomize terrain for other tiles
                        tileType = when (random.nextInt(100)) {
                            in 0..29 -> TileType.PLAIN
                            in 30..49 -> TileType.FOREST
                            in 50..64 -> TileType.MOUNTAIN
                            in 65..74 -> TileType.RIVER
                            in 75..84 -> TileType.VILLAGE
                            else -> TileType.FORTRESS
                        }
                    }
                
                    val tile = MapTile(col.toFloat(), row.toFloat(), tileType)
                    tiles.add(tile)
                }
            }
    }

    override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
                Log.d("NTA", "onDraw called: width=${width}, height=${height}, scale=$scale, offsetX=$offsetX, offsetY=$offsetY, tiles=${tiles.size}, visibility=${visibility}")
        
                if (width == 0 || height == 0) {
                    Log.w("NTA", "onDraw: View has zero size, skipping draw")
                    return
                }
        
                    // Clear background
                    canvas.drawColor(Color.rgb(20, 40, 60))
                
                    canvas.save()
                    canvas.translate(offsetX, offsetY)
                    canvas.scale(scale, scale)
        
                    // Calculate center offset for 6x6 grid
                    val centerX = width / 2f / scale
                    val centerY = height / 2f / scale
                    val gridStartX = centerX - (GRID_SIZE * TILE_WIDTH / 2f)
                    val gridStartY = centerY - (GRID_SIZE * TILE_HEIGHT / 2f)
        
                    Log.d("NTA", "Drawing grid: centerX=$centerX, centerY=$centerY, gridStartX=$gridStartX, gridStartY=$gridStartY")
                
                    // Debug: log first few tile positions
                    if (tiles.size > 0) {
                        val firstTile = tiles[0]
                        val isoX = (firstTile.col - firstTile.row) * (TILE_WIDTH / 2f)
                        val isoY = (firstTile.col + firstTile.row) * (TILE_HEIGHT / 2f)
                        Log.d("NTA", "First tile (0,0): isoX=$isoX, isoY=$isoY, screenX=${gridStartX + isoX + TILE_WIDTH/2}, screenY=${gridStartY + isoY + TILE_HEIGHT/2}")
                    
                        val lastTile = tiles[tiles.size - 1]
                        val isoX2 = (lastTile.col - lastTile.row) * (TILE_WIDTH / 2f)
                        val isoY2 = (lastTile.col + lastTile.row) * (TILE_HEIGHT / 2f)
                        Log.d("NTA", "Last tile (${lastTile.col},${lastTile.row}): isoX=$isoX2, isoY=$isoY2, screenX=${gridStartX + isoX2 + TILE_WIDTH/2}, screenY=${gridStartY + isoY2 + TILE_HEIGHT/2}")
                    }
        
                    // Draw all tiles
                    for (tile in tiles) {
                        drawTile(canvas, tile, gridStartX, gridStartY)
                    }
        
                    canvas.restore()
        
                    // Draw debug info
                    canvas.drawText("Scale: ${String.format("%.2f", scale)}", 50f, 50f, debugPaint)
                    canvas.drawText("Offset: ${offsetX.toInt()}, ${offsetY.toInt()}", 50f, 70f, debugPaint)
                    canvas.drawText("Tiles: ${tiles.size}", 50f, 90f, debugPaint)
                }
                
                canvas.save()
                canvas.translate(offsetX, offsetY)
                canvas.scale(scale, scale)
        
                // Calculate center offset for 6x6 grid
                val centerX = width / 2f / scale
                val centerY = height / 2f / scale
                val gridStartX = centerX - (GRID_SIZE * TILE_WIDTH / 2f)
                val gridStartY = centerY - (GRID_SIZE * TILE_HEIGHT / 2f)
        
                Log.d("NTA", "Drawing grid: centerX=$centerX, centerY=$centerY, gridStartX=$gridStartX, gridStartY=$gridStartY")
                
                // Debug: log first few tile positions
                if (tiles.size > 0) {
                    val firstTile = tiles[0]
                    val isoX = (firstTile.col - firstTile.row) * (TILE_WIDTH / 2f)
                    val isoY = (firstTile.col + firstTile.row) * (TILE_HEIGHT / 2f)
                    Log.d("NTA", "First tile (0,0): isoX=$isoX, isoY=$isoY, screenX=${gridStartX + isoX + TILE_WIDTH/2}, screenY=${gridStartY + isoY + TILE_HEIGHT/2}")
                    
                    val lastTile = tiles[tiles.size - 1]
                    val isoX2 = (lastTile.col - lastTile.row) * (TILE_WIDTH / 2f)
                    val isoY2 = (lastTile.col + lastTile.row) * (TILE_HEIGHT / 2f)
                    Log.d("NTA", "Last tile (${lastTile.col},${lastTile.row}): isoX=$isoX2, isoY=$isoY2, screenX=${gridStartX + isoX2 + TILE_WIDTH/2}, screenY=${gridStartY + isoY2 + TILE_HEIGHT/2}")
                }
        
                // Draw all tiles
                for (tile in tiles) {
                    drawTile(canvas, tile, gridStartX, gridStartY)
                }
        
                canvas.restore()
        
                // Draw debug info
                canvas.drawText("Scale: ${String.format("%.2f", scale)}", 50f, 50f, debugPaint)
                canvas.drawText("Offset: ${offsetX.toInt()}, ${offsetY.toInt()}", 50f, 70f, debugPaint)
                canvas.drawText("Tiles: ${tiles.size}", 50f, 90f, debugPaint)
            }
    
    private fun drawTile(canvas: Canvas, tile: MapTile, startX: Float, startY: Float) {
            // Isometric projection: convert grid (col, row) to screen coordinates
            // isoX = (col - row) * (TILE_WIDTH / 2)
            // isoY = (col + row) * (TILE_HEIGHT / 2)
            val isoX = (tile.col - tile.row) * (TILE_WIDTH / 2f)
            val isoY = (tile.col + tile.row) * (TILE_HEIGHT / 2f)
        
            val screenX = startX + isoX
            val screenY = startY + isoY
        
            // Diamond points
            val centerX = screenX + TILE_WIDTH / 2f
            val centerY = screenY + TILE_HEIGHT / 2f
        
            val path = android.graphics.Path().apply {
                moveTo(centerX, centerY - TILE_HEIGHT / 2f)  // Top
                lineTo(centerX + TILE_WIDTH / 2f, centerY)   // Right
                lineTo(centerX, centerY + TILE_HEIGHT / 2f)  // Bottom
                lineTo(centerX - TILE_WIDTH / 2f, centerY)   // Left
                close()
            }
        
            // Set tile color based on type
            tilePaint.color = when (tile.type) {
                TileType.PLAIN -> Color.rgb(100, 180, 100)
                TileType.FOREST -> Color.rgb(60, 140, 60)
                TileType.MOUNTAIN -> Color.rgb(120, 120, 120)
                TileType.RIVER -> Color.rgb(60, 100, 200)
                TileType.VILLAGE -> Color.rgb(180, 160, 80)
                TileType.FORTRESS -> Color.rgb(140, 80, 80)
                TileType.PLAYER_CAPITAL -> Color.rgb(60, 120, 220)
                TileType.ENEMY_CAPITAL -> Color.rgb(220, 60, 60)
            }
        
            canvas.drawPath(path, tilePaint)
            canvas.drawPath(path, tileBorderPaint)
        
            // Draw tile label
            val label = when (tile.type) {
                TileType.PLAYER_CAPITAL -> "★"
                TileType.ENEMY_CAPITAL -> "★"
                else -> "${tile.col.toInt()},${tile.row.toInt()}"
            }
            canvas.drawText(label, centerX, centerY + 5f, textPaint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
            scaleGestureDetector.onTouchEvent(event)
            gestureDetector.onTouchEvent(event)
            return true
    }
    
    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
            super.onSizeChanged(w, h, oldw, oldh)
                Log.d("NTA", "onSizeChanged: w=$w, h=$h, oldw=$oldw, oldh=$oldh")
                // Center the grid initially
                offsetX = w / 2f
                offsetY = h / 2f
                Log.d("NTA", "onSizeChanged: offsetX=$offsetX, offsetY=$offsetY")
                // Force a draw after size is set
                postInvalidate()
            }
    
    // Public method to regenerate map (for testing randomization)
    fun regenerateMap() {
            generateMap()
            invalidate()
    }
}

data class MapTile(
    val col: Float,
    val row: Float,
    val type: TileType
)

enum class TileType {
    PLAIN, FOREST, MOUNTAIN, RIVER, VILLAGE, FORTRESS,
    PLAYER_CAPITAL, ENEMY_CAPITAL
}