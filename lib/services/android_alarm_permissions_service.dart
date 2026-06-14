import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidAlarmPermissionStatus {
  final bool exactAlarmAllowed;
  final bool fullScreenIntentAllowed;
  final bool notificationsAllowed;
  final bool ignoringBatteryOptimizations;
  final bool doNotDisturbAccessAllowed;
  final String manufacturer;

  const AndroidAlarmPermissionStatus({
    required this.exactAlarmAllowed,
    required this.fullScreenIntentAllowed,
    required this.notificationsAllowed,
    required this.ignoringBatteryOptimizations,
    required this.doNotDisturbAccessAllowed,
    this.manufacturer = '',
  });

  bool get isReady =>
      exactAlarmAllowed &&
      fullScreenIntentAllowed &&
      notificationsAllowed &&
      ignoringBatteryOptimizations &&
      doNotDisturbAccessAllowed;
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
        doNotDisturbAccessAllowed: true,
        manufacturer: '',
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
    final doNotDisturbAccessAllowed =
        await _channel.invokeMethod<bool>('hasNotificationPolicyAccess') ??
            false;
    final manufacturer =
        await _channel.invokeMethod<String>('getManufacturer') ?? '';

    return AndroidAlarmPermissionStatus(
      exactAlarmAllowed: exactAlarmAllowed,
      fullScreenIntentAllowed: fullScreenIntentAllowed,
      notificationsAllowed: notificationsAllowed,
      ignoringBatteryOptimizations: ignoringBatteryOptimizations,
      doNotDisturbAccessAllowed: doNotDisturbAccessAllowed,
      manufacturer: manufacturer,
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

  Future<void> openDoNotDisturbSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openDoNotDisturbSettings');
  }

  Future<void> openAutostartSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openAutostartSettings');
  }
}

