import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/models.dart';
import 'package:starklicht_flutter/view/animations.dart';

import 'imessage.dart';

class AnimationMessage extends IBluetoothMessage {
  List<ColorPoint> _colors;
  AnimationSettingsConfig _config;

  AnimationMessage(this._colors, this._config);

  @override
  bool get withoutResponse => false;

  @override
  List<int> getMessageBody() {
    var b = [
      // Length of messages
      _colors.length,
      buildInterpolationType(),
      // Is Restart
      _config.timefactor==TimeFactor.pingpong?1:0,
      // SECONDS
      _config.seconds,
      // Milliseconds
      (_config.millis / 50).round(),
      // Write all colors
      ...getColorsArray(),
    ];
    print(b);
    return b;
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

  List<int> getColorsArray() {
    List<int> l = [];
    for (var c in _colors) {
      l.add((c.point * 255).round());
      l.add((c.color.red));
      l.add((c.color.green));
      l.add((c.color.blue));
      l.add((c.color.alpha));
    }
    return l;
  }

  @override
  MessageType messageType = MessageType.interpolated;
}