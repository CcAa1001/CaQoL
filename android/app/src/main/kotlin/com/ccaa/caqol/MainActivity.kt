package com.ccaa.caqol

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import com.gdelataillade.alarm.alarm.AlarmReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ACTION_CAQOL_ALARM_CLOCK = "com.ccaa.caqol.ACTION_ALARM_CLOCK"
        private const val EXTRA_CAQOL_ALARM_ID = "caqol_alarm_id"
    }

    private var previousMusicVolume: Int? = null
    private var previousAlarmVolume: Int? = null
    private var previousSpeakerphoneOn: Boolean? = null
    private var previousAudioMode: Int? = null
    private var previousInterruptionFilter: Int? = null
    private var alarmAudioBoostEnabled = false
    private var pendingLaunchedAlarmId: Int? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureAlarmLaunchIntent(intent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureAlarmLaunchIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "caqol/alarm_permissions")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canScheduleExactAlarms" -> result.success(canScheduleExactAlarms())
                    "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent())
                    "areNotificationsEnabled" -> result.success(areNotificationsEnabled())
                    "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())
                    "hasNotificationPolicyAccess" -> result.success(hasNotificationPolicyAccess())
                    "getManufacturer" -> result.success(Build.MANUFACTURER)
                    "openExactAlarmSettings" -> {
                        openExactAlarmSettings()
                        result.success(null)
                    }
                    "openFullScreenIntentSettings" -> {
                        openFullScreenIntentSettings()
                        result.success(null)
                    }
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    "openBatteryOptimizationSettings" -> {
                        openBatteryOptimizationSettings()
                        result.success(null)
                    }
                    "openDoNotDisturbSettings" -> {
                        openDoNotDisturbSettings()
                        result.success(null)
                    }
                    "openAutostartSettings" -> {
                        openAutostartSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "caqol/alarm_audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAlarmAudioStatus" -> result.success(getAlarmAudioStatus())
                    "enableAlarmAudioBoost" -> {
                        enableAlarmAudioBoost()
                        result.success(null)
                    }
                    "reinforceAlarmAudio" -> {
                        val activeAlarmCount = call.argument<Int>("activeAlarmCount") ?: 1
                        val ringSeconds = call.argument<Int>("ringSeconds") ?: 0
                        reinforceAlarmAudio(activeAlarmCount, ringSeconds)
                        result.success(null)
                    }
                    "restoreAlarmAudioIfIdle" -> {
                        restoreAlarmAudioIfIdle()
                        result.success(null)
                    }
                    "openAlarmSoundSettings" -> {
                        openAlarmSoundSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "caqol/alarm_clock")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarmClock" -> {
                        val status = scheduleAlarmClock(
                            id = call.argument<Int>("id") ?: 0,
                            triggerAtMillis = call.argument<Long>("millisecondsSinceEpoch") ?: 0L,
                            assetAudioPath = call.argument<String>("assetAudioPath") ?: "assets/alarm.mp3",
                            loopAudio = call.argument<Boolean>("loopAudio") ?: true,
                            vibrate = call.argument<Boolean>("vibrate") ?: true,
                            volume = call.argument<Double>("volume") ?: 1.0,
                            volumeEnforced = call.argument<Boolean>("volumeEnforced") ?: true,
                            fadeDuration = call.argument<Double>("fadeDuration") ?: 0.0,
                            fullScreenIntent = call.argument<Boolean>("fullScreenIntent") ?: true,
                            notificationTitle = call.argument<String>("notificationTitle") ?: "Alarm",
                            notificationBody = call.argument<String>("notificationBody")
                                ?: "Wake up now. Open CaQoL to stop this alarm.",
                            notificationStopButton = call.argument<String>("notificationStopButton")
                        )
                        result.success(status)
                    }
                    "startLockTask" -> {
                        try {
                            startLockTask()
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("LOCK_TASK_FAILED", e.message, null)
                        }
                    }
                    "stopLockTask" -> {
                        try {
                            stopLockTask()
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("UNLOCK_TASK_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "caqol/alarm_launch")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumeLaunchedAlarmId" -> {
                        val id = pendingLaunchedAlarmId
                        pendingLaunchedAlarmId = null
                        result.success(id)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun captureAlarmLaunchIntent(intent: Intent?) {
        if (intent?.action == ACTION_CAQOL_ALARM_CLOCK) {
            val id = intent.getIntExtra(EXTRA_CAQOL_ALARM_ID, 0)
            if (id != 0) {
                pendingLaunchedAlarmId = id
            }
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = getSystemService(AlarmManager::class.java)
        return alarmManager?.canScheduleExactAlarms() == true
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        val notificationManager = getSystemService(NotificationManager::class.java)
        return notificationManager?.canUseFullScreenIntent() == true
    }

    private fun areNotificationsEnabled(): Boolean {
        val notificationManager = getSystemService(NotificationManager::class.java)
        return notificationManager?.areNotificationsEnabled() == true
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(PowerManager::class.java)
        return powerManager?.isIgnoringBatteryOptimizations(packageName) == true
    }

    private fun hasNotificationPolicyAccess(): Boolean {
        val notificationManager = getSystemService(NotificationManager::class.java)
        return notificationManager?.isNotificationPolicyAccessGranted == true
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            startActivity(
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            return
        }

        openAppDetailsSettings()
    }

    private fun openFullScreenIntentSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivity(
                Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                    data = Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            return
        }

        startActivity(
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    private fun openNotificationSettings() {
        startActivity(
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    private fun openBatteryOptimizationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            startActivity(
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            return
        }

        openAppDetailsSettings()
    }

    private fun openDoNotDisturbSettings() {
        startActivity(
            Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    private fun getAlarmAudioStatus(): Map<String, Any> {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return mapOf(
            "alarmVolume" to audioManager.getStreamVolume(AudioManager.STREAM_ALARM),
            "alarmMaxVolume" to audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
            "musicVolume" to audioManager.getStreamVolume(AudioManager.STREAM_MUSIC),
            "musicMaxVolume" to audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
            "doNotDisturbAccessAllowed" to hasNotificationPolicyAccess()
        )
    }

    private fun enableAlarmAudioBoost() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (!alarmAudioBoostEnabled) {
            previousMusicVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            previousAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
            previousSpeakerphoneOn = audioManager.isSpeakerphoneOn
            previousAudioMode = audioManager.mode
            if (hasNotificationPolicyAccess()) {
                val notificationManager = getSystemService(NotificationManager::class.java)
                previousInterruptionFilter = notificationManager?.currentInterruptionFilter
            }
        }
        alarmAudioBoostEnabled = true
        forceAlarmAudio(audioManager)
    }

    private fun reinforceAlarmAudio(activeAlarmCount: Int, ringSeconds: Int) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (!alarmAudioBoostEnabled) {
            enableAlarmAudioBoost()
            return
        }
        forceAlarmAudio(audioManager)
        if (activeAlarmCount > 1 || ringSeconds >= 45) {
            audioManager.isSpeakerphoneOn = true
        }
    }

    private fun forceAlarmAudio(audioManager: AudioManager) {
        val maxAlarmVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        val maxMusicVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        audioManager.mode = AudioManager.MODE_NORMAL
        audioManager.isSpeakerphoneOn = true
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarmVolume, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxMusicVolume, 0)
        if (hasNotificationPolicyAccess()) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
        }
    }

    private fun restoreAlarmAudioIfIdle() {
        if (!alarmAudioBoostEnabled) {
            return
        }
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        previousAlarmVolume?.let {
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, it, 0)
        }
        previousMusicVolume?.let {
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, it, 0)
        }
        previousAudioMode?.let {
            audioManager.mode = it
        }
        previousSpeakerphoneOn?.let {
            audioManager.isSpeakerphoneOn = it
        }
        if (hasNotificationPolicyAccess()) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            previousInterruptionFilter?.let {
                notificationManager?.setInterruptionFilter(it)
            }
        }
        previousMusicVolume = null
        previousAlarmVolume = null
        previousSpeakerphoneOn = null
        previousAudioMode = null
        previousInterruptionFilter = null
        alarmAudioBoostEnabled = false
    }

    private fun openAlarmSoundSettings() {
        startActivity(
            Intent(Settings.ACTION_SOUND_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    private fun scheduleAlarmClock(
        id: Int,
        triggerAtMillis: Long,
        assetAudioPath: String,
        loopAudio: Boolean,
        vibrate: Boolean,
        volume: Double,
        volumeEnforced: Boolean,
        fadeDuration: Double,
        fullScreenIntent: Boolean,
        notificationTitle: String,
        notificationBody: String,
        notificationStopButton: String?
    ): Map<String, Any> {
        val exactAllowed = canScheduleExactAlarms()
        if (id == 0 || triggerAtMillis <= System.currentTimeMillis()) {
            return mapOf(
                "scheduled" to false,
                "exactAlarmAllowed" to exactAllowed,
                "reason" to "invalid_alarm_time",
                "manufacturer" to Build.MANUFACTURER
            )
        }

        if (!exactAllowed) {
            return mapOf(
                "scheduled" to false,
                "exactAlarmAllowed" to false,
                "reason" to "exact_alarm_permission_denied",
                "manufacturer" to Build.MANUFACTURER
            )
        }

        val alarmIntent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("assetAudioPath", assetAudioPath)
            putExtra("loopAudio", loopAudio)
            putExtra("vibrate", vibrate)
            putExtra("volume", volume)
            putExtra("volumeEnforced", volumeEnforced)
            putExtra("fadeDuration", fadeDuration)
            putExtra("fullScreenIntent", fullScreenIntent)
            putExtra(
                "notificationSettings",
                buildNotificationSettingsJson(
                    notificationTitle,
                    notificationBody,
                    notificationStopButton
                )
            )
        }
        val serviceOperation = PendingIntent.getBroadcast(
            this,
            id,
            alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_CAQOL_ALARM_CLOCK
            putExtra(EXTRA_CAQOL_ALARM_ID, id)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
        }
        val launchOperation = PendingIntent.getActivity(
            this,
            id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return mapOf(
                "scheduled" to false,
                "exactAlarmAllowed" to exactAllowed,
                "reason" to "alarm_manager_unavailable",
                "manufacturer" to Build.MANUFACTURER
            )
        var serviceAlarmSet = true
        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                serviceOperation
            )
        } catch (error: SecurityException) {
            // setAlarmClock below is the more important fallback on Android 12+.
            serviceAlarmSet = false
        }
        return try {
            alarmManager.setAlarmClock(
                AlarmManager.AlarmClockInfo(triggerAtMillis, launchOperation),
                launchOperation
            )
            mapOf(
                "scheduled" to true,
                "exactAlarmAllowed" to exactAllowed,
                "serviceAlarmSet" to serviceAlarmSet,
                "alarmClockSet" to true,
                "manufacturer" to Build.MANUFACTURER
            )
        } catch (error: SecurityException) {
            mapOf(
                "scheduled" to false,
                "exactAlarmAllowed" to exactAllowed,
                "serviceAlarmSet" to serviceAlarmSet,
                "alarmClockSet" to false,
                "reason" to "security_exception",
                "manufacturer" to Build.MANUFACTURER
            )
        }
    }

    private fun openAutostartSettings() {
        val intents = listOf(
            Intent().apply {
                setClassName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent().apply {
                setClassName(
                    "com.miui.securitycenter",
                    "com.miui.powercenter.PowerSettings"
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
        for (candidate in intents) {
            if (candidate.resolveActivity(packageManager) != null) {
                startActivity(candidate)
                return
            }
        }
        openAppDetailsSettings()
    }

    private fun buildNotificationSettingsJson(
        title: String,
        body: String,
        stopButton: String?
    ): String {
        val escapedTitle = title.jsonEscaped()
        val escapedBody = body.jsonEscaped()
        val escapedStopButton = stopButton?.jsonEscaped()
        val stopButtonJson = if (escapedStopButton == null) {
            "null"
        } else {
            "\"$escapedStopButton\""
        }
        return "{\"title\":\"$escapedTitle\",\"body\":\"$escapedBody\",\"stopButton\":$stopButtonJson,\"icon\":null}"
    }

    private fun String.jsonEscaped(): String =
        replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")

    private fun openAppDetailsSettings() {
        startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }
}

