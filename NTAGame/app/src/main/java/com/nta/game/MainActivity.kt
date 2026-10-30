package com.nta.game

import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        Log.d("NTA", "MainActivity onCreate")
        
        // Request window focus to prevent MIUI from backgrounding us
        window.addFlags(
            android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            android.view.WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        
        // Force the window to be drawn
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
            View.SYSTEM_UI_FLAG_FULLSCREEN
        )
        
        val rootView = findViewById<FrameLayout>(R.id.rootLayout)
        rootView.viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                Log.d("NTA", "Layout complete: w=${rootView.width}, h=${rootView.height}")
                Log.d("NTA", "Root layout visibility: ${rootView.visibility}")
                rootView.viewTreeObserver.removeOnGlobalLayoutListener(this)
            }
        })
    }
    
    override fun onResume() {
        super.onResume()
        Log.d("NTA", "MainActivity onResume")
        // Force invalidate to ensure drawing
        val mapView = findViewById<com.nta.game.MapView>(R.id.mapView)
        if (mapView != null) {
            mapView.postInvalidate()
        }
    }
}
