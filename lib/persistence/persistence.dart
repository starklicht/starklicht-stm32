
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:starklicht_flutter/model/animation.dart';

abstract class IPersistence {
  List<KeyframeAnimation> getAnimationStore();
  void saveAnimation(KeyframeAnimation a);
  KeyframeAnimation? findByName(String name);
}

class Persistence {
  static const String animationStore = "animations";
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

}