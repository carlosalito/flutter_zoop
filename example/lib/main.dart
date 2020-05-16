import 'package:flutter/material.dart';
import 'package:flutterzoop/flutterzoop.dart';

import 'bluetoothOffScreen.dart';
import 'findDevice.dart';

void main() {
  runApp(FlutterZoopApp());
}

class FlutterZoopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterZoop.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
