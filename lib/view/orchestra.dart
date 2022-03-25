

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderableitemsview/reorderableitemsview.dart';
import 'package:starklicht_flutter/controller/orchestra_handler.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/model/orchestra.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
      if(current is RepeatNode && running && cont) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
            ReorderableItemsView(
              padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  widget.nodes.insert(newIndex, widget.nodes.removeAt(oldIndex));
                });
              },
              staggeredTiles: widget.nodes.map((e) =>
                StaggeredTileExtended.count(e is TimedNode ? 8 : 4,e is TimedNode? 2 : 4)
              ).toList(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: 8,
              isGrid: true,
              children: widget.nodes.toList(),
              longPressToDrag: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: running ? stop : run,
        child: Icon(running ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Persistence().getAnimationStore().then((value) {
      var nodes = [
        MessageNode(key: Key("a"),
            lamps: [],
            message:
                AnimationMessage(value[0].colors, value[0].config)),
        MessageNode(key: Key("b"),
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.orange)),
        MessageNode(key: Key("c"),
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.blue)),
        MessageNode(key: Key("d"),
            lamps: [],
            message:
            ColorMessage.fromColor(Colors.green)),
        TimedNode(key: Key("e"),time: Duration(milliseconds: 1000)),
        WaitUserNode(key: Key("g<ya<"),time: Duration(milliseconds: 1000)),
        RepeatNode(key: Key("f"),time: Duration(milliseconds: 1000)),

      ];
      handlers[NodeType.TIME] = TimedNodeHandler();
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
  }

  @override
  void dispose() {
    for (var element in streams.values) { element.close(); }
    super.dispose();
  }
}