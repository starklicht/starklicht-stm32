
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starklicht_flutter/model/animation.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/redux.dart';
import 'package:starklicht_flutter/view/animations.dart';

abstract class IPersistence {
  List<KeyframeAnimation> getAnimationStore();
  void saveAnimation(KeyframeAnimation a);
  KeyframeAnimation? findByName(String name);
}

class Persistence {
  static KeyframeAnimation defaultEditorAnimation = KeyframeAnimation(
    [
      ColorPoint(Colors.black, 0),
      ColorPoint(Colors.white, 1),
    ],
    AnimationSettingsConfig(
      InterpolationType.linear,
      TimeFactor.repeat,
      1,
      0
    ),
    "Default"
  );
  static const String animationStore = "animations";
  static const String editorAnimation = "editor-animation";
  Future<List<KeyframeAnimation>> getAnimationStore() async {
    final prefs = await SharedPreferences.getInstance();
    var animations = prefs.getStringList(animationStore);
    var fac = KeyframeAnimationFactory();
    if(animations == null) {
      return [];
    }
    return animations.map((e) => fac.build(e)).toList();
  }

  Future<void> saveAnimation(KeyframeAnimation a) async {
    // TODO: implement saveAnimation
    var currentAnimations = await getAnimationStore();
    print(currentAnimations);
    var i = currentAnimations.indexWhere((element) => element.title == a.title);
    if(i > -1) {
      currentAnimations[i] = a;
    } else {
      currentAnimations.add(a);
    }
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setStringList(
        animationStore,
        currentAnimations.map((e) => jsonEncode(e.toJson())).toList()
    );
  }
  
  Future<KeyframeAnimation> getEditorAnimation() async {
    final prefs = await SharedPreferences.getInstance();
    var animation = prefs.getString(editorAnimation);
    if(animation == null) {
      return defaultEditorAnimation;
    }
    return KeyframeAnimationFactory().build(animation);
  }

  Future<void> saveEditorAnimation(KeyframeAnimation a) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(editorAnimation, jsonEncode(a.toJson()));
  }

  // Global Settings
  static const String brightness = "brightness";
  static int defaultBrightness = 100;
  Future<int> getBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(brightness) ?? defaultBrightness;
  }

  Future<void> setBrightness(int i) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(brightness, i);
  }

  static const String color = "color";
  static Color defaultColor = Colors.black;
  Future<Color> getColor() async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt(color) ?? defaultColor.value);
  }

  Future<void> setColor(Color i) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(color, i.value);
  }

}