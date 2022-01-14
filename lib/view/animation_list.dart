import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';

import 'package:starklicht_flutter/model/animation.dart';
import 'package:starklicht_flutter/model/models.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:starklicht_flutter/view/animations.dart';

class AnimationsWidget extends StatefulWidget {
  const AnimationsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationsWidgetState();
}

class _AnimationsWidgetState extends State<AnimationsWidget> {
  List<KeyframeAnimation> animations = [];
  final BluetoothController controller = BluetoothControllerWidget();


  void edit() {

    print("Test");
  }

  void load() {
    Persistence().getAnimationStore().then((i) => {
      setState(() {
        animations = i;
      })
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void send(KeyframeAnimation animation) {
    controller.broadcast(
        AnimationMessage(animation.colors, animation.config)
    );
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        itemCount: animations.isEmpty?1:animations.length,
        itemBuilder: (BuildContext context, int index) {
          if(animations.isEmpty) {
            return Padding(
                padding: EdgeInsets.only(top: 140),
                child: Column(
                    children: [
                      Image.asset('assets/question-mark.png'),
                      const Text(
                        "Keine gespeicherten Animationen\n",
                        style: TextStyle(
                            fontSize: 20
                        ),
                      ),
                      const Text(
                        "Im Bereich \"Animation\" kannst du Animationen erstellen und speichern.\n",
                        style: TextStyle(
                            color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ]
                )
            );
          }
          else {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              margin: EdgeInsets.all(6.0),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                onTap: () => send(animations[index]),
                  child: Padding(padding: EdgeInsets.only(top: 12, bottom: 12), child: Column(
                      children: [
                ListTile(
                  leading: AnimationPreviewWidget(
                    settings: AnimationSettingsConfig(
                      animations[index].config.interpolationType,
                      animations[index].config.timefactor,
                      animations[index].config.seconds,
                      animations[index].config.millis
                    ),
                    colors: GradientSettingsConfig(
                      animations[index].colors.map((e) => ColorPoint(e.color, e.point)).toList()
                    ),
                    callback: null,
                    restartCallback: {},
                    notify: {},
                    isEditorPreview: false,
                  ),
                  title: Text(animations[index].title),
                  subtitle: Text('${animations[index].toString()}'),
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: edit,
                        icon: const Icon(Icons.settings_remote)),
                    IconButton(
                        onPressed: edit, icon: const Icon(Icons.arrow_forward))
                  ],
                )*/
              ]))));
          }
        });
  }
}
