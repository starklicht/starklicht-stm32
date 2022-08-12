import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:lottie/lottie.dart';
import "../i18n/connections.dart";
import '../model/lamp_groups_enum.dart';
import 'package:collection/src/iterable_extensions.dart';

class _ConnectionsWidgetState extends State<ConnectionsWidget> {
  BluetoothController<SBluetoothDevice> controller = BluetoothControllerWidget();
  List<SBluetoothDevice> foundDevices = <SBluetoothDevice>[];
  Set<SBluetoothDevice> connectedDevices = {};
  bool mock = true;
  bool test = false;
  bool test2 = false;
  bool _isLoading = false;

  BluetoothState state = BluetoothState.unknown;

  StreamSubscription<dynamic>? stream;
  StreamSubscription<dynamic>? myStream;
  StreamSubscription<dynamic>? optionsStream;
  StreamSubscription<dynamic>? disconnectStream;


  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
    });
    myStream?.cancel();
    myStream = controller.connectedDevicesStream().listen((value) {
      if(mounted) {
        setState(() {
          _isLoading = false;
          connectedDevices = value.toSet();
        });
      }
      /*  */
    });
    stream?.cancel();
    controller.stateStream().listen((event) {
      setState(() {
        state = event;
      });
    });
  }

  List<String> getPlaceholderTitleAndSubtitle() {
    if(state == BluetoothState.unauthorized || state == BluetoothState.unknown
    || state == BluetoothState.unavailable) {
      return ["Bluetooth ist nicht verfügbar".i18n, "Eventuell fehlen Berechtigungen für den Standortzugriff oder Bluetooth".i18n];
    }
    if(state == BluetoothState.off) {
      return ["Bluetooth ist aus".i18n, "Du kannst Bluetooth in deinen Geräteeinstellungen anschalten".i18n];
    }
    return ["Keine aktiven Verbindungen".i18n, "Bitte verbinde dich zunächst mit einem Starklicht".i18n];
  }


  Widget getAvatar(String name) {
    var group = LampGroups.values.firstWhereOrNull((e) => name.toLowerCase() == e.name.toLowerCase());
    if(group != null) {
      return Icon(group.icon, size: 18);
    }
    return Text(name[0].toUpperCase());
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
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
                return const CircularProgressIndicator();
              }
              else if (connectedDevices.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.all(8),
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
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,

                            ),
                          ),
                          Text(
                            "${getPlaceholderTitleAndSubtitle()[1]}\n",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey
                            ),
                          ),
                          if(state == BluetoothState.on) ElevatedButton(
                            child: Text("Gerät suchen".i18n),
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
                var option = d.options;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    option.name ?? d.device.name
                                    , style: const TextStyle(
                                    fontSize: 32,
                                    overflow: TextOverflow.ellipsis
                                  )),
                                  IconButton(onPressed: () => {
                                    showDialog(context: context, builder: (_) {
                                      return AlertDialog(
                                        title: Text("Informationen".i18n),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Gerätename: %s".i18n.fill([d.device.name])),
                                            Text("Name: %s".i18n.fill([option.name ?? "Nicht vergeben"])),
                                            Text("ID: %s".i18n.fill([d.device.id.id]))
                                          ]
                                        ),
                                      );
                                    })
                                  }, icon: const Icon(Icons.info_outlined))
                                ],
                              )),
                              if(option != null) ...[
                                const Divider(
                                  height: 32
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ChoiceChip(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        avatar: const CircleAvatar(
                                            child: Icon(Icons.invert_colors)
                                        ),
                                        selected: option.inverse,
                                        onSelected: (val) {
                                          setState(() {
                                            controller.setOptions(d.device.id.id, option.withInverse(val));
                                          });
                                        },
                                        label: Text("Invertieren".i18n)
                                    ),
                                    GestureDetector(
                                      onLongPress: () => {
                                        showDialog(context: context, builder: (_) {
                                          var t = TextEditingController();
                                          t.text = option.delayTimeMillis.toString();
                                          return AlertDialog(
                                            title: Text("Verzögungsdauer ändern".i18n),
                                            content: TextField(
                                              controller: t,
                                              decoration: InputDecoration(
                                                  labelText: 'Verzögerung in ms'.i18n,
                                                  border: const OutlineInputBorder()
                                              ),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  child: Text("Abbrechen".i18n),
                                                  onPressed: () => {Navigator.pop(context)}),
                                              TextButton(
                                                child: Text("Speichern".i18n),
                                                onPressed: () => {
                                                  controller.setOptions(d.device.id.id, option.withDelayTime(
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
                                          avatar: const CircleAvatar(
                                              child: Icon(Icons.schedule)
                                          ),
                                          selected: option.delay,
                                          onSelected: (val) {
                                            setState(() {
                                              controller.setOptions(d.device.id.id, option.withDelay(val));
                                            });
                                          },
                                          label: Text("Verzögerung (%d ms)".i18n.fill([option.delayTimeMillis]))
                                      ),
                                    ),
                                    ChoiceChip(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        avatar: const CircleAvatar(
                                            child: Icon(Icons.visibility)
                                        ),
                                        selected: option.active,
                                        onSelected: (val) {
                                          setState(() {
                                            controller.setOptions(d.device.id.id, option.withActive(val));
                                          });
                                        },
                                        label: Text("Aktivieren".i18n)
                                    ),
                                    Divider(),
                                    Text("Lampengruppen"),
                                    Container(
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            ...option.tags.map((e) => Chip(
                                              avatar: CircleAvatar(
                                                child: getAvatar(e),
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                              ),
                                              label: Text(e),
                                              materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                              onDeleted: () => {
                                                setState((){
                                                  controller.setOptions(d.device.id.id, option.withoutTag("test"));
                                                })
                                              },
                                            )),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4.0),
                                              child: ActionChip(
                                                materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  showDialog(context: context, builder: (_) {
                                                    return AlertDialog(
                                                      title: Text("Gruppenbeschränkung hinzufügen"),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("Vorlagen"),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Wrap(
                                                              children:
                                                              LampGroups.values.map((e) =>
                                                                  ActionChip(
                                                                      avatar: CircleAvatar(
                                                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                                                        child: Icon(e.icon, size: 18),
                                                                      ),
                                                                      label: Text(e.name.toLowerCase()), onPressed: () => {
                                                                    textController.text = e.name.toLowerCase()
                                                                  }
                                                                  )
                                                              ).toList()
                                                              ,
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            controller: textController,
                                                            decoration: const InputDecoration(
                                                                labelText: "Lampengruppe definieren"
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(child: Text("Abbrechen"), onPressed: () => { Navigator.pop(context) },),
                                                        TextButton(child: Text("Speichern"), onPressed: () {
                                                          if(textController.text.trim().isNotEmpty) {
                                                            setState(() {
                                                              controller.setOptions(d.device.id.id, option.withTag(textController.text.trim()));
                                                            });
                                                          }
                                                          Navigator.pop(context);
                                                        })
                                                      ],
                                                    );
                                                  });
                                                },
                                                label: Icon(Icons.add),
                                              ),
                                            ),
                                          ]
                                        )
                                      ),
                                    )
                                  ]
                              ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Wrap(
                                    children: [
                                      TextButton(
                                        child: Text("Verbindung trennen".i18n.toUpperCase(), style:
                                        const TextStyle(
                                          color: Colors.redAccent
                                        )),
                                        onPressed: () => {
                                          controller.disconnect(d)
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Umbenennen".i18n.toUpperCase()),
                                        onPressed: () => {
                                          showDialog(context: context, builder: (_) {
                                            var t = TextEditingController();
                                            t.text = option.name ?? "";
                                            return AlertDialog(
                                              title: Text("Umbenennen".i18n),
                                              content: TextField(
                                                textCapitalization: TextCapitalization.sentences,
                                                controller: t,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(20),
                                                  ],
                                                decoration: InputDecoration(
                                                    labelText: 'Name'.i18n,
                                                    hintText: d.device.name,
                                                    border: const OutlineInputBorder()
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                    child: Text("Abbrechen".i18n),
                                                onPressed: () => {Navigator.pop(context)}),
                                                TextButton(
                                                  child: Text("Speichern".i18n),
                                                  onPressed: () {
                                                    var text = t.text.trim();
                                                    controller.setOptions(d.device.id.id, option.withName(
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
    myStream?.cancel;
    // Remove handler again
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
  Set<SBluetoothDevice> foundDevices = <SBluetoothDevice>{};
  bool _scanning = false;
  StreamSubscription? subscription;
  StreamSubscription? deviceSubscription;

  void scan() {
    setState(() {
      foundDevices.clear();
    });
    subscription?.cancel();
    deviceSubscription?.cancel();
    deviceSubscription = controller.scan(4).listen((a) {
      setState(() {
        foundDevices = a.toSet() as Set<SBluetoothDevice>;
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
    return _scanning?"Suche".i18n:foundDevices.isEmpty?"Keine Geräte gefunden".i18n:"Mit Gerät verbinden".i18n;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return SimpleDialog(title: Text(getTitle()), children: <Widget>[
        ...foundDevices.map((e) => SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () {
                controller.connect(e);
                Navigator.pop(context);
              },
              child: Text(e.options.name ?? e.device.name),
            )),
        if (_scanning) ...[
          SimpleDialogOption(
              child: Center(
                  child: Column(
            children: const [CircularProgressIndicator()],
          )))
        ] else ...[
          Center(
              child: Column(
            children: [
              ElevatedButton(onPressed: scan, child: Text("Search again".i18n))
            ],
          ))
        ]
      ]);
    });
  }
}


class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchWidgetState();
}
