import 'package:flutter/material.dart';

import 'imessage.dart';

class BrightnessMessage extends IBluetoothMessage<int> {
  int brightness;

  BrightnessMessage(this.brightness);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    return [
      brightness
    ];
  }

  @override
  void setValue(int value) {
    brightness = value;
    if(brightness > 100) {
      brightness = 100;
    } else if(brightness < 0) {
      brightness = 0;
    }
  }

  @override
  double toPercentage() {
    return brightness.toDouble() / 100.0;
  }

  @override
  bool displayAsProgressBar() {
    return true;
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