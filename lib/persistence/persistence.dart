
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/redux.dart';
import 'package:starklicht_flutter/view/animations.dart';

import '../messages/animation_message.dart';
import '../messages/message_factory.dart';

abstract class IPersistence {
  Future<List<AnimationMessage>> getAnimationStore();
  Future<List<AnimationMessage>> saveAnimation(AnimationMessage a);
  Future<List<AnimationMessage>> deleteAnimation(String title);
  Future<AnimationMessage?> findByName(String name);
  Future<bool> existsByName(String name);
  Future<bool> rename(String name, String newName);
  Future<List<AnimationMessage>> save(List<AnimationMessage> newValues);
  Future<StarklichtBluetoothOptions> getBluetoothOption(String id);
  Future<bool> hasBluetoothOption(String id);
  Future<StarklichtBluetoothOptions> setBluetoothOption(String id, StarklichtBluetoothOptions option);
}

class Persistence implements IPersistence {
  static final Persistence _instance = Persistence._internal();
  factory Persistence() => _instance;
  Persistence._internal();
  static const String optionsPrefix = "OPTIONS_";

  static AnimationMessage defaultEditorAnimation = AnimationMessage(
    [
      ColorPoint(Colors.black, 0),
      ColorPoint(Colors.white, 1),
    ],
    AnimationSettingsConfig(
      InterpolationType.linear,
      TimeFactor.repeat,
      0,
      1,
      0
    ),
  );
  static const String animationStore = "animations";
  static const String colors = "colors";
  static const String editorAnimation = "editor-animation";

  @override
  Future<List<AnimationMessage>> getAnimationStore() async {
    final prefs = await SharedPreferences.getInstance();
    var animations = prefs.getStringList(animationStore);
    var fac = AnimationMessageFactory();
    if(animations == null) {
      return [];
    }
    return animations.map((e) => fac.build(e)).toList();
  }

  Future<void> saveCustomColors(List<Color> c) async {
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setStringList(colors, c.map((e) => e.value.toString()).toList());
  }

  Future<List<Color>> loadCustomColors() async {
    var sPrefs = await SharedPreferences.getInstance();
    if(!sPrefs.containsKey(colors)) {
      return [];
    }
    var colorList = sPrefs.getStringList(colors);
    return colorList!.map((e) => Color(int.parse(e))).toList();
  }

  @override
  Future<List<AnimationMessage>> saveAnimation(AnimationMessage a) async {
    assert(a.title != null);
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
    return currentAnimations;
  }
  
  Future<AnimationMessage> getEditorAnimation() async {
    final prefs = await SharedPreferences.getInstance();
    var animation = prefs.getString(editorAnimation);
    if(animation == null) {
      return defaultEditorAnimation;
    }
    return AnimationMessageFactory().build(animation);
  }

  Future<void> saveEditorAnimation(AnimationMessage a) async {
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
  Future<List<AnimationMessage>> deleteAnimation(String title) async {
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
  Future<AnimationMessage?> findByName(String name) async {
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
      throw Exception("Konnte nicht umbenannt werden, da Animation $newName schon existiert");
    }
    var index = l.indexWhere((element) => element.title == name);
    if(index == -1) {
      throw Exception("Konnte nicht umbenannt werden, da Animation $name nicht existiert");
    }
    l[index].title = newName;
    save(l);
    return true;
  }

  @override
  Future<List<AnimationMessage>> save(List<AnimationMessage> newValues) async {
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setStringList(
        animationStore,
        newValues.map((e) => jsonEncode(e.toJson())).toList()
    );
    return newValues;
  }

  @override
  Future<StarklichtBluetoothOptions> getBluetoothOption(String id) async {
    var sPrefs = await SharedPreferences.getInstance();
    var json = sPrefs.getString("$optionsPrefix$id");
    if(json == null) {
      return setBluetoothOption(id, StarklichtBluetoothOptions(id));
    }
    return StarklichtBluetoothOptionsFactory().build(json);
  }

  @override
  Future<StarklichtBluetoothOptions> setBluetoothOption(String id, StarklichtBluetoothOptions option) async {
    var sPrefs = await SharedPreferences.getInstance();
    sPrefs.setString("$optionsPrefix$id", jsonEncode(option.toJson()));
    return option;
  }

  @override
  Future<bool> hasBluetoothOption(String id) async {
    var sPrefs = await SharedPreferences.getInstance();
    return sPrefs.containsKey("$optionsPrefix$id");
  }
}