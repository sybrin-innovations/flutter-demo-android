package com.example.flutter_sybrin_demo

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.sybrin.identity.SybrinIdentity
import com.sybrin.identity.SybrinIdentityConfiguration
import com.sybrin.identity.enums.Document

import com.sybrin.facecomparison.SybrinFacialComparison
import com.sybrin.facecomparison.SybrinFacialComparisonConfiguration
import com.sybrin.livenessdetection.SybrinLivenessDetection
import com.sybrin.livenessdetection.SybrinLivenessDetectionConfiguration


class MainActivity: FlutterActivity() {
     private val CHANNEL = "com.example.flutter_sybrin_demo/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanDocument" -> {
                    val license: String? = call.argument("license")
                    if (license != null) {
                        scanDocument(license, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "License and Environment Key required", null)
                    }
                }

                "liveness" -> {
                    val license: String? = call.argument("license")
                    if (license != null) {
                        faceCompare(license, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "License and Environment Key required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scanDocument(license: String, result: MethodChannel.Result) {
        val license2 = "W9QMhtqRNzf9Rrm3g400vzClydbPb9y04CzPy09OA6nqqFJ7qHitGR5hFEOgDIQIB0ivEwuZpRvwACRe/ELTEItJYQGCHCCgBwkKgpByVtj+EMnog3fRuWs7mlKfsZPiRkHvZkrmVqXBPk5rzoTXfHreK9phoxa2xqGve3tRQ7H8NgtjoCmH7d93AeFQrRFzVsqOuOA9R6b3jZegIXUdyLf0ZVx79vSzLWsSgluPpMGDo0eC6qWOEgot+CoseiDpzKGwChbjH8b5HpAJDUUjpcQh1GRPXgW3izeKeTs27U0f+2Pn5YN1VhKQN1neWVMPwIemUUs6+ycCuQk7sX8k/+TqfJ/F02/pMM2gbCR19UhT5ByNMoBq8/cdnXaWV1Bz6+jq+xSn4zGcC5G4nuU1JIo7QFolOH2v6FN9hEpAISpJw+4WBYZbNJeZRLfa3QoECzubX2Mx+A8wbqrYjgugDm1PdcZSM5NXmASlq7RfcOmiWrMbvqTy9LEXAv3zv4zX"
        //val license2 = "W9QMhtqRNzf9Rrm3g400vzClydbPb9y04CzPy09OA6nqqFJ7qHitGR5hFEOgDIQICI2hwRY+qYyS6K3OS13rQMQ1MeW8kFvead3GS7eVCiBHD6gMzo3DuZI6WQL174Gobgkhux5rKFngufNMbAsa07lkyk9r9mUo049pWYW/k60Ps+6pV5wR821DaEIYQ2Q7jkcCTYbXMEqNPqd68MBCcb3kJonoYVro5cv1O4UcdBIuXGUHi5wZHury4W76T9OndhLHpwgstE+rpIGo1FldWfanq9z9NUBy5FNmXh59Ir8Vk9AI5X2RMrzaCQ/EgcAAHvS0NbaMklMjtNDDY2Ga2He7Y8uz9Ch0jdbtYMbG9jAg50K4L+4z1hDNIKtf7e6UClm3v9+fe0xBKWCs/9g7p0v0US2HWB8KXHVq41kLlUlvIEJPuGo3dJIcd+LAsnqZOIzAZFHqF7q0UqY/jA17Ww5oZpmT0EJLRF/Nz9CdVluOY1he9uBxAUU111BPxWXE"
        val config = SybrinIdentityConfiguration.Builder(license2)
            //.setEnvironmentKey(environmentKey)
            .build()

        val sybrinIdentity = SybrinIdentity.getInstance(this, config)
        sybrinIdentity.scanDocument(Document.SouthAfricaPassport)
            .addOnSuccessListener { scanResult ->
                result.success(scanResult)
            }
            .addOnFailureListener { error ->
                result.error("SCAN_FAILED", error.message, null)
            }
            .addOnCancelListener {
                result.error("SCAN_CANCELLED", "Scan was cancelled", null)
            }
    }

    private fun faceCompare(license: String, result: MethodChannel.Result) {
        val license2 = "W9QMhtqRNzf9Rrm3g400vzClydbPb9y04CzPy09OA6nqqFJ7qHitGR5hFEOgDIQIogOOs9t8oBr/lcdsDFWkcEInc7CEDdTFKvFy9PxHUqZB2yptypxAtyuX7OP5K2XTYjoQiNC1IkEA0gcBUf/3CGTPhpZGor64vuyjeW0OKWXSthWKR3znAXLp5zAkPjNK/d7BpV0uQg1+JbM9dRqcF6sQXzVTaGOLjctYQyKxbqkHrVe/VaPd4DvGeGzcJleQS0T5ihioP+VIYy1x7PEAOFhXhq5FHZ7u/0wQszvncn5QC4V6BnG77cusg86/mHTaBsQv0gbWCCSiuVcsF3E7VMdExLRzcc7n7INZ5fognOgd8HcYea0RTLrf7gn5sbI6m5/DKC6nJcMyb8hBfaYgdi2Ur5Ln/DReGfHf7a+4AJjLVR8TK+pVDiJFK/VjPj9wrC3UPgaNg7TbGfMGKHgu/7uduCUFAp/HRT4qw5af5aLGM3dAsA4yt62zvzUpDKa0"
        //val license2 = "W9QMhtqRNzf9Rrm3g400vzClydbPb9y04CzPy09OA6nqqFJ7qHitGR5hFEOgDIQIM6xqG/uTaw8ML/MLlPot3j3j0cS33FRS/C04N5jxciM0EHsdF8Jaf59q5vOncX01zgYdBSjXXGIW/KLuQHdhj/NIwow2ah9mF7sdAZI9uW2lGQ7M89Ayd69pNVG+tJHCARLGlFOSNmuNF5dw/wrLDWYTW2rE5Z/t5fWqYZR0X1D+18ZfpMwZsjOr/6PGYK/HqdQkhb7NtGZO/1/+YSLZhfG6YCfu+uyxoFX7Ept3Ji2jgci9UF3J7fsTmOOpYNOZ3oxxKxlKZZw3HZ2BfuqT4RtIcKco7RNoEpBoCEkRk8ufjHYCGwysEHGkGPN1ljduJif+P1IBkqISyoIj1Gh6l8rqiMBjmIyEJfk5BlAmdJAEx5GtJrmIqQGw59WFM/m3oueZGk+vD5TUgfM5gD7GFjEZ8ULC/MdYaAUlD2GDiKPMstBaS5y7ytSUG8nVwrpL"
        val sldc = SybrinLivenessDetectionConfiguration.Builder(license2)
        //.setEnvironmentKey(mEnvironmentKey)
        .build()

        val sld = SybrinLivenessDetection.getInstance(this@MainActivity, sldc)

        sld.openPassiveLivenessDetection()
            .addOnSuccessListener { result ->
                val sfc = SybrinFacialComparisonConfiguration.Builder(license2)
//                    .setEnvironmentKey(mEnvironmentKey)
                    .build()

                val sf = SybrinFacialComparison.getInstance(this@MainActivity, sfc)
                sf.compareFaces(result.selfieImage, arrayOf(result.croppedSelfieImage))
                    .addOnSuccessListener {
                        println("success")
                    }
                    .addOnFailureListener {
                        println("Failed")
                    }
                println("Succeeded")
            }
            .addOnFailureListener {
                println("Failed")
            }
            .addOnCancelListener {
                println("Canceled")
            }
    }
}
