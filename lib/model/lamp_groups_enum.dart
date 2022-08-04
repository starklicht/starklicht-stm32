
import 'package:flutter/material.dart';

enum LampGroups {
  FILL, KEY, BACK, ATMOSPHERE, EFFECT
}

extension LampGroupsExtension on LampGroups {
  IconData get icon {
    switch (this) {
      case LampGroups.FILL:
        return Icons.lightbulb_circle;
      case LampGroups.KEY:
        return Icons.lightbulb_outline;
      case LampGroups.BACK:
        return Icons.lightbulb_circle_outlined;
      case LampGroups.ATMOSPHERE:
        return Icons.landscape;
      case LampGroups.EFFECT:
        return Icons.local_fire_department;
    }
  }
}