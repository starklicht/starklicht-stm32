import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/view/animations.dart';

class BaseColorAnimation extends Animatable<Color?> {
  List<ColorPoint> _points;

  BaseColorAnimation(this._points) {
    sort();
  }

  sort() {
    _points.sort((a, b) => a.point.compareTo(b.point));
    print(_points.map((e) => e.point));
  }


  set points(List<ColorPoint> value) {
    _points = value;
    sort();
  }

  double map(
      double x, double in_min, double in_max, double out_min, double out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }

  @override
  Color? transform(double t) {
    var leftSelect = _points.where((element) => element.point <= t).toList();
    leftSelect.sort((a, b) => b.point.compareTo(b.point));
    var rightSelect = _points.where((element) => element.point > t).toList();
    rightSelect.sort((a, b) => a.point.compareTo(b.point));
    if(leftSelect.isEmpty) {
      return rightSelect[0].color;
    } else if(rightSelect.isEmpty) {
      return leftSelect[0].color;
    }
    ColorPoint leftTween = leftSelect[0];
    ColorPoint rightTween = rightSelect[0];
    // Transform time
    var tt = map(t, leftTween.point, rightTween.point, 0, 1);
    return Color.lerp(leftTween.color, rightTween.color, tt);
  }


}
class ConstantAnimator extends BaseColorAnimation {
  ConstantAnimator(List<ColorPoint> points) : super(points);



}