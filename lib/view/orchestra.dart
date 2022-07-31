

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:reorderableitemsview/reorderableitemsview.dart';
import 'package:starklicht_flutter/controller/orchestra_handler.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/messages/imessage.dart';
import 'package:starklicht_flutter/model/animation.dart';
import 'package:starklicht_flutter/model/orchestra.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:starklicht_flutter/view/time_picker.dart';

import 'colors.dart';
class OrchestraWidget extends StatefulWidget {
  List<INode> nodes = [];

  OrchestraWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrchestraWidgetState();

}

class _Example01Tile extends StatelessWidget {
  const _Example01Tile(Key key, this.backgroundColor, this.iconData): super(key: key);

  final Color backgroundColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrchestraWidgetState extends State<OrchestraWidget> {
  Map<NodeType, OrchestraNodeHandler> handlers = {};
  Map<INode, StreamController<double>> streams = {};
  var queue = Queue<INode>();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var running = false;
  var _type = NodeType.WAIT;
  var _messageType = MessageType.brightness;
  var _currentBrightness = 100.0;
  List<KeyframeAnimation> _animationStore = [];
  var currentDuration = const Duration(minutes: 0, seconds: 0, milliseconds: 0);

  Future<void> run() async {
    setState(() {
      running = true;
    });
    queue.clear();
    queue.addAll(widget.nodes);
    while(queue.isNotEmpty && running) {
      var current = queue.removeFirst();
      var cont = await handlers[current.type]!.execute(current, streams[current]!, context: context);
      if(!cont) {
        break;
      }
      if(current.type == NodeType.REPEAT && running && cont) {
        print("Repeat node...");
        await run();
        break;
      }
    }
    setState(() {
      running = false;
    });
  }

  Future<void> stop() async {
    setState(() {
      running = false;
    });
    await handlers[NodeType.TIME]!.cancel();
    await handlers[NodeType.MESSAGE]!.cancel();
  }

  void deleteCallback(Key id) {
    setState(() {
      widget.nodes.removeWhere((element) => element.key == id);
    });
    var snackBar = const SnackBar(
      content: Text('Event wurde gelöscht'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  int getWidth(e) {
    if(e is TimedNode) {
      return 8;
    }
    return 4;
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
            GestureDetector(
              onLongPress: () => {print("Hallo welt")},
              onLongPressEnd: (s) => {},
              child: ReorderableItemsView(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    widget.nodes.insert(newIndex, widget.nodes.removeAt(oldIndex));
                  });
                },
                staggeredTiles: widget.nodes.map((e) =>
                  StaggeredTileExtended.count(getWidth(e),e is TimedNode? 2 : 4)
                ).toList(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 8,
                isGrid: true,
                children: widget.nodes.map((e) =>
                  e
                ).toList(),
                longPressToDrag: true,
              ),
            ),
      floatingActionButton: SpeedDial(
        spacing: 15,
        spaceBetweenChildren: 15,
        icon: Icons.add,
        activeIcon: Icons.close,
        openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.timer),
                label: "Zeitevent",
                onTap: () {
                  showDialog(context: context, builder: (_) {
                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text("Zeitevent hinzufügen"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TODO Export this into an own fucker
                            RadioListTile<NodeType>(value: NodeType.WAIT,
                                title: const Text("Auf Benutzereingabe warten"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),
                            RadioListTile<NodeType>(value: NodeType.TIME,
                                title: const Text("Zeitverzögerung"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),

                            RadioListTile<NodeType>(value: NodeType.REPEAT,
                                title: const Text("Neustart nach Zeitverzögerung"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),
                            if(_type == NodeType.REPEAT || _type == NodeType.TIME) ...[
                              Text("Verzögerung".toUpperCase(), style: Theme.of(context).textTheme.overline),
                            ],
                            AnimatedContainer(height: _type == NodeType.REPEAT || _type == NodeType.TIME ? 100 : 0.0001, duration: const Duration(milliseconds: 200), child: TimePicker(onChanged: (a) => {
                              setState(() {
                                currentDuration = a;
                              })
                            }, small: true, startDuration: currentDuration))
                          ],
                        ),
                        actions: [
                          TextButton(
                              child: const Text("Abbrechen"),
                              onPressed: () => {Navigator.pop(context)}),
                          TextButton(
                              child: const Text("Hinzufügen"),
                              onPressed: () {
                                setState((){
                                  widget.nodes.add(TimedNode(onDelete: deleteCallback,time: currentDuration, type: _type));
                                });
                                refresh();
                                Navigator.pop(context);
                              })
                        ],
                      );
                    });
                  });
                  /* setState(() {
                    widget.nodes.add(TimedNode(time: Duration(seconds: 1)));
                  }); */
                }
            ),
            SpeedDialChild(
              child: const Icon(Icons.settings_remote),
                label: "Nachrichtenevent",
              onTap: () {
                showDialog(context: context, builder: (_) {
                  Persistence().getAnimationStore().then((value) => _animationStore = value);
                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text("Zeitevent hinzufügen"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TODO Export this into an own fucker
                          RadioListTile<MessageType>(value: MessageType.brightness,
                              title: const Text("Helligkeit"),
                              groupValue: _messageType,
                              onChanged: (value) => {setState((){ _messageType = value!; })}),
                          RadioListTile<MessageType>(value: MessageType.color,
                              title: const Text("Farbe"),
                              groupValue: _messageType,
                              onChanged: (value) => {setState((){ _messageType = value!; })}),
                          RadioListTile<MessageType>(value: MessageType.interpolated,
                              title: const Text("Animation"),
                              groupValue: _messageType,
                              onChanged: (value) => {setState((){ _messageType = value!; })}),
                          if(_messageType == MessageType.brightness) ... [
                            Text("Helligkeit bestimmen".toUpperCase(), style: Theme.of(context).textTheme.overline),
                            Column(children: [
                              Slider(
                                max: 100,
                                onChangeEnd: (d) => {
                                  setState(() {
                                    _currentBrightness = d;
                                  }),
                                },
                                onChanged: (d) => {
                                  setState(() {
                                    _currentBrightness = d;
                                  }),
                                },
                                value: _currentBrightness,
                              ),
                              Text("${_currentBrightness.toInt()}%", style: const TextStyle(
                                  fontSize: 32
                              ),)
                            ],)
                          ]
                          else if(_messageType == MessageType.color) ...[
                            Text("Farbe auswählen".toUpperCase(), style: Theme.of(context).textTheme.overline),
                            ColorsWidget(
                              startColor: Colors.white,
                            )
                          ]
                          else if (_messageType == MessageType.interpolated) ...[
                            Text("Animation aus Liste auswählen".toUpperCase(), style: Theme.of(context).textTheme.overline),
                            // Persistence
                            //DropdownButton<String>(items: _animationStore.map((e) => DropdownMenuItem(child: Text(e.title))).toList(), onChanged: (i) => {})
                          ]
                        ],
                      ),
                      actions: [
                        TextButton(
                            child: const Text("Abbrechen"),
                            onPressed: () => {Navigator.pop(context)}),
                        TextButton(
                            child: const Text("Hinzufügen"),
                            onPressed: () {
                              setState((){
                                widget.nodes.add(
                                  MessageNode(lamps: const [], message: BrightnessMessage(_currentBrightness.toInt()))
                                );
                              });
                              refresh();
                              Navigator.pop(context);
                            })
                      ],
                    );
                  });
                });
                /* setState(() {
                  widget.nodes.add(MessageNode(onDelete: deleteCallback, lamps: ["a", "b"], message: BrightnessMessage(100)));
                }); */
              }
            ),
          ],
      ),
    );
  }

  @override
  void initState() {
    Persistence().getAnimationStore().then((value) {
      var nodes = [
        MessageNode(
            onDelete: deleteCallback,
            lamps: const [],
            message:
            ColorMessage.fromColor(Colors.orange)),
        MessageNode(
            onDelete: deleteCallback,
            lamps: const [],
            message:
            ColorMessage.fromColor(Colors.blue)),
        MessageNode(
            onDelete: deleteCallback,
            lamps: const [],
            message:
            ColorMessage.fromColor(Colors.green)),
        TimedNode(onDelete: deleteCallback,
            time: const Duration(milliseconds: 1000), type: NodeType.TIME),
        TimedNode(onDelete: deleteCallback,time: const Duration(milliseconds: 1000), type: NodeType.WAIT),
        TimedNode(onDelete: deleteCallback,time: const Duration(milliseconds: 1000), type: NodeType.REPEAT),
      ];
      handlers[NodeType.TIME] = TimedNodeHandler();
      handlers[NodeType.REPEAT] = TimedNodeHandler();
      handlers[NodeType.MESSAGE] = MessageNodeHandler();
      handlers[NodeType.WAIT] = UserInputHandler();
      for (var element in nodes) {
        var s = StreamController<double>.broadcast();
        streams[element] = s;
        element.update = s.stream;
      }
      setState(() {
        widget.nodes = nodes;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var element in streams.values) { element.close(); }
    super.dispose();
  }
}