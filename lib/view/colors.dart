
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

class ColorsWidget extends StatefulWidget {
  bool sendOnChange;
  Color? startColor;
  Function? changeCallback;
  bool hideLayout;
  ColorsWidget({Key? key, required this.sendOnChange, this.startColor, this.changeCallback, this.hideLayout = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorsWidgetState();
}

class _ColorsWidgetState extends State<ColorsWidget> {
  double _red = 0;
  double _green = 0;
  double _blue = 0;
  double _alpha = 0;
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
  BluetoothController controller = BluetoothControllerWidget();
  List<Color> recentColors = [];


// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
      _red = color.red.toDouble();
      _green = color.green.toDouble();
      _blue = color.blue.toDouble();
      _alpha = color.alpha.toDouble();
    });
    widget.changeCallback?.call(pickerColor);
    if(widget.sendOnChange) {
      // Also, save the color...
      Persistence().setColor(pickerColor);
      controller.broadcast(ColorMessage(_red.toInt(), _green.toInt(), _blue.toInt(), _alpha.toInt()));
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
  }


  @override
  void initState() {
    super.initState();
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
          _red = widget.startColor!.red.toDouble();
          _green = widget.startColor!.green.toDouble();
          _blue = widget.startColor!.blue.toDouble();
          _alpha = widget.startColor!.alpha.toDouble();
        })
      });
    } else if(widget.sendOnChange) {
      // Load from state
      setState(() {
        isLoading = true;
      });
      // TODO: Error logs
      Persistence().getColor().then((i) => {
      setState(() {
        pickerColor = i;
        updateIsColorSaved();
        _red = i.red.toDouble();
        _green = i.green.toDouble();
        _blue = i.blue.toDouble();
        _alpha = i.alpha.toDouble();
      })
      }).then((value) => Persistence().loadCustomColors().then((e) => {
        setState(() {
          var nMap = e.map((e) => MapEntry(ColorTools.createPrimarySwatch(e), ""));
          colorsNameMap = { for (var item in nMap) item.key : item.value };
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
          padding: widget.hideLayout ? const EdgeInsets.all(0) : const EdgeInsets.only(bottom: 56),
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
              if(_colorIsSaved && !widget.hideLayout) ...[
                TextButton.icon(
                    onPressed: () => {
                      setState(() {
                        var nMap = colorsNameMap.entries.where((element) => element.key.value != pickerColor.value);
                        colorsNameMap = { for (var item in nMap) item.key : item.value };
                        Persistence().saveCustomColors(colorsNameMap.keys.map((e) => e).toList());
                        updateIsColorSaved();
                      })
                    },
                    label: Text("Löschen"),
                    icon: Icon(Icons.delete)
                )
              ] else if(!widget.hideLayout)...[
                TextButton.icon(
                    onPressed: () {
                      setState(() {
                        var nMap = colorsNameMap.entries.toList();
                        nMap.add(MapEntry(ColorTools.createPrimarySwatch(pickerColor), "New Color"));
                        colorsNameMap = { for (var item in nMap) item.key : item.value };
                        Persistence().saveCustomColors(colorsNameMap.keys.map((e) => e).toList());
                        updateIsColorSaved();
                      });
                    },
                    label: Text("Speichern"),
                    icon: Icon(Icons.save)
                )
              ]
            ],
          ),
        )
    );
  }
}