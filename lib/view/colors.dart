
import 'dart:math';
import 'dart:ui';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import '../i18n/colors.dart';

class ColorSaveController {
  Function? save;
  Function? delete;
}

class ColorsWidget extends StatefulWidget {
  Color? startColor;
  ValueChanged<Color>? onChanged;
  ValueChanged<bool>? onColorExistsChange;
  ColorSaveController? controller;
  ColorsWidget({Key? key, this.startColor, this.onChanged, this.onColorExistsChange, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorsWidgetState();
}

class _ColorsWidgetState extends State<ColorsWidget> {
  bool isLoading = false;

  Map<ColorSwatch<Object>, String> colorsNameMap =
  <ColorSwatch<Object>, String>{
  };

  bool _hexValid = true;
  String _currentHex = "";
  bool _colorIsSaved = false;
  var _formKey = GlobalKey<FormState>();

  // create some values
  Color pickerColor = Color(0xff000000);
  List<Color> recentColors = [];


// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
    widget.onChanged?.call(pickerColor);
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
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              ColorPicker(
                heading: Text(
                  'Farbauswahl',
                  style: Theme.of(context).textTheme.headline5,
                ),
                color: pickerColor,
                onColorChanged: (color) => {
                  changeColor(color)
                },
                onColorChangeEnd: (color) {
                  print("Hi");
                  updateIsColorSaved();
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
                tonalSubheading: Text("Helligkeit"),
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
            ]
          ),
        )
    );
  }
}

class ColorScaffoldWidget extends StatefulWidget {
  Function? save;
  Function? delete;
  @override
  State<StatefulWidget> createState() => _ColorScaffoldWidgetState();
}

class _ColorScaffoldWidgetState extends State<ColorScaffoldWidget> {
  BluetoothController controller = BluetoothControllerWidget();
  bool _colorExists = false;
  final ColorSaveController saveController = ColorSaveController();

  @override
  Widget build(BuildContext context) {
    ValueChanged<bool>? onColorSave;
    return Scaffold(
      body: ColorsWidget(
        controller: saveController,
        onChanged: (color) {
          Persistence().setColor(color);
          controller.broadcast(ColorMessage(color.red.toInt(), color.green.toInt(), color.blue.toInt(), color.alpha.toInt()));
        },
        onColorExistsChange: (exists) => setState(() { _colorExists = exists; }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_colorExists) {
            saveController.delete?.call();
          } else {
            saveController.save?.call();
          }
        },
        child: _colorExists ? Icon(Icons.delete) : Icon(Icons.save),

      ),
    );
  }
}