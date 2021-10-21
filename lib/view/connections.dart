import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';

class _ConnectionsWidgetState extends State<ConnectionsWidget> {
  BluetoothController controller = BluetoothControllerWidget();
  List<BluetoothDevice> foundDevices = <BluetoothDevice>[];
  bool scanning = false;
  List<String> connectedDevices = ["Starklicht-YND", "STARKLICHT-LAE"];
  List<bool> active = [true, true];
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
    return Scaffold(
      body: Center(child:
        ListView.builder(
            // + 1 To display a nice title
            itemCount: connectedDevices.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Text("Test");
              } else {
                return Card(
                    margin: EdgeInsets.all(4.0),
                    child: Column(
                        children: [
                          ListTile(
                              leading: Icon(Icons.lightbulb),
                              title: Text(connectedDevices[index - 1]),
                              subtitle: Text('Beschreibung für sdf $index - 1'),
                              trailing: Switch(
                                value: active[index - 1],
                                onChanged: (value) {
                                  setState(() {
                                    active[index - 1] = value;
                                    print(active[index - 1]);
                                  });
                                },
                                activeTrackColor: Colors.blueGrey,
                                activeColor: Colors.white,
                              )
                          )
                        ]
                    )
                );
              }
            }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class ConnectionsWidget extends StatefulWidget {
  const ConnectionsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsWidgetState();
}
