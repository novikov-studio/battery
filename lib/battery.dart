
import 'dart:async';

import 'package:flutter/services.dart';

class Battery {
  static const MethodChannel _channel = MethodChannel('battery');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
