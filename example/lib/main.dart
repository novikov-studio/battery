import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _power;

  @override
  void initState() {
    super.initState();
    Battery.onBatteryPowerChanged = _onBatteryPowerChanged;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }

  void _onBatteryPowerChanged(power) {
    setState(() {
      _power = (power * 100.0).round();
    });

    if (power < 20) {
      _showSnack('Low power!', isError: true);
    }
  }

  Future<void> _getPower() async {
    final power = await Battery.power;
    if (power != null) {
      final percents = (power * 100.0).round();
      _showSnack('Power $percents', isError: false);
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
