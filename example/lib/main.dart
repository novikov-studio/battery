import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _power;
  bool _alarm = true;

  @override
  void initState() {
    super.initState();
    Battery.onBatteryPowerChanged = _onBatteryPowerChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Battery Plugin example'),
          actions: [
            IconButton(
              onPressed: _getPower,
              icon: const Icon(Icons.battery_unknown),
            ),
          ],
        ),
        body: Center(
          child: _power != null
              ? Text('$_power')
              : const CircularProgressIndicator(),
        ),
    );
  }

  void _onBatteryPowerChanged(power) {
    setState(() {
      _power = power;
    });

    if (power < 20) {
      if (_alarm) {
        _alarm = false;
        _showSnack('Low power!', isError: true);
      }
    } else {
      _alarm = true;
    }
  }

  Future<void> _getPower() async {
    final power = await Battery.power;
    if (power != null) {
      _showSnack('Power $power', isError: false);
    } else {
      _showSnack('Can\'t get power', isError: true);
    }
  }

  void _showSnack(String text, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: isError ? const TextStyle(color: Colors.white) : null,
        ),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
