package com.example.smartparkingproximitysensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.util.Log
import com.android.volley.Request
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.Volley
import org.json.JSONObject

class MainActivity : AppCompatActivity() {

    private lateinit var sensorManager: SensorManager
    private var proximitySensor: Sensor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize SensorManager and Proximity Sensor
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)

        if (proximitySensor != null) {
            sensorManager.registerListener(proximitySensorListener, proximitySensor, SensorManager.SENSOR_DELAY_NORMAL)
        } else {
            Log.d("ProximitySensor", "No Proximity Sensor found!")
        }
    }

    // SensorEventListener to monitor proximity changes
    private val proximitySensorListener = object : SensorEventListener {
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

        override fun onSensorChanged(event: SensorEvent) {
            val isOccupied = event.values[0] < proximitySensor!!.maximumRange // Close object detected
            sendAvailabilityStatusToApi(isOccupied)
        }
    }

    private fun sendAvailabilityStatusToApi(isOccupied: Boolean) {
        val url = "http://52.53.253.65:5000/parking/status" // Replace with your actual API URL
        val jsonBody = JSONObject().apply {
            put("isOccupied", isOccupied)
        }

        val request = JsonObjectRequest(Request.Method.POST, url, jsonBody,
            { response -> Log.d("API", "Response: $response") },
            { error -> Log.d("API", "Error: $error") })

        Volley.newRequestQueue(this).add(request)
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(proximitySensorListener)
    }
}