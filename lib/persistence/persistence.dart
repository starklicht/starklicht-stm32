
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starklicht_flutter/model/animation.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/redux.dart';
import 'package:starklicht_flutter/view/animations.dart';

abstract class IPersistence {
  Future<List<KeyframeAnimation>> getAnimationStore();
  void saveAnimation(KeyframeAnimation a);
  Future<List<KeyframeAnimation>> deleteAnimation(String title);
  Future<KeyframeAnimation?> findByName(String name);
  Future<bool> existsByName(String name);
  Future<bool> rename(String name, String newName);
  Future<List<KeyframeAnimation>> save(List<KeyframeAnimation> newValues);
}

class Persistence implements IPersistence {
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

  @override
  Future<List<KeyframeAnimation>> deleteAnimation(String title) async {
    var currentAnimations = await getAnimationStore();
    currentAnimations.removeWhere((element) => element.title == title);
    print(currentAnimations.length);
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setStringList(
        animationStore,
        currentAnimations.map((e) => jsonEncode(e.toJson())).toList()
    );
    return currentAnimations;
  }

  @override
  Future<KeyframeAnimation?> findByName(String name) async {
    var currentAnimations = await getAnimationStore();
    return currentAnimations.firstWhereOrNull((element) => element.title == name);
  }

  @override
  Future<bool> existsByName(String name) async {
    var a = await findByName(name);
    return a != null;
  }

  @override
  Future<bool> rename(String name, String newName) async {
    if(name == newName) {
      return false;
    }
    var l = await getAnimationStore();
    if(l.indexWhere((element) => element.title == newName) > -1) {
      throw Exception("Konnte nicht umbenannt werden, da Animation ${newName} schon existiert");
    }
    var index = l.indexWhere((element) => element.title == name);
    if(index == -1) {
      throw Exception("Konnte nicht umbenannt werden, da Animation ${name} nicht existiert");
    }
    l[index].title = newName;
    save(l);
    return true;
  }

  @override
  Future<List<KeyframeAnimation>> save(List<KeyframeAnimation> newValues) async {
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setStringList(
        animationStore,
        newValues.map((e) => jsonEncode(e.toJson())).toList()
    );
    return newValues;
  }
}