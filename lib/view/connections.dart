import 'dart:async';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';

class _ConnectionsWidgetState extends State<ConnectionsWidget> {
  BluetoothController<BluetoothDevice> controller = BluetoothControllerWidget();
  List<BluetoothDevice> foundDevices = <BluetoothDevice>[];
  Set<BluetoothDevice> connectedDevices = {};
  bool mock = true;
  bool test = false;
  bool test2 = false;
  List<StarklichtBluetoothOptions> options = [];
  bool _isLoading = false;

  BluetoothState state = BluetoothState.unknown;

  StreamSubscription<dynamic>? stream;
  StreamSubscription<dynamic>? optionsStream;
  StreamSubscription<dynamic>? disconnectStream;


  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    controller.connectedDevicesStream().then((value) {
      setState(() {
        _isLoading = false;
        connectedDevices = value.toSet();
      });
      /*  */
    });
    stream?.cancel();
    stream = controller.getConnectionStream().listen((d) {
      print("STATE CHANGE!");
      print(d.state.toString());
      setState(() {
        connectedDevices.add(d);
      });
    });
    disconnectStream?.cancel();
    disconnectStream = controller.getDisconnectionStream().listen((d) {
      print("DISCONNECTIOOOON");
      print(d.id);
      setState(() {
        connectedDevices.remove(d);
      });
    });
    controller.stateStream().listen((event) {
      setState(() {
        state = event;
      });
    });
    optionsStream = controller.getOptionsStream().listen((event) {
      setState(() {
        options = event;
      });
    });
  }

  List<String> getPlaceholderTitleAndSubtitle() {
    if(state == BluetoothState.unauthorized || state == BluetoothState.unknown
    || state == BluetoothState.unavailable) {
      return ["Bluetooth ist nicht verfügbar", "Eventuell fehlen Berechtigungen für den\n Standortzugriff oder Bluetooth."];
    }
    if(state == BluetoothState.off) {
      return ["Bluetooth ist aus", "Du kannst Bluetooth in deinen \nGeräteeinstellungen anschalten."];
    }
    return ["Keine aktiven Verbindungen", "Bitte verbinde dich zunächst mit einem Starklicht."];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ListView.builder(
          shrinkWrap: connectedDevices.isEmpty,
            itemCount: connectedDevices.isEmpty || _isLoading
                || state == BluetoothState.unknown ||
                state == BluetoothState.off ||
                state == BluetoothState.unauthorized ||
                state == BluetoothState.unavailable
                ?1:connectedDevices.length,
            itemBuilder: (BuildContext context, int index) {
              print(index);
              if (_isLoading) {
                return CircularProgressIndicator();
              }
              else if (connectedDevices.isEmpty) {
                return Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/rocket.json',
		                        width: 500
                          ),
                          // Image.asset('assets/searching-for-devices.png'),
                          Text(
                            "${getPlaceholderTitleAndSubtitle()[0]}\n",
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          Text(
                            "${getPlaceholderTitleAndSubtitle()[1]}\n",
                            style: TextStyle(
                                color: Colors.grey
                            ),
                          ),
                          if(state == BluetoothState.on) ElevatedButton(
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
                var d = connectedDevices.toList()[index];
                var option = options.firstWhereOrNull((element) => element.id == d.id.id);
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 8,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    option?.name ?? d.name
                                    , style: TextStyle(
                                    fontSize: 32,
                                  )),
                                  IconButton(onPressed: () => {
                                    showDialog(context: context, builder: (_) {
                                      return AlertDialog(
                                        title: Text("Informationen"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Gerätename: ${d.name}"),
                                            Text("Name: ${option?.name ?? "Nicht vergeben"}"),
                                            Text("ID: ${d.id.id}")
                                          ]
                                        ),
                                      );
                                    })
                                  }, icon: Icon(Icons.info_outlined))
                                ],
                              ),
                              if(option != null) ...[
                                Divider(
                                  height: 32
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ChoiceChip(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        avatar: CircleAvatar(
                                            child: Icon(Icons.invert_colors)
                                        ),
                                        selected: option.inverse,
                                        onSelected: (val) {
                                          setState(() {
                                            controller.setOptions(d.id.id, option.withInverse(val));
                                          });
                                        },
                                        label: Text("Invertieren")
                                    ),
                                    GestureDetector(
                                      onLongPress: () => {
                                        showDialog(context: context, builder: (_) {
                                          var t = TextEditingController();
                                          t.text = option.delayTimeMillis.toString();
                                          return AlertDialog(
                                            title: Text("Verzögungsdauer ändern"),
                                            content: TextField(
                                              controller: t,
                                              decoration: InputDecoration(
                                                  labelText: 'Verzögerung in ms',
                                                  border: OutlineInputBorder()
                                              ),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  child: Text("Abbrechen"),
                                                  onPressed: () => {Navigator.pop(context)}),
                                              TextButton(
                                                child: Text("Speichern"),
                                                onPressed: () => {
                                                  controller.setOptions(d.id.id, option.withDelayTime(
                                                    int.parse(t.text)
                                                  )),
                                                  Navigator.pop(context)
                                                }
                                              )
                                            ],
                                          );
                                        })
                                      },
                                      child: ChoiceChip(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          avatar: CircleAvatar(
                                              child: Icon(Icons.schedule)
                                          ),
                                          selected: option.delay,
                                          onSelected: (val) {
                                            setState(() {
                                              controller.setOptions(d.id.id, option.withDelay(val));
                                            });
                                          },
                                          label: Text("Verzögerung (${option.delayTimeMillis}ms)")
                                      ),
                                    ),
                                    ChoiceChip(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        avatar: CircleAvatar(
                                            child: Icon(Icons.visibility_off)
                                        ),
                                        selected: !option.active,
                                        onSelected: (val) {
                                          setState(() {
                                            controller.setOptions(d.id.id, option.withActive(!val));
                                          });
                                        },
                                        label: Text("Deaktivieren")
                                    ),
                                  ]
                              ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Wrap(
                                    children: [
                                      TextButton(
                                        child: Text("Verbindung trennen".toUpperCase(), style:
                                        TextStyle(
                                          color: Colors.redAccent
                                        )),
                                        onPressed: () => {
                                          controller.disconnect(d)
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Umbenennen".toUpperCase()),
                                        onPressed: () => {
                                          showDialog(context: context, builder: (_) {
                                            var t = TextEditingController();
                                            t.text = option.name ?? "";
                                            return AlertDialog(
                                              title: Text("Umbenennen"),
                                              content: TextField(
                                                textCapitalization: TextCapitalization.sentences,
                                                controller: t,
                                                decoration: InputDecoration(
                                                    labelText: 'Name',
                                                    hintText: d.name,
                                                    border: OutlineInputBorder()
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                    child: Text("Abbrechen"),
                                                onPressed: () => {Navigator.pop(context)}),
                                                TextButton(
                                                  child: Text("Speichern"),
                                                  onPressed: () {
                                                    var text = t.text.trim();
                                                    controller.setOptions(d.id.id, option.withName(
                                                        text.isEmpty ? null : text
                                                    ));
                                                    Navigator.pop(context);
                                                  }
                                                )
                                              ],
                                            );
                                          })
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ]
                              /* trailing: Switch(
                                value: options[d]!.active,
                                onChanged: (value) {
                                  setState(() {
                                    options[d]!.active = value;
                                  });
                                  controller.setActive(d, options[d]!.active);
                                },
                                activeTrackColor: Colors.blueGrey,
                                activeColor: Colors.white,
                              ) */
                        ]
                    ),
                      /* onTap: () => showDialog(context: context, builder: (_) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                          title: Text(d.name),
                          content: Column(
                          children: [
                            CheckboxListTile(
                              title: Text("Farben invertieren"),
                              value: options[d]!.inverse,
                              onChanged: (value) {
                                setState(() {
                                  options[d]!.inverse = value!;
                                });
                                controller.setInverse(d, value!);
                              }
                            ),
                            CheckboxListTile(
                                title: Text("Eingaben verzögern"),
                                value: options[d]!.delay,
                                onChanged: (value) {
                                  setState(() {
                                    options[d]!.delay = value!;
                                  });
                                  controller.setDelay(d, value!);
                                }
                            ),
                            if(options[d]!.delay)
                              ...[
                                TextFormField(
                                  onChanged: (value) {
                                    var s = 0;
                                    if(value.isNotEmpty) {
                                      s = int.parse(value.trim());
                                    }
                                    setState(() {
                                      options[d]!.delayTimeMillis = s;
                                    });
                                    controller.setDelayTime(d, s);
                                  },
                                  initialValue: options[d]!.delayTimeMillis
                                      .toString(),
                                  decoration: const InputDecoration(
                                    labelText: "Verzögerung in Millisekunden:",
                                    border: OutlineInputBorder()
                                  ),
                                  keyboardType: TextInputType.number,
                                )
                              ]
                          ],
                          ),
                          );
                        });
                      }), */
                    ));
              }
            }
        )
      ),
        floatingActionButton: state == BluetoothState.on?FloatingActionButton(
        onPressed:  () => {
          showDialog(context: context, builder: (_) {
            return const SearchWidget();
          })
        },
        child: const Icon(Icons.add),
        // backgroundColor: Colors.white,
      ):null,
    );
  }

  @override
  void dispose() {
    stream?.cancel();
    optionsStream?.cancel();
    disconnectStream?.cancel;
    // Remove handler again
    super.dispose();
  }
}

class ConnectionsWidget extends StatefulWidget {
  ConnectionsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  BluetoothController controller = BluetoothControllerWidget();
  Set<BluetoothDevice> foundDevices = <BluetoothDevice>{};
  bool _scanning = false;
  StreamSubscription? subscription;
  StreamSubscription? deviceSubscription;

  void scan() {
    setState(() {
      foundDevices = {};
    });
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
    super.initState();
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
