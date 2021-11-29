import 'package:flutter/foundation.dart';
import 'package:starklicht_flutter/model/enums.dart';

enum Actions {
  SetAnimationSettingsConfig
}

@immutable
class AnimationSettingsConfig {
  final InterpolationType interpolationType;
  final TimeFactor timefactor;
  final int seconds;
  final int millis;

  const AnimationSettingsConfig(
      this.interpolationType,
      this.timefactor,
      this.seconds,
      this.millis
      );
}