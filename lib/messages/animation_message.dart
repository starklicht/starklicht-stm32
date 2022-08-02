
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/models.dart';
import 'package:starklicht_flutter/view/animations.dart';

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

class AnimationMessage extends IBluetoothMessage {
  final List<ColorPoint> _colors;
  final AnimationSettingsConfig _config;
  String? title;
  int maxValue = 255;

  AnimationMessage(this._colors, this._config, { this.title });

  static AnimationMessage buildDefault() {
    return AnimationMessage([ColorPoint(Colors.white, 0), ColorPoint(Colors.black, 1)], AnimationSettingsConfig(
      InterpolationType.linear,
      TimeFactor.repeat,
      0,
      1,
      0,
    ), title: "Kleiner Test");
  }

  @override
  Gradient? toGradient() {
    return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors:
        List.from(_colors.map((e) => e.color)),
        stops: List.from(
        _colors.map((e) => e.point)));
  }

  @override
  bool get withoutResponse => false;

  @override
  bool get isGradient => true;

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    if(_config.seconds == 0 && _config.millis == 0 && _config.minutes == 0) {
      throw Exception("Time is 0!");
    }
    var b = [
      // Length of messages
      _colors.length,
      buildInterpolationType(),
      // Is Restart
      _config.timefactor==TimeFactor.pingpong?1:_config.timefactor==TimeFactor.once?2:0,
      // Integrate Seamlessly
      0,
      // MINUTES!
      _config.minutes,
      // SECONDS
      _config.seconds,
      // Milliseconds
      (_config.millis / 50).round(),
      // Write all colors
      ...getColorsArray(inverse),
    ];
    return b;
  }

  @override
  String retrieveText() {
    if(title == null) {
      return "Unbenannt";
    }
    return title!;
  }

  int buildInterpolationType() {
    switch(_config.interpolationType) {
      case InterpolationType.linear:
        if(_config.timefactor == TimeFactor.shuffle) {
          return 2;
        } else {
          return 0;
        }
      case InterpolationType.constant:
        if(_config.timefactor == TimeFactor.shuffle) {
          return 3;
        } else {
          return 1;
        }
    }
  }

  List<int> getColorsArray(bool inverse) {
    List<int> l = [];
    for (var c in _colors) {
      var col = Color.fromARGB(255, c.color.red, c.color.green, c.color.blue);
      l.add((c.point * 255).round());
      if(inverse) {
        col = col.inverse();
      }
      l.add((col.red));
      l.add((col.green));
      l.add((col.blue));
      l.add((c.color.alpha));
    }
    return l;
  }

  @override
  MessageType messageType = MessageType.interpolated;
}