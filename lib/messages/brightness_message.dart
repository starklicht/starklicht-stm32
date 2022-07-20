import 'package:flutter/material.dart';

import 'imessage.dart';

class BrightnessMessage extends IBluetoothMessage {
  int brightness;

  BrightnessMessage(this.brightness);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    return [
      brightness
    ];
  }

  @override
  Color toColor() {
    var col = ((brightness / 100.0) * 255).round();
    return Color.fromARGB(255, col, col, col);
  }

  @override
  String retrieveText() {
    return "$brightness%";
  }

  @override
  MessageType messageType = MessageType.brightness;
}