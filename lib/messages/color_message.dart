import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';

import 'imessage.dart';

extension on Color {
  Color inverse() {
    var hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
    if(hsv.hue > 180) {
      hsv = hsv.withHue(hsv.hue - 180);
    } else {
      hsv = hsv.withHue(hsv.hue + 180);
    }
    return hsv.toColor();
  }
}


class ColorMessage extends IBluetoothMessage {
  int maxValue = 255;
  late int red, green, blue, master;

  ColorMessage(this.red, this.green, this.blue, this.master);

  ColorMessage.fromColor(Color color) {
    red = color.red;
    green = color.green;
    blue = color.blue;
    master = color.alpha;
  }


  @override
  List<int> getMessageBody({ bool inverse = false }) {
    if(inverse == false) {
      return [red, green, blue, master];
    } else {
      // Inverse color
      var c = toColor().inverse();
      return [c.red, c.green, c.blue, master];
    }
  }

  @override
  Color toColor() {
    // TODO: implement toColor
    return Color.fromARGB(255, red, green, blue);
  }

  @override
  String retrieveText() {
    return ColorTools.nameThatColor(toColor());
  }

  @override
  MessageType messageType = MessageType.color;
}