import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/view/animations.dart';

class BaseColorAnimation extends Animatable<Color?> {
  List<ColorPoint> _points;
  bool _randomize;
  final _random = Random();
  double lastValue = 0;
  double nextValue = 0;
  double lastTime = 0;

  BaseColorAnimation(this._points, this._randomize) {
    sort();
    nextValue = _random.nextDouble();
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

  Color? gradientScale(double t) {
    var leftSelect = selectLeft(t);
    var rightSelect = selectRight(t);
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

  List<ColorPoint> selectLeft(double t) {
    var l = _points.where((element) => element.point <= t).toList();
    l.sort((a, b) => b.point.compareTo(a.point));
    return l;
  }

  List<ColorPoint> selectRight(double t) {
    var r = _points.where((element) => element.point > t).toList();
    r.sort((a, b) => a.point.compareTo(b.point));
    return r;
  }


  double interpolate(double t) {
    if(_randomize) {
      if (t < lastTime) {
        lastValue = nextValue;
        nextValue = _random.nextDouble();
      }
      lastTime = t;
      return (1 - t) * lastValue + (t) * nextValue;
    }
    return t;
  }

  @override
  Color? transform(double t) {
    return gradientScale(interpolate(t));
  }
}
class ConstantColorAnimator extends BaseColorAnimation {
  ConstantColorAnimator(List<ColorPoint> points, bool randomize) : super(points, randomize);

  @override
  Color? transform(double t) {
    if(_randomize) {
      if (t < lastTime) {
        nextValue = _random.nextDouble();
      }
      lastTime = t;
      return gradientScale(nextValue);
    }
    var l = selectLeft(t);
    var r = selectRight(t);
    if(l.isEmpty) {
      return r[0].color;
    } else if(r.isEmpty) {
      return l[0].color;
    }
    var m = [l[0], r[0]];
    var tt = map(t, m[0].point, m[1].point, 0, 1);
    var i = IntTween(begin: 0, end: 1).lerp(tt);
    return m[i].color;
  }
}