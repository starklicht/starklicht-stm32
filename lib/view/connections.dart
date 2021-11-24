import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';

class _ConnectionsWidgetState extends State<ConnectionsWidget> {
  BluetoothController<BluetoothDevice> controller = BluetoothControllerWidget();
  List<BluetoothDevice> foundDevices = <BluetoothDevice>[];
  Set<BluetoothDevice> connectedDevices = {};
  List<bool> active = [true, true];
  bool _isLoading = false;

  StreamSubscription<dynamic>? stream;


  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    controller.connectedDevicesStream().then((value) {
      setState(() {
        _isLoading = false;
      });
      connectedDevices = value.toSet();
      stream?.cancel();
      stream = controller.getConnectionStream().listen((d) {
        setState(() {
          connectedDevices.add(d);
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:
        ListView.builder(
            // + 1 To display a nice title
            itemCount: connectedDevices.isEmpty || _isLoading?1:connectedDevices.length,
            itemBuilder: (BuildContext context, int index) {
              print(index);
              if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              else if (connectedDevices.isEmpty) {
                return Padding(
                    padding: EdgeInsets.only(top: 140),
                    child: Column(
                        children: [
                          Image.asset('assets/searching-for-devices.png'),
                          const Text(
                              "Keine aktiven Verbindungen\n",
                              style: TextStyle(
                                fontSize: 20
                              ),
                          ),
                          const Text(
                            "Bitte verbinde dich zunächst mit einem Gerät.\n",
                            style: TextStyle(
                                color: Colors.grey
                            ),
                          ),
                          ElevatedButton(
                            child: Text("Gerät suchen"),
                            onPressed: () {
                              showDialog(context: context, builder: (_) {
                                return const SearchWidget();
                              });
                            },
                          )
                        ]
                    )
                );
              } else {
                return Card(
                    margin: EdgeInsets.all(4.0),
                    child: Column(
                        children: [
                          ListTile(
                              leading: Icon(Icons.lightbulb),
                              title: Text(connectedDevices.toList()[index].name),
                              subtitle: Text('Beschreibung für sdf $index - 1'),
                              trailing: Switch(
                                value: active[index],
                                onChanged: (value) {
                                  setState(() {
                                    active[index] = value;
                                    print(active[index]);
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
        onPressed:  () => {
          showDialog(context: context, builder: (_) {
            return const SearchWidget();
          })
        },
        child: const Icon(Icons.add),
        // backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }
}

class ConnectionsWidget extends StatefulWidget {
  const ConnectionsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  BluetoothController controller = BluetoothControllerWidget();
  List<BluetoothDevice> foundDevices = <BluetoothDevice>[];
  bool _scanning = false;
  StreamSubscription? subscription;
  StreamSubscription? deviceSubscription;

  void scan() {
    foundDevices.clear();
    subscription?.cancel();
    deviceSubscription?.cancel();
    deviceSubscription = controller.scan(4).asBroadcastStream().listen((a) {
      setState(() {
        foundDevices.add(a);
      });
    });
    subscription = controller.scanning().asBroadcastStream().listen((event) {
      setState(() {
        _scanning = event;
      });
    });
  }


  @override
  void initState() {
    scan();
  }

  @override
  void dispose() {
    subscription?.cancel();
    deviceSubscription?.cancel();
    super.dispose();
  }

  String getTitle() {
    return _scanning?"Suche":foundDevices.isEmpty?"Keine Geräte gefunden":"Mit Gerät verbinden";
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Text(getTitle()),
        children: <Widget>[
          ...foundDevices.map((e) => SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            onPressed: () {
              controller.connect(e);
              Navigator.pop(context);
            },
            child: Text(e.name),
          )),
          if (_scanning) ...[
            SimpleDialogOption(
                child: Center(
                    child: Column(
                      children: const [CircularProgressIndicator()],
                    )
                )
            )
          ]
          else ...[
            Center(
                child: Column(
                  children: [ElevatedButton(onPressed: scan, child: Text("Erneut suchen"))
                  ],
                )
            )
          ]
        ]
    );
  }

}


class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchWidgetState();
}
