
import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/messages/fade_message.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:starklicht_flutter/view/time_picker.dart';
import '../i18n/colors.dart';
import 'dart:math' as math;
class ColorSaveController {
  Function? save;
  Function? delete;
}

class ColorsWidget extends StatefulWidget {
  Color? startColor;
  ValueChanged<Color>? onChanged;
  bool emitEventsSlowly;
  ValueChanged<bool>? onColorExistsChange;
  ColorSaveController? controller;
  ColorsWidget({Key? key, this.startColor, this.onChanged, this.onColorExistsChange, this.controller, this.emitEventsSlowly = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorsWidgetState();
}

class _ColorsWidgetState extends State<ColorsWidget> {
  bool isLoading = false;

  Map<ColorSwatch<Object>, String> colorsNameMap =
  <ColorSwatch<Object>, String>{
  };

  final bool _hexValid = true;
  final String _currentHex = "";
  bool _colorIsSaved = false;
  final _formKey = GlobalKey<FormState>();

  // create some values
  Color pickerColor = const Color(0xff000000);
  List<Color> recentColors = [];


// ValueChanged<Color> callback
  void changeColor(Color color, {bool emit = true}) {
    setState(() {
      pickerColor = color;
    });
    if(emit) {
      widget.onChanged?.call(pickerColor);
    }
  }

  String getColorText() {
    return (0xFFFFFF & pickerColor.value).toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      var prefix = pickerColor.alpha.toRadixString(16);
      if(prefix.length == 1) {
        prefix = "0" + prefix;
      }
      hexColor = prefix + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    throw Exception("Hex code is wrong");
  }

  void updateIsColorSaved() {
    setState(() {
      _colorIsSaved = ColorTools.isCustomColor(pickerColor, colorsNameMap);
    });
    widget.onColorExistsChange?.call(_colorIsSaved);
  }

  void saveColor() {
    print("I AM SAVING A COLOR");
    setState(() {
      var nMap = colorsNameMap.entries.toList();
      nMap.add(MapEntry(ColorTools.createPrimarySwatch(pickerColor), "New Color"));
      colorsNameMap = { for (var item in nMap) item.key : item.value };
      Persistence().saveCustomColors(colorsNameMap.keys.map((e) => e).toList());
      updateIsColorSaved();
    });
  }

  void deleteColor() {
    print("I AM DELETING A COLOR");
    setState(() {
      var nMap = colorsNameMap.entries.where((element) => element.key.value != pickerColor.value);
      colorsNameMap = { for (var item in nMap) item.key : item.value };
      Persistence().saveCustomColors(colorsNameMap.keys.map((e) => e).toList());
      updateIsColorSaved();
    });
  }


  @override
  void initState() {
    super.initState();
    widget.controller?.save = saveColor;
    widget.controller?.delete = deleteColor;
    if(widget.startColor != null) {
      setState(() {
        isLoading = true;
      });
      Persistence().loadCustomColors().then((e) => {
        setState(() {
          var nMap = e.map((e) => MapEntry(ColorTools.createPrimarySwatch(e), ""));
          colorsNameMap = { for (var item in nMap) item.key : item.value };
          isLoading = false;
          pickerColor = widget.startColor!;
        })
      });
    } else {
      // Load from state
      setState(() {
        isLoading = true;
      });
      // TODO: Error logs
      Persistence().getColor().then((i) => {
      setState(() {
        pickerColor = i;
        updateIsColorSaved();
      })
      }).then((value) => Persistence().loadCustomColors().then((e) => {
        setState(() {
          var nMap = e.map((e) => MapEntry(ColorTools.createPrimarySwatch(e), ""));
          colorsNameMap = { for (var item in nMap) item.key : item.value };
          updateIsColorSaved();
          isLoading = false;
        })
      }));
    }
  }

  double wheelDiameter() {
    return min(500, MediaQuery.of(context).size.width);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(isLoading) {
      return Text("Lädt...".i18n);
    }
    return Column(
      children: [
        ColorPicker(
          heading: Text(
            'Farbauswahl',
            style: Theme.of(context).textTheme.headline5,
          ),
          color: pickerColor,
          onColorChanged: (color) => {
            changeColor(color, emit: widget.emitEventsSlowly == false)
          },
          onColorChangeEnd: (color) {
            print("Hi");
            updateIsColorSaved();
            if(widget.emitEventsSlowly) {
              widget.onChanged?.call(pickerColor);
            }
          },

          pickerTypeLabels: const <ColorPickerType, String>{
            ColorPickerType.both: "Palette",
            ColorPickerType.custom: "Gespeichert",
            ColorPickerType.wheel: "Farbrad"
          },
          maxRecentColors: 6,
          recentColorsSubheading: Text("Zuletzt verwendete Farben", style: Theme.of(context).textTheme.subtitle1),
          recentColors: recentColors,
          onRecentColorsChanged: (List<Color> colors) {
            setState(() {
              recentColors = colors;
              updateIsColorSaved();
            });
          },
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
          ),
          showRecentColors: true,
          wheelDiameter: wheelDiameter(),
          enableShadesSelection: true,
          tonalSubheading: const Text("Helligkeit"),
          showColorCode: true,
          showColorName: true,
          pickersEnabled: const <ColorPickerType, bool> {
            ColorPickerType.wheel: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.both: true,
            ColorPickerType.custom: true,
          },
          customColorSwatchesAndNames: colorsNameMap,
        ),
        TextButton.icon(label: Text("Zufallsfarbe"), icon: Icon(Icons.shuffle), onPressed: () {
          changeColor(Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
          updateIsColorSaved();
        },)
      ]
    );
  }
}

class ColorScaffoldWidget extends StatefulWidget {
  Function? save;
  Function? delete;
  bool emitSlowly = true;
  Duration emitDuration = Duration(milliseconds: 400);

  String formatTime() {
    var minutes = emitDuration.inMinutes.remainder(60);
    var seconds = emitDuration.inSeconds.remainder(60);
    var millis = emitDuration.inMilliseconds.remainder(1000);
    var str = "";
    if(minutes > 0) {
      str+= "${minutes} Minuten ";
    }
    if(seconds > 0) {
      str+= "${seconds} Sekunden ";
    }
    if(millis > 0) {
      str+= "${millis} Millisekunden ";
    }
    if(str.trim().isEmpty) {
      return "Ohne Zeitverzögerung";
    }
    return str.trim();
  }

  @override
  State<StatefulWidget> createState() => _ColorScaffoldWidgetState();
}

class _ColorScaffoldWidgetState extends State<ColorScaffoldWidget> with TickerProviderStateMixin {
  BluetoothController controller = BluetoothControllerWidget();
  bool _colorExists = false;
  final ColorSaveController saveController = ColorSaveController();

  late Animation<double> _myAnimation;
  late AnimationController _controller;
  bool timeIsExtended = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _myAnimation = CurvedAnimation(
        curve: Curves.linear,
        parent: _controller
    );
  }

  @override
  Widget build(BuildContext context) {
    ValueChanged<bool>? onColorSave;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: Column(
            children: [
              ColorsWidget(
                emitEventsSlowly: widget.emitSlowly,
                controller: saveController,
                onChanged: (color) {
                  Persistence().setColor(color);
                  if(!widget.emitSlowly) {
                    controller.broadcast(ColorMessage(color.red.toInt(), color.green.toInt(), color.blue.toInt(), color.alpha.toInt()));
                  } else {
                    controller.broadcast(FadeMessage(duration: widget.emitDuration, color: color));
                  }
                },
                onColorExistsChange: (exists) => setState(() { _colorExists = exists; }),
              ),
              Text(
                "Sendeoptionen",
                style: Theme.of(context).textTheme.headline5,
              ),
              CheckboxListTile(value: widget.emitSlowly, onChanged: (v) => {
                setState(() {
                  widget.emitSlowly = v ?? false;
                })
              }, title: Text("Glatte Übergänge")),
              ListTile(
                title: TextButton(
                  onPressed: () {
                    setState(() { timeIsExtended = !timeIsExtended;});
                    if(timeIsExtended) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                  child: RichText(
                      text: TextSpan(children: [
                        TextSpan(text: "Dauer: ", style: Theme.of(context).textTheme.bodyMedium),
                        WidgetSpan(child: Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.inverseSurface)),
                        TextSpan(text: " ${widget.formatTime()}", style: Theme.of(context).textTheme.bodyMedium)
                      ])),
                ),
                trailing: IconButton(
                  icon: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: Icon(Icons.expand_more),
                  ),
                  onPressed: () {
                    setState(() {
                      timeIsExtended = !timeIsExtended;
                    });
                    if(timeIsExtended) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: timeIsExtended ? 200 : 0.00000001,
                child: TimePicker(
                  startDuration: widget.emitDuration,
                  onChanged: (t) => {
                    setState(() {
                      widget.emitDuration = t;
                    })
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_colorExists) {
            saveController.delete?.call();
          } else {
            saveController.save?.call();
          }
        },
        child: _colorExists ? const Icon(Icons.delete) : const Icon(Icons.save),

      ),
    );
  }
}