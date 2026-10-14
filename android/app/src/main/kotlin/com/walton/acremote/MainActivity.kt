package com.walton.acremote

import android.content.Context
import android.hardware.ConsumerIrManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.walton.acremote/ir"
    private var irManager: ConsumerIrManager? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "hasIrEmitter" -> {
                    val hasEmitter = irManager?.hasIrEmitter() ?: false
                    result.success(hasEmitter)
                }
                "getCarrierFrequencies" -> {
                    val manager = irManager
                    if (manager == null || !manager.hasIrEmitter()) {
                        result.success(emptyList<Map<String, Int>>())
                        return@setMethodCallHandler
                    }
                    try {
                        val ranges = manager.carrierFrequencies
                        val list = ranges.map { range ->
                            mapOf("min" to range.minFrequency, "max" to range.maxFrequency)
                        }
                        result.success(list)
                    } catch (e: Exception) {
                        result.error("FREQ_ERROR", e.message, null)
                    }
                }
                "transmit" -> {
                    val manager = irManager
                    if (manager == null) {
                        result.error("NO_IR_SERVICE", "ConsumerIrManager service is not available", null)
                        return@setMethodCallHandler
                    }
                    if (!manager.hasIrEmitter()) {
                        result.error("NO_EMITTER", "Device does not possess an IR emitter", null)
                        return@setMethodCallHandler
                    }

                    val frequency = call.argument<Int>("frequency")
                    val patternList = call.argument<List<Int>>("pattern")

                    if (frequency == null || patternList == null || patternList.isEmpty()) {
                        result.error("INVALID_ARGS", "Frequency and pattern array are required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val pattern = patternList.toIntArray()
                        manager.transmit(frequency, pattern)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("TRANSMIT_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
