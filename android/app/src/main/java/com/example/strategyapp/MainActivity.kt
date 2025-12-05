package com.example.strategyapp

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ایجاد کانال‌های نوتیفیکیشن
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NotificationManager::class.java)

            val serviceChannel = NotificationChannel(
                "strategy_channel",
                "Strategy Service",
                NotificationManager.IMPORTANCE_LOW
            )
            nm.createNotificationChannel(serviceChannel)

            val alertsChannel = NotificationChannel(
                "alerts",
                "Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                enableLights(true)
                lightColor = Color.GREEN
                enableVibration(true)
                setSound(
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .build()
                )
            }
            nm.createNotificationChannel(alertsChannel)
        }

        // انتخاب کاربر: یک جفت‌ارز و تایم‌فریم
        val symbol = "BTCUSDT"
        val timeframe = "5m"

        val intent = Intent(this, StrategyService::class.java).apply {
            putExtra("symbol", symbol)
            putExtra("timeframe", timeframe)
        }
        ContextCompat.startForegroundService(this, intent)
    }
}
