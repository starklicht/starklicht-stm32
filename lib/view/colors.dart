
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/color_message.dart';

class ColorsWidget extends StatefulWidget {
  const ColorsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorsWidgetState();
}

class _ColorsWidgetState extends State<ColorsWidget> {
  double _red = 0;
  double _green = 0;
  double _blue = 0;
  double _alpha = 0;

  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
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
    controller.broadcast(ColorMessage(_red.toInt(), _green.toInt(), _blue.toInt(), _alpha.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      Slider(
          value: _red,
          min: 0,
          activeColor: Colors.red,
          max: 255,
          onChanged: (value) {
            setState(() {
              _red = value;
              pickerColor = Color.fromARGB(255, _red.toInt(), _green.toInt(), _blue.toInt());
              controller.broadcast(ColorMessage(_red.toInt(), _green.toInt(), _blue.toInt(), pickerColor.alpha));
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
              pickerColor = Color.fromARGB(255, _red.toInt(), _green.toInt(), _blue.toInt());
              controller.broadcast(ColorMessage(_red.toInt(), _green.toInt(), _blue.toInt(), pickerColor.alpha));
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
              pickerColor = Color.fromARGB(255, _red.toInt(), _green.toInt(), _blue.toInt());
              controller.broadcast(ColorMessage(_red.toInt(), _green.toInt(), _blue.toInt(), pickerColor.alpha));
            });
          }
      ),
      ColorPicker(
        pickerColor: pickerColor,
        onColorChanged: changeColor,
        showLabel: true,
        pickerAreaHeightPercent: 0.8,
      ),
    ]);
  }

}