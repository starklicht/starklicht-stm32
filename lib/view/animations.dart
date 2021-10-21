
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimationsWidget extends StatefulWidget {
  const AnimationsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationsWidgetState();
}

class _AnimationsWidgetState extends State<AnimationsWidget> {
  List<String> animations = [];

  void edit () {
    print("Test");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    setState(() {
      animations.clear();
      for(var i = 0; i < 10; i++) {
        animations.add("Animation $i");
        print("Adding item $i");
      }
    });

    return ListView.builder(
      itemCount: animations.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: EdgeInsets.all(4.0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.red),
                title: Text(animations[index]),
                subtitle: Text('Beschreibung für sdf $index'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: edit,icon: const Icon(Icons.settings_remote)),
                  IconButton(onPressed: edit,icon: const Icon(Icons.arrow_forward))
              ],)
            ]
          )
        );
      }
    );
  }

}