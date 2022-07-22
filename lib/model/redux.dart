import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/view/animations.dart';

enum Actions {
  SetAnimationSettingsConfig
}

class AnimationSettingsConfig {
  InterpolationType interpolationType;
  TimeFactor timefactor;
  int minutes;
  int seconds;
  int millis;
  Function? callback;

  AnimationSettingsConfig(
      this.interpolationType,
      this.timefactor,
      this.minutes,
      this.seconds,
      this.millis,
      );

  Map<String, dynamic> toJson() => {
    'interpolationType': interpolationType.index,
    'timeFactor': timefactor.index,
    'minutes': minutes,
    'millis': millis,
    'seconds': seconds
  };

}

class GradientSettingsConfig {
  List<ColorPoint> colors;
  Function? callback;

  GradientSettingsConfig(
      this.colors,
      );
}