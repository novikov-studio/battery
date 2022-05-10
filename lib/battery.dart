import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Интерфейс плагина.
class Battery {
  static const _channelName = 'battery';
  static const _methodPowerChangeNotify = 'power_change_notify';
  static const _methodGetPower = 'get_percents';

  static const MethodChannel _channel = MethodChannel(_channelName);
  static bool _initialized = false;
  static ValueChanged<int>? _onBatteryPowerChanged;

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String?>('getPlatformVersion');

    return version;
  }

  /// Получение текущего зараяда батарееи в процентах (0..100).
  static Future<int?> get power async =>
      _channel.invokeMethod<int?>(_methodGetPower);

  /// Колбэк на изменение заряда батареи.
  static ValueChanged<int>? get onBatteryPowerChanged =>
      _onBatteryPowerChanged;

  /// Установка колбэка на изменение заряда батареи.
  static set onBatteryPowerChanged(ValueChanged<int>? value) {
    _onBatteryPowerChanged = value;
    if (value != null) {
      if (!_initialized) _init();
    } else {
      if (_initialized) _finit();
    }
  }

  /// Инициализация.
  static void _init() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case _methodPowerChangeNotify:
          _onBatteryPowerChanged?.call(call.arguments as int);
      }
    });
    _initialized = true;
  }

  /// Финализация.
  static void _finit() {
    _channel.setMethodCallHandler(null);
    _initialized = false;
  }
}
