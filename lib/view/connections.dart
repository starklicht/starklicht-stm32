import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';

class _ConnectionsWidgetState extends State<ConnectionsWidget> {
  BluetoothController controller = BluetoothControllerWidget();
  List<BluetoothDevice> foundDevices = <BluetoothDevice>[];
  bool scanning = false;

  void scan() {
    try {
      var s = controller.scan(4);
      s.listen((event) {
        setState(() {
          foundDevices.add(event);
        });
      });
    } catch (e) {
      print("Scanning still");
    }
  }

  void stopScan() {
    controller.stopScan();
  }

  void connect() {}

  @override
  Widget build(BuildContext context) {
    controller.scanning().listen((s) {
      setState(() {
        scanning = s;
      });
    });
    return Column(
      children: [
        Column(children: [
          Text('Connections'),
          Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: EdgeInsets.all(10.0),
              child: Row(children: [
                TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white
                    ),
                    onPressed: scanning ? null : scan,
                    child: scanning ? Text('Scanning...') : Text('Scan')),
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white
                    ),
                    onPressed: () {
                      connect();
                    },
                    child: const Text('Connect'))
              ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ))
        ])
      ],
    );
  }
}

class ConnectionsWidget extends StatefulWidget {
  const ConnectionsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsWidgetState();
}
