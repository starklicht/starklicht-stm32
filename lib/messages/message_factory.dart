import 'dart:convert';
import 'dart:ui';

import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/messages/imessage.dart';
import 'package:starklicht_flutter/model/factory.dart';

import '../model/enums.dart';
import '../model/redux.dart';
import '../view/animations.dart';
import 'animation_message.dart';

abstract class IMessageFactory<T> extends Factory<T> {}

class ColorMessageFactory extends IMessageFactory<ColorMessage> {
  @override
  ColorMessage build(String params) {
    var json = jsonDecode(params);
    int color = json['data']['color'];
    return ColorMessage.fromColor(Color(color));
  }
}

class BrightnessMessageFactory extends IMessageFactory<BrightnessMessage> {
  @override
  BrightnessMessage build(String params) {
    var json = jsonDecode(params);
    int brightness = json['data']['brightness'];
    return BrightnessMessage(brightness);
  }
}

class AnimationMessageFactory extends IMessageFactory<AnimationMessage> {
  @override
  AnimationMessage build(String params) {
    var json = jsonDecode(params);
    print(json);
    var colors = (json['colors'] as List<dynamic>).map((e) => ColorPoint(
        Color(e['color'] as int),
        e['point'] as double
    )).toList();
    var animationSettings = AnimationSettingsConfig(
      // InterpolationType.linear,
      // TimeFactor.repeat,
        InterpolationType.values[json['config']['interpolationType'] as int],
        TimeFactor.values[json['config']['timeFactor'] as int],
        json['config']['minutes'] as int? ?? 0,
        json['config']['seconds'] as int,
        json['config']['millis'] as int
    );
    return AnimationMessage(
        colors,
        animationSettings,
        title: json['title']
    );
  }
}