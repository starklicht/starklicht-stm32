import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';

import 'package:starklicht_flutter/model/models.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:starklicht_flutter/view/animations.dart';
import '../i18n/animation_list.dart';

class AnimationsWidget extends StatefulWidget {
  const AnimationsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationsWidgetState();
}

class _AnimationsWidgetState extends State<AnimationsWidget> {
  Offset _tapDownPosition = const Offset(0, 0);
  List<AnimationMessage> animations = [];
  String query = "";
  final BluetoothController controller = BluetoothControllerWidget();
  String currentNameRename = "";
  var t = TextEditingController();
  final RestartController restartController = RestartController();


  void edit() {
    print("Test");
  }

  List<AnimationMessage> filteredAnimations() {
    var a = animations;
    if(query.isNotEmpty) {
      a = animations.where((element) => element.title!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    a.sort((a, b) {
      return a.title!.compareTo(b.title!);
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
          content: Text('Animation "%s" wurde gelöscht'.i18n.fill([title])),
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

  void send(AnimationMessage animation) {
    controller.broadcast(
        animation
    );
  }

  var isValidAnimation = true;


  void setAnimations(List<AnimationMessage> an) {
    print("SETTING ANIMATIONS NEW...");
    an.forEach((element) {
      print("ELEMENT");
      print(element.colors.map((e) => e.point));
    });
    setState(() {
      animations = [];
    });
    // FIXME: Can we do this more beautiful?
    Future.delayed(Duration(milliseconds: 1), () => {
      setState(() {
        animations = an;
      })
    });

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
                padding: const EdgeInsets.all(8),
                child: Column(
                    children: [
                      Lottie.asset(
                      'assets/server.json',
		                    width: 500
                      ),
                      Text(
                        "Keine gespeicherten Animationen\n".i18n,
                        style: const TextStyle(
                            fontSize: 20
                        ),
                      ),
                      Text(
                        'Im Bereich "Animation" kannst du Animationen erstellen und speichern'.i18n,
                        style: const TextStyle(
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
                decoration: InputDecoration(
                  labelText: 'Suche'.i18n,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder()
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              margin: const EdgeInsets.all(6.0),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                          leading: const Icon(Icons.edit),
                          title: Text("Editieren".i18n),
                        ),
                          onTap: () {
                            var currentAnimation = filteredAnimations()[realIndex].copy();
                            Future.delayed(
                                const Duration(seconds: 0),
                                    () =>
                                    showDialog(context: context, builder: (_) {
                                      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                        return AlertDialog(
                                          title: Text("Bearbeiten".i18n),
                                          insetPadding: EdgeInsets.all(16),
                                          contentPadding: EdgeInsets.zero,
                                          content: Container(
                                            child: AnimationsEditorWidget(
                                              showSendingOptions: false,
                                              onAnimationsValidChanged: (bool value) {
                                                Future.delayed(Duration.zero, () async {
                                                  setState(() {
                                                    isValidAnimation = value;
                                                  });
                                                });
                                              },
                                              onAnimationChanged: (a) => setState(() {
                                                currentAnimation = a.copy();
                                              }),
                                              animation: currentAnimation,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(onPressed: () =>{
                                              Navigator.pop(context)
                                            }, child: Text("Abbrechen".i18n)),
                                            TextButton(onPressed: !isValidAnimation? null : () {
                                              print(currentAnimation);
                                              Persistence().saveAnimation(currentAnimation).then((value) {
                                                Future.delayed(Duration.zero, () => {
                                                  setAnimations(value)
                                                });
                                                Navigator.pop(context);
                                              });
                                            }, child: Text("Speichern".i18n)),
                                          ],
                                        );
                                      });
                                    })
                            );
                          },
                          value: 0
                        ),
                        PopupMenuItem(child: ListTile(
                          leading: const Icon(Icons.drive_file_rename_outline_sharp),
                          title: Text("Umbenennen".i18n),
                        ),
                            onTap: () {
                              setState(() {
                                currentNameRename =  filteredAnimations()[realIndex].title!;
                              });
                              t.text = currentNameRename;
                              Future.delayed(
                                const Duration(seconds: 0),
                                () =>
                                  showDialog(context: context, builder: (_) {
                                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                    return AlertDialog(
                                        title: Text("Umbenennen".i18n),
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
                                          }, child: Text("Abbrechen".i18n)),
                                          TextButton(onPressed: filteredAnimations()[realIndex].title == currentNameRename? null : () {
                                            var old = filteredAnimations()[realIndex].title;
                                            Persistence().rename(filteredAnimations()[realIndex].title!, t.text).then((value) =>
                                            {
                                              load(),
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content:
                                                    Text('Animation "%s" wurde zu "%s" umbenannt'.i18n.fill([old!, t.text]))
                                                )
                                              ),
                                              Navigator.pop(context)
                                            });
                                          }, child: Text("Speichern".i18n)),
                                        ],
                                    );
                                  });
                                })
                              );
                            },
                            value: 1
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.delete), // your icon
                            title: Text("Löschen".i18n),
                          ),
                          value: 2,
                          onTap: () => deleteItem(filteredAnimations()[realIndex].title!),
                        ),
                      ]
                  );
                },
                child: Column(
                    children: [
                ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: AnimationPreviewWidget(
                    settings: AnimationSettingsConfig(
                      filteredAnimations()[realIndex].config.interpolationType,
                      filteredAnimations()[realIndex].config.timefactor,
                      filteredAnimations()[realIndex].config.minutes,
                      filteredAnimations()[realIndex].config.seconds,
                      filteredAnimations()[realIndex].config.millis
                    ),
                    colors: GradientSettingsConfig(
                      filteredAnimations()[realIndex].colors.map((e) => ColorPoint(e.color, e.point)).toList()
                    ),
                    callback: null,
                    restartController: restartController,
                    restartCallback: {},
                    notify: {},
                    isEditorPreview: false,
                    onAnimationsValidChanged: (val) => {},
                  ),
                  title: Text(filteredAnimations()[realIndex].title!),
                  subtitle: Text(filteredAnimations()[realIndex].toString()),
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
              ])));
          }
        }));
  }
}
