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
  int red, green, blue, master;

  ColorMessage(this.red, this.green, this.blue, this.master);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    if(inverse == false) {
      return [red, green, blue, master];
    } else {
      // Inverse color
      var c = Color.fromARGB(255, red, green, blue).inverse();
      return [c.red, c.green, c.blue, master];
    }
  }

  @override
  MessageType messageType = MessageType.color;
}