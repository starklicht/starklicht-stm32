

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderableitemsview/reorderableitemsview.dart';
import 'package:starklicht_flutter/controller/orchestra_handler.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/model/orchestra.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:uuid/uuid.dart';
class OrchestraWidget extends StatefulWidget {
  List<INode> nodes = [];

  OrchestraWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrchestraWidgetState();

}

class _Example01Tile extends StatelessWidget {
  _Example01Tile(Key key, this.backgroundColor, this.iconData): super(key: key);

  final Color backgroundColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: backgroundColor,
      child: new InkWell(
        onTap: () {},
        child: new Center(
          child: new Padding(
            padding: EdgeInsets.all(4.0),
            child: new Icon(
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
  double _currentSeconds = 1;
  double _currentMillis = 0;

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
    var snackBar = SnackBar(
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
      appBar: AppBar(
        title: Text("Orchester"),
        actions: [
          IconButton(onPressed: running ? stop : run,
            icon: Icon(running ? Icons.stop : Icons.play_arrow),),
          IconButton(onPressed: () => {}, icon: Icon(Icons.save))
        ],
      ),
      body:
            GestureDetector(
              onLongPress: () => {print("Hallo welt")},
              onLongPressEnd: (s) => {},
              child: ReorderableItemsView(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
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
                child: Icon(Icons.timer),
                label: "Zeitevent",
                onTap: () {
                  showDialog(context: context, builder: (_) {

                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text("Zeitevent hinzufügen"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TODO Export this into an own fucker
                            RadioListTile<NodeType>(value: NodeType.WAIT,
                                title: Text("Auf Benutzereingabe warten"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),
                            RadioListTile<NodeType>(value: NodeType.TIME,
                                title: Text("Zeitverzögerung"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),

                            RadioListTile<NodeType>(value: NodeType.REPEAT,
                                title: Text("Neustart nach Zeitverzögerung"),
                                groupValue: _type,
                                onChanged: (value) => {setState((){ _type = value!; })}),
                            if(_type == NodeType.REPEAT || _type == NodeType.TIME) ...[
                              Text("Verzögerung".toUpperCase(), style: Theme.of(context).textTheme.overline),
                              Wrap(
                                children: [
                                  DropdownButton<double>(
                                    value: _currentSeconds,
                                    items: [for (var i = 0; i <= 60; i++) i].map((value) =>
                                        DropdownMenuItem<double>(
                                            value: value.toDouble(),
                                            child: Text("$value Sekunden")
                                        )
                                    ).toList(),
                                    onChanged: (d) => setState(() {
                                      _currentSeconds = d!;
                                    }),
                                  ),
                                  DropdownButton<double>(
                                    value: _currentMillis,
                                    items: [for (var i = 0; i <= 1000; i+=100) i].map((value) =>
                                        DropdownMenuItem<double>(
                                            value: value.toDouble(),
                                            child: Text("$value Millisekunden")
                                        )
                                    ).toList(),
                                    onChanged: (d) => setState(() {
                                      _currentMillis = d!;
                                    }),
                                  )
                                ],
                              ),
                            ]
                          ],
                        ),
                        actions: [
                          TextButton(
                              child: Text("Abbrechen"),
                              onPressed: () => {Navigator.pop(context)}),
                          TextButton(
                              child: Text("Hinzufügen"),
                              onPressed: () {
                                setState((){
                                  widget.nodes.add(TimedNode(onDelete: deleteCallback,time: Duration(seconds: _currentSeconds.toInt(), milliseconds: _currentMillis.toInt()), type: _type));
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
              child: Icon(Icons.settings_remote),
                label: "Nachrichtenevent",
              onTap: () {
                setState(() {
                  widget.nodes.add(MessageNode(onDelete: deleteCallback, lamps: ["a", "b"], message: BrightnessMessage(100)));
                });
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
            lamps: [],
            message:
                AnimationMessage(value[0].colors, value[0].config)),
        MessageNode(
            onDelete: deleteCallback,
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.orange)),
        MessageNode(
            onDelete: deleteCallback,
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.blue)),
        MessageNode(
            onDelete: deleteCallback,
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.green)),
        TimedNode(onDelete: deleteCallback,
            time: Duration(milliseconds: 1000), type: NodeType.TIME),
        TimedNode(onDelete: deleteCallback,time: Duration(milliseconds: 1000), type: NodeType.WAIT),
        TimedNode(onDelete: deleteCallback,time: Duration(milliseconds: 1000), type: NodeType.REPEAT),
      ];
      handlers[NodeType.TIME] = TimedNodeHandler();
      handlers[NodeType.REPEAT] = TimedNodeHandler();
      handlers[NodeType.MESSAGE] = MessageNodeHandler();
      handlers[NodeType.WAIT] = UserInputHandler();
      nodes.forEach((element) {
        var s = StreamController<double>.broadcast();
        streams[element] = s;
        element.update = s.stream;
      });
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