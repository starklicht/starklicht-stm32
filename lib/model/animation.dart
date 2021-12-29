
import 'dart:convert';
import 'dart:ui';

import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/factory.dart';
import 'package:starklicht_flutter/model/redux.dart';
import 'package:starklicht_flutter/view/animations.dart';

class KeyframeAnimationFactory extends Factory<KeyframeAnimation> {
  @override
  KeyframeAnimation build(String params) {
    var json = jsonDecode(params);
    print(json);
    var colors = (json['colors'] as List<dynamic>).map((e) => ColorPoint(
      Color(e['color'] as int),
      e['point'] as double
    )).toList();
    var animationSettings = AnimationSettingsConfig(
      InterpolationType.linear,
      TimeFactor.repeat,
      json['config']['seconds'] as int,
      json['config']['millis'] as int,
    );
    return KeyframeAnimation(
        colors,
        animationSettings,
        json['title']
    );
  }

}

class KeyframeAnimation {
  List<ColorPoint> _colors;
  AnimationSettingsConfig _config;
  String title;

  List<ColorPoint> get colors => _colors;

  KeyframeAnimation(this._colors, this._config, this.title);

  Map<String, dynamic> toJson() => {
    'title': title,
    'config': _config.toJson(),
    'colors': _colors.map((e) => e.toJson()).toList()
  };


  @override
  String toString() {
    return ''
        '${config.seconds}s ${config.millis}ms';
  }

  AnimationSettingsConfig get config => _config;
}