
import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/messages/color_message.dart';
import 'package:starklicht_flutter/messages/imessage.dart';

enum NodeType {
  NOT_DEFINED, TIME, MESSAGE, WAIT
}

abstract class INode extends StatefulWidget {
  Function? notifyParent;
  double progress = 0;
  INode({Key? key, this.notifyParent, this.update}) : super(key: key);
  Stream<double>? update;
  abstract NodeType type;
}

class MessageNode extends INode {
  final List<String> lamps;
  final IBluetoothMessage message;

  MessageNode({Key? key, required this.lamps, required this.message, update}) : super(key: key, update: update);

  @override
  State<StatefulWidget> createState() => MessageNodeState();

  @override
  NodeType type = NodeType.MESSAGE;
}

class TimedNode extends INode {
  Stream<double> getProgress() {
    throw UnimplementedError();
  }
  final Duration time;

  TimedNode({Key? key, required this.time, update}) : super(key:key, update: update);

  @override
  State<StatefulWidget> createState() => TimedNodeState();

  @override
  NodeType type = NodeType.TIME;
}

class RepeatNode extends TimedNode {
  RepeatNode({Key? key, required time}) : super(key:key, time: time);
}

class WaitUserNode extends TimedNode {
  @override
  NodeType type = NodeType.WAIT;
  WaitUserNode({Key? key, required time}) : super(key:key, time: time);
}

class AddNode extends INode {
  AddNode({Key? key}) : super(key: key);

  @override
  NodeType type = NodeType.NOT_DEFINED;

  @override
  State<StatefulWidget> createState() => AddNodeState();

}

abstract class INodeState<T extends INode> extends State<T> {
  StreamSubscription<double>? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.update?.listen((event) {
      setState(() {
        widget.progress = event;
      });
    });
  }
}

class AddNodeState extends INodeState<AddNode> {
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      dashPattern: [5, 5],
      radius: Radius.circular(8),
      color: Colors.blueAccent,
      child: Padding(
        padding: EdgeInsets.all(58),
        child: Center(
          child: IconButton(
            onPressed: () => {},
            color: Colors.blueAccent,
            icon: Icon(Icons.add),
          )
        )
      )
    );
  }

}


class MessageNodeState extends INodeState<MessageNode> {

  String getTitle() {
    switch(widget.message.messageType) {
      case MessageType.color:
        return "Farbe";
      case MessageType.interpolated:
        return "Animation";
        break;
      case MessageType.request:
        break;
      case MessageType.onoff:
        break;
      case MessageType.poti:
        break;
      case MessageType.brightness:
        return "Helligkeit";
      case MessageType.save:
        break;
      case MessageType.clear:
        break;
    }
    return "Nicht definiert";
  }

  String getText() {
    return widget.message.retrieveText();
  }

  Color getColor() {
    return widget.message.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).dividerColor
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTitle().toUpperCase(),
                style: Theme.of(context).textTheme.overline,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3.0,
                            spreadRadius: 0.0,
                            offset:
                            Offset(2.0, 2.0), // shadow direction: bottom right
                          ),
                        ],
                      ),
                    ),
                    Text(
                      getText(),
                      style: Theme.of(context).textTheme.bodyText1
                    ),
                    if(widget.progress > 0) ...[SizedBox(width: 12, height: 12,child: CircularProgressIndicator(strokeWidth: 2,))]

                  ],
                ),
              ),
              Text(
                "Lampen".toUpperCase(),
                style: Theme.of(context).textTheme.overline,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    ChoiceChip(label: Text("Starklicht YDN"), selected: true, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                    ChoiceChip(label: Text("Starklicht DAC"), selected: false, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,)
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}

class TimedNodeState extends INodeState<TimedNode> {
  String getTitle() {
    if(widget is RepeatNode) {
      return "Neustart";
    } else if(widget is WaitUserNode) {
      return "Warten";
    }
    return "Verzögerung";
  }

  List<Color> getColors() {
    if(widget is RepeatNode) {
      return [Color(0xffF7971E), Color(0xffFFD200)];
    } else if(widget is WaitUserNode) {
      return [Color(0xff42275A), Color(0xff734B6D)];
    }
    return [Color(0xff136A8A), Color(0xff267871)];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: getColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          )
        ),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * widget.progress,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTitle(),
                      style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(getSubtitle(),
                      style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white))
                    ],
                  ),
                  Spacer(flex: 2),
                  Icon(getIcon(), color: Colors.white, size: 64,)
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  IconData getIcon() {
    if(widget is RepeatNode) {
      return Icons.history;
    } else if(widget is WaitUserNode) {
      return Icons.hourglass_empty;
    }
    return Icons.timer;
  }

  String getSubtitle() {
    if(widget is RepeatNode) {
      return "Nach ${widget.time.inSeconds},${(widget.time.inMilliseconds - widget.time.inSeconds * 1000) ~/ 100} Sekunde(n)";
    } else if (widget is WaitUserNode) {
      return "Auf Benutzereingabe";
    }
    return "${widget.time.inSeconds},${(widget.time.inMilliseconds - widget.time.inSeconds * 1000) ~/ 100} Sekunde(n)";
  }
}