import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidAlarmPermissionStatus {
  final bool exactAlarmAllowed;
  final bool fullScreenIntentAllowed;
  final bool notificationsAllowed;
  final bool ignoringBatteryOptimizations;

  const AndroidAlarmPermissionStatus({
    required this.exactAlarmAllowed,
    required this.fullScreenIntentAllowed,
    required this.notificationsAllowed,
    required this.ignoringBatteryOptimizations,
  });

  bool get isReady =>
      exactAlarmAllowed &&
      fullScreenIntentAllowed &&
      notificationsAllowed &&
      ignoringBatteryOptimizations;
}

class AndroidAlarmPermissionsService {
  static const _channel = MethodChannel('caqol/alarm_permissions');

  Future<AndroidAlarmPermissionStatus> getStatus() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const AndroidAlarmPermissionStatus(
        exactAlarmAllowed: true,
        fullScreenIntentAllowed: true,
        notificationsAllowed: true,
        ignoringBatteryOptimizations: true,
      );
    }

    final exactAlarmAllowed =
        await _channel.invokeMethod<bool>('canScheduleExactAlarms') ?? false;
    final fullScreenIntentAllowed =
        await _channel.invokeMethod<bool>('canUseFullScreenIntent') ?? false;
    final notificationsAllowed =
        await _channel.invokeMethod<bool>('areNotificationsEnabled') ?? false;
    final ignoringBatteryOptimizations =
        await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
            false;

    return AndroidAlarmPermissionStatus(
      exactAlarmAllowed: exactAlarmAllowed,
      fullScreenIntentAllowed: fullScreenIntentAllowed,
      notificationsAllowed: notificationsAllowed,
      ignoringBatteryOptimizations: ignoringBatteryOptimizations,
    );
  }

  Future<void> openExactAlarmSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openExactAlarmSettings');
  }

  Future<void> openFullScreenIntentSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openFullScreenIntentSettings');
  }

  Future<void> openNotificationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openNotificationSettings');
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
  }
}

