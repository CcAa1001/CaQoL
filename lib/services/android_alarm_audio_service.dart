import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AlarmAudioStatus {
  final int alarmVolume;
  final int alarmMaxVolume;
  final int musicVolume;
  final int musicMaxVolume;
  final bool doNotDisturbAccessAllowed;

  const AlarmAudioStatus({
    required this.alarmVolume,
    required this.alarmMaxVolume,
    required this.musicVolume,
    required this.musicMaxVolume,
    required this.doNotDisturbAccessAllowed,
  });

  factory AlarmAudioStatus.fromMap(Map<dynamic, dynamic> map) {
    return AlarmAudioStatus(
      alarmVolume: map['alarmVolume'] ?? 0,
      alarmMaxVolume: map['alarmMaxVolume'] ?? 0,
      musicVolume: map['musicVolume'] ?? 0,
      musicMaxVolume: map['musicMaxVolume'] ?? 0,
      doNotDisturbAccessAllowed: map['doNotDisturbAccessAllowed'] == true,
    );
  }
}

class AndroidAlarmAudioService {
  static const _channel = MethodChannel('caqol/alarm_audio');

  Future<AlarmAudioStatus?> getStatus() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getAlarmAudioStatus',
    );
    if (result == null) {
      return null;
    }
    return AlarmAudioStatus.fromMap(result);
  }

  Future<void> enableBoost() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('enableAlarmAudioBoost');
  }

  Future<void> reinforce({
    required int activeAlarmCount,
    required int ringSeconds,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>(
      'reinforceAlarmAudio',
      {
        'activeAlarmCount': activeAlarmCount,
        'ringSeconds': ringSeconds,
      },
    );
  }

  Future<void> restoreIfIdle() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('restoreAlarmAudioIfIdle');
  }

  Future<void> openAlarmSoundSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('openAlarmSoundSettings');
  }
}
