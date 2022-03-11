
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';

class ColorsWidget extends StatefulWidget {
  bool sendOnChange;
  Color? startColor;
  Function? changeCallback;
  ColorsWidget({Key? key, required this.sendOnChange, this.startColor, this.changeCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorsWidgetState();
}

class _ColorsWidgetState extends State<ColorsWidget> {
  double _red = 0;
  double _green = 0;
  double _blue = 0;
  double _alpha = 0;
  bool isLoading = false;

  bool _hexValid = true;
  String _currentHex = "";

  var _formKey = GlobalKey<FormState>();

  // create some values
  Color pickerColor = Color(0xff000000);
  BluetoothController controller = BluetoothControllerWidget();



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


  @override
  void initState() {
    super.initState();
    if(widget.startColor != null) {
      setState(() {
        pickerColor = widget.startColor!;
        _red = widget.startColor!.red.toDouble();
        _green = widget.startColor!.green.toDouble();
        _blue = widget.startColor!.blue.toDouble();
        _alpha = widget.startColor!.alpha.toDouble();
      });
    } else if(widget.sendOnChange) {
      // Load from state
      setState(() {
        isLoading = true;
      });
      Persistence().getColor().then((i) => {
      setState(() {
        pickerColor = i;
        _red = i.red.toDouble();
        _green = i.green.toDouble();
        _blue = i.blue.toDouble();
        _alpha = i.alpha.toDouble();
        isLoading = false;
      })
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(isLoading) {
      return Text("Lädt...");
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Slider(
          value: _red,
          min: 0,
          activeColor: Colors.red,
          max: 255,
          onChanged: (value) {
            setState(() {
              _red = value;
              changeColor(Color.fromARGB(pickerColor.alpha, _red.toInt(), _green.toInt(), _blue.toInt()));
            });
          }
      ),
      Slider(
          value: _green,
          min: 0,
          activeColor: Colors.green,
          max: 255,
          onChanged: (value) {
            setState(() {
              _green = value;
              changeColor(Color.fromARGB(pickerColor.alpha, _red.toInt(), _green.toInt(), _blue.toInt()));
            });
          }
      ),
      Slider(
          value: _blue,
          min: 0,
          activeColor: Colors.blue,
          max: 255,
          onChanged: (value) {
            setState(() {
              _blue = value;
              changeColor(Color.fromARGB(pickerColor.alpha, _red.toInt(), _green.toInt(), _blue.toInt()));
            });
          }
      ),
      ColorPicker(
        pickerColor: pickerColor,
        onColorChanged: changeColor,
        pickerAreaBorderRadius: BorderRadius.all(Radius.circular(12)),
        showLabel: false,
        displayThumbColor: true,
        enableAlpha: false,
        pickerAreaHeightPercent: 1,
        colorPickerWidth: 300,
        paletteType: PaletteType.hsv
      ),
      TextButton(
          onPressed: () {
        showDialog(context: context, builder: (_) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
            title: Text("Farbcode eingeben"),
            content: Form(
              key: _formKey,
              onChanged: () => setState(() {
                _hexValid = _formKey.currentState!.validate();
              }),
                child: TextFormField(
                  onSaved: (v) => { _currentHex = v! },
              initialValue: getColorText(),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Hex-Code unvollständig';
                }
                if(!RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(value)) {
                  return 'Kein valider Hex-Code';
                }
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(6)
              ],
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon:Text("#"),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            )),
            actions: [
              TextButton(child:Text("Abbrechen"), onPressed: () => {
                Navigator.pop(context)
              }),
              TextButton(child:Text("Übernehmen"),
                  onPressed: _hexValid?
                  () => {
                    _formKey.currentState?.save(),
                    changeColor(_getColorFromHex(_currentHex)),
                    Navigator.pop(context)
                  }
                                :
                  null
              )
            ],
          );});
        });
      }, child: Text("#${getColorText()}"))
    ]);
  }
}