/// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets, which means it defaults to [BottomNavigationBarType.fixed], and
// the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].

import 'package:flutter/material.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/save_message.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:starklicht_flutter/view/animation_list.dart';
import 'package:starklicht_flutter/view/colors.dart';
import 'package:starklicht_flutter/view/connections.dart';

import 'view/animations.dart';

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: const MyStatefulWidget(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.pink,
        accentColor: Colors.pink,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pink,
        accentColor: Colors.pink,
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  double _red = 0;
  final BluetoothController controller = BluetoothControllerWidget();
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    ConnectionsWidget(),
    ColorsWidget(sendOnChange: true),
    Padding(padding: EdgeInsets.only(top: 12),child:AnimationsEditorWidget()),
    AnimationsWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void saveToLamp(int selectedRadio) {
    print(selectedRadio);
    int n = controller.broadcast(SaveMessage(true, selectedRadio));
    var snackBar = SnackBar(
      content: Text('Auf Button ${selectedRadio + 1} für ${n} Lampen gespeichert'),
      duration: Duration(milliseconds: 600),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void loadFromLamp(int selectedRadio) {
    int n = controller.broadcast(SaveMessage(false, selectedRadio));
    var snackBar = SnackBar(
      content: Text('Button ${selectedRadio + 1} auf ${n} Lampen geladen'),
      duration: Duration(milliseconds: 600),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STARKLICHT V2', style: TextStyle(
          fontFamily: 'MontserratBlack',
        )),
        backgroundColor: Colors.black87,
        actions: <Widget>[
          IconButton(onPressed: () => {
            controller.broadcast(BrightnessMessage(0)),
            Persistence().setBrightness(0),
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lampenhelligkeiten auf 0% gesetzt"))
          )
            // TODO: Better icon
          }, icon: Icon(Icons.lightbulb_outline)),
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
                  title: Text("Helligkeit einstellen"),
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
                      Text("${brightness.toInt()}%", style: TextStyle(
                        fontSize: 32
                      ),)
                    ])
                  ),
                  );});
            }); });

            }, icon: Icon(Icons.light_mode)),
          IconButton(
              onPressed: () => showDialog(context: context, builder: (BuildContext context) {
                int selectedRadio = -1;
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {return AlertDialog(
                  title: Text("Auf Button speichern"),
                  content: Container(
                      height: 110,
                      child:Column(
                    children: [
                      Text("Speichere die momentan ablaufende Szene auf deinem Starklicht"),
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
                      if(selectedRadio >= 0) ...[Text("Wird auf Button ${selectedRadio + 1} gespeichert")]

                    ],
                  )),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Abbrechen")),
                      TextButton(onPressed: selectedRadio < 0?null:() {
                        loadFromLamp(selectedRadio);
                        Navigator.pop(context);
                      }, child: Text("Laden")),
                    TextButton(onPressed: selectedRadio < 0?null:() {
                      saveToLamp(selectedRadio);
                      Navigator.pop(context);
                    }, child: Text("Speichern"))
                  ],);},

                );
              }),
              icon: Icon(Icons.save_alt)
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_tethering),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            label: 'Simple',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'Animation'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bibliothek',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
