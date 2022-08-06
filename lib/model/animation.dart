
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
      // InterpolationType.linear,
      // TimeFactor.repeat,
      InterpolationType.values[json['config']['interpolationType'] as int],
      TimeFactor.values[json['config']['timeFactor'] as int],
      json['config']['minutes'] as int? ?? 0,
      json['config']['seconds'] as int,
      json['config']['millis'] as int
    );
    return KeyframeAnimation(
        colors,
        animationSettings,
        json['title']
    );
  }

}

// TODO: Get rid of this, it has the same data as Animation Message.
class KeyframeAnimation {
  final List<ColorPoint> _colors;
  final AnimationSettingsConfig _config;
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
        '${config.seconds}s ${config.millis}ms (${config.interpolationType.toString().split('.')[1]}) - ${colors.length} Farben';
  }

  AnimationSettingsConfig get config => _config;

  copy() {
    return KeyframeAnimation(
      _colors.map((e) => ColorPoint(e.color, e.point)).toList(),
      AnimationSettingsConfig(
        _config.interpolationType,
        _config.timefactor,
        _config.minutes,
        _config.seconds,
        _config.millis
      ),
      title
    );
  }
}