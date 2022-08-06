/// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets, which means it defaults to [BottomNavigationBarType.fixed], and
// the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/save_message.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:starklicht_flutter/view/animation_list.dart';
import 'package:starklicht_flutter/view/colors.dart';
import 'package:starklicht_flutter/view/connections.dart';
import "package:i18n_extension/i18n_widget.dart";
import 'package:starklicht_flutter/view/orchestra_list_view.dart';
import "i18n/main.dart";

import 'view/animations.dart';

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', "US"),
        Locale('de', "DE")
      ],
      title: _title,
      home: I18n(
          child: const MyStatefulWidget()
      ),
      darkTheme: ThemeData.dark(),
      /* theme: ThemeData(
        toggleableActiveColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(
            secondary: Colors.blueAccent, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black12
        ),
        toggleableActiveColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(
            secondary: Colors.blueAccent, brightness: Brightness.dark,

        ),
      ), */
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  final bool showOrchestra = true;

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // TODO: Put hashmap of Options over here and pass it to the components.
  // The options should be synchronized to controller
  List<SBluetoothDevice> options = [];
  StreamSubscription<dynamic>? optionsStream;
  int _selectedIndex = 0;
  bool hideBottom = false;
  final double _red = 0;
  final BluetoothController controller = BluetoothControllerWidget();
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    const ConnectionsWidget(),
    ColorScaffoldWidget(),
    const AnimationsEditorScaffoldWidget(),
    const AnimationsWidget(),
    OrchestraListView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller.connectedDevicesStream().listen((event) {
      setState(() {
        options = event as List<SBluetoothDevice>;
      });
    });
    controller.connectionChangeStream().listen((event) {
      var text = "";
      var name = event.device.options.name ?? event.device.device.name;
      if(event.type == ConnectionType.CONNECT) {
        if(!event.auto) {
          text = "%s wurde verbunden".i18n.fill([name]);
        } else {
          text = "%s hat sich verbunden".i18n.fill([name]);
        }
      } else {
        if(!event.auto) {
          text = "%s wurde getrennt".i18n.fill([name]);
        } else {
          text = "%s hat sich getrennt".i18n.fill([name]);
        }
      }
      var snackBar = SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 600),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void saveToLamp(int selectedRadio) async {
    print(selectedRadio);
    int n = controller.broadcast(SaveMessage(true, selectedRadio));
    var snackBar = SnackBar(
      content: Text('Auf Button %d gespeichert'.i18n.fill([selectedRadio + 1])),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void loadFromLamp(int selectedRadio) async {
    int n = controller.broadcast(SaveMessage(false, selectedRadio));
    var snackBar = SnackBar(
      content: Text('Button %d geladen'.i18n.fill([selectedRadio + 1])),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STARKLICHT'.i18n, style: const TextStyle(
          fontFamily: 'MontserratBlack',
        )),
        actions: <Widget>[
          if(options.isNotEmpty)...[ IconButton(
            onPressed: () => {
              setState(() {
                hideBottom = !hideBottom;
              })
            },
            icon: const Icon(Icons.border_bottom),
          ), ],
          IconButton(onPressed: () {
            var brightness = 100.0;
            Persistence().getBrightness().then((i) {
              setState(() {
                brightness = i.toDouble();
              });
              showDialog(context: context, builder: (_) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                  scrollable: true,
                  title: Text("Helligkeit einstellen".i18n),
                  content: Container(
                    child:Column(children:  [
                      Slider(
                      max: 100,
                        onChangeEnd: (d) => {
                          setState(() {
                            brightness = d;
                          }),
                          controller.broadcast(BrightnessMessage(brightness  * 255 ~/ 100.0)),
                          Persistence().setBrightness(brightness.toInt())
                        },
                        onChanged: (d) => {
                          setState(() {
                            brightness = d;
                          }),
                          controller.broadcast(BrightnessMessage(brightness  * 255 ~/ 100.0))
                        },
                        value: brightness,
                      ),
                      Text("${brightness.toInt()}%", style: const TextStyle(
                        fontSize: 32
                      ),)
                    ])
                  ),
                    actions: [
                      TextButton.icon(onPressed: () => {
                        setState(() {
                          brightness = 0;
                        }),
                        controller.broadcast(BrightnessMessage(brightness  * 255 ~/ 100.0))
                      }, icon: const Icon(Icons.lightbulb_outline), label: Text("Aus".i18n)),
                      TextButton.icon(onPressed: () => {
                        setState(() {
                          brightness = 100;
                        }),
                        controller.broadcast(BrightnessMessage(brightness  * 255 ~/ 100.0))
                      }, icon: const Icon(Icons.lightbulb), label: Text("Max. Helligkeit".i18n))
                    ],
                  );});
            }); });

            }, icon: const Icon(Icons.light_mode)),
          IconButton(
              onPressed: () => showDialog(context: context, builder: (BuildContext context) {
                int selectedRadio = -1;
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {return AlertDialog(
                  title: Text("Auf Button speichern".i18n),
                  content: SizedBox(
                      height: 110,
                      child:Column(
                    children: [
                      Text("Speichere die momentan ablaufende Szene auf deinem Starklicht".i18n),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        List<Widget>.generate(4, (int index) {
                          return Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (value) {
                              setState(() => selectedRadio = value as int);
                            },
                          );
                        }),
                      ),
                      if(selectedRadio >= 0) ...[Text("Wird auf Button %d gespeichert".i18n.fill([selectedRadio + 1]))]

                    ],
                  )),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Abbrechen".i18n)),
                      TextButton(onPressed: selectedRadio < 0?null:() {
                        loadFromLamp(selectedRadio);
                        Navigator.pop(context);
                      }, child: Text("Laden".i18n)),
                    TextButton(onPressed: selectedRadio < 0?null:() {
                      saveToLamp(selectedRadio);
                      Navigator.pop(context);
                    }, child: Text("Speichern".i18n))
                  ],);},

                );
              }),
              icon: const Icon(Icons.save_alt)
          ),
        ],
      ),
      bottomSheet: options.isEmpty || hideBottom ? null : Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            border: Border.all(
              color: Theme.of(context).dividerColor
            ),
            color: Theme.of(context).cardColor
          ),
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
             options.map((e) =>
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    children:
                    [
                      Checkbox(
                        value: e.options.active,
                        onChanged: (v) => {
                          setState(() {
                            controller.setOptions(e.device.id.id, e.options.withActive(v!));
                          }),
                        },
                      ),
                      Text(controller.getName(e.device.id.id)),
                    ]
                ),
              )
            ).toList()
        )
      ),
      body: Padding(
        padding: options.isEmpty || hideBottom ? EdgeInsets.zero:const EdgeInsets.only(bottom: 56),
        child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.wifi_tethering),
            label: 'Verbindungen'.i18n,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.color_lens),
            label: 'Farbe'.i18n,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.animation),
            label: 'Animation'.i18n
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: 'Bibliothek'.i18n,
          ),
          if(widget.showOrchestra) ... [const BottomNavigationBarItem(
            icon: Icon(Icons.view_timeline),
            label: 'Timelines'
          )]
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
