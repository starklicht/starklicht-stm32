import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
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
  Offset _tapDownPosition = Offset(0, 0);
  List<KeyframeAnimation> animations = [];
  String query = "";
  final BluetoothController controller = BluetoothControllerWidget();
  String currentNameRename = "";
  var t = TextEditingController();


  void edit() {
    print("Test");
  }

  List<KeyframeAnimation> filteredAnimations() {
    var a = animations;
    if(query.isNotEmpty) {
      a = animations.where((element) => element.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    a.sort((a, b) {
      return a.title.compareTo(b.title);
    });
    print(a.length);
    return a;
  }

  void load() {
    Persistence().getAnimationStore().then((i) => {
      setState(() {
        animations = i;
      })
    });
  }

  void deleteItem(String title) {
    Persistence().deleteAnimation(title).then((i) {
      if(i.length < animations.length) {
        // If length has changed, it has been deleted
        var snackBar = SnackBar(
          content: Text('Animation "$title" wurde gelöscht'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      setState(() {
        animations = i;
      });
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

    return Container(
        alignment: Alignment.center,
        child: ListView.builder(
        itemCount: animations.isEmpty?1:filteredAnimations().length+1,
        shrinkWrap: animations.isEmpty,
        itemBuilder: (BuildContext context, int index) {
          if(animations.isEmpty) {
            return Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                    children: [
                      Lottie.asset(
                      'assets/server.json',
		      width: 500
                      ),
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
          else if(index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Suche',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()
                ),
                onChanged: (text) {
                  setState(() {
                    query = text;
                  });
                },
                textCapitalization: TextCapitalization.sentences,
              ),
            );
          }
          else {
            var realIndex = index - 1;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              margin: EdgeInsets.all(6.0),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                onTapDown: (TapDownDetails details) {
                  _tapDownPosition = details.globalPosition;
                },
                onTap: () => send(filteredAnimations()[realIndex]),
                onLongPress: () {
                  final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
                  showMenu(
                      context: context,
                      position: RelativeRect.fromRect(_tapDownPosition & const Size(40, 40), Offset.zero & overlay.size),
                      items: <PopupMenuEntry> [
                        PopupMenuItem(child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text("Editieren"),
                        ),
                          onTap: () {
                            Persistence().saveEditorAnimation(filteredAnimations()[realIndex]);
                            var snackBar = const SnackBar(
                              content: Text('Animation kann jetzt im Abschnitt "Animation" bearbeitet werden'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          },
                          value: 0
                        ),
                        PopupMenuItem(child: const ListTile(
                          leading: Icon(Icons.drive_file_rename_outline_sharp),
                          title: Text("Umbenennen"),
                        ),
                            onTap: () {
                              setState(() {
                                currentNameRename =  filteredAnimations()[realIndex].title;
                              });
                              t.text = currentNameRename;
                              Future.delayed(
                                const Duration(seconds: 0),
                                () =>
                                  showDialog(context: context, builder: (_) {
                                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                    return AlertDialog(
                                        title: Text("Umbenennen"),
                                        content: TextField(
                                          controller: t,
                                          onChanged: (v) => {
                                            setState(() {
                                              currentNameRename = v;
                                            })
                                          },
                                        ),
                                        actions: [
                                          TextButton(onPressed: () =>{
                                            Navigator.pop(context)
                                          }, child: Text("Abbrechen")),
                                          TextButton(onPressed: filteredAnimations()[realIndex].title == currentNameRename? null : () {
                                            var old = filteredAnimations()[realIndex].title;
                                            Persistence().rename(filteredAnimations()[realIndex].title, t.text).then((value) =>
                                            {
                                              load(),
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content:
                                                    Text('Animation "${old}" wurde zu "${t.text}" umbenannt')
                                                )
                                              ),
                                              Navigator.pop(context)
                                            });
                                          }, child: Text("Speichern")),
                                        ],
                                    );
                                  });
                                })
                              );
                              /* setState(() {
                                currentNameRename = filteredAnimations()[realIndex].title;
                              });
                              showDialog(context: context, builder: (_) {
                                return AlertDialog(
                                  title: Text("Umbenennen"),
                                  content: TextField(
                                    onChanged: (text) {
                                      setState(() {
                                        currentNameRename = text;
                                      });
                                    }
                                  ),
                                );
                              }); */
                            },
                            value: 1
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.delete), // your icon
                            title: Text("Löschen"),
                          ),
                          value: 2,
                          onTap: () => deleteItem(filteredAnimations()[realIndex].title),
                        ),
                      ]
                  );
                },
                child: Padding(padding: EdgeInsets.only(top: 12, bottom: 12), child: Column(
                    children: [
                ListTile(
                  leading: AnimationPreviewWidget(
                    settings: AnimationSettingsConfig(
                      filteredAnimations()[realIndex].config.interpolationType,
                      filteredAnimations()[realIndex].config.timefactor,
                      filteredAnimations()[realIndex].config.seconds,
                      filteredAnimations()[realIndex].config.millis
                    ),
                    colors: GradientSettingsConfig(
                      filteredAnimations()[realIndex].colors.map((e) => ColorPoint(e.color, e.point)).toList()
                    ),
                    callback: null,
                    restartCallback: {},
                    notify: {},
                    isEditorPreview: false,
                  ),
                  title: Text(filteredAnimations()[realIndex].title),
                  subtitle: Text('${filteredAnimations()[realIndex].toString()}'),
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
        }));
  }
}
