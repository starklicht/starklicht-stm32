
import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/messages/imessage.dart';
import 'package:starklicht_flutter/view/time_picker.dart';
import 'package:uuid/uuid.dart';

import '../controller/starklicht_bluetooth_controller.dart';

enum NodeType {
  NOT_DEFINED, TIME, REPEAT, MESSAGE, WAIT
}

abstract class INode extends StatefulWidget {
  Function? notifyParent;
  Function(Key id)? onDelete;
  double progress = 0;
  INode({Key? key, this.notifyParent, this.update, this.onDelete}) : super(key: key ?? Key(const Uuid().v4()));
  Stream<double>? update;
  abstract NodeType type;
}

class MessageNode extends INode {
  final List<String> lamps;
  List<String> activeLamps = [];
  final IBluetoothMessage message;

  MessageNode({Key? key, required this.lamps, required this.message, update, onDelete}) : super(key: key, update: update, onDelete: onDelete);

  @override
  State<StatefulWidget> createState() => MessageNodeState();

  @override
  NodeType type = NodeType.MESSAGE;
}

class ParentNode extends INode {
  Stream<double> getProgress() {
    throw UnimplementedError();
  }

  String getSubtitle() {
    if(type == NodeType.REPEAT) {
      return formatTime();
    } else if (type == NodeType.WAIT) {
      return "Auf Benutzereingabe";
    }
    return formatTime();
  }

  String formatTime() {
    return "${time.inMinutes.remainder(60)}m ${time.inSeconds.remainder(60)}s ${time.inMilliseconds.remainder(1000)}ms";
  }

  bool hasSubtitle() {
    return time.inMicroseconds > 0 || type == NodeType.WAIT;
  }

  List<MessageNode> messages;
  Duration time;
  ParentNode({Key? key, this.time = const Duration(), update, onDelete, this.type = NodeType.NOT_DEFINED, this.messages = const []}) : super(key:key, update: update, onDelete: onDelete);

  @override
  State<StatefulWidget> createState() => ParentNodeState();

  @override
  NodeType type;
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
      dashPattern: const [5, 5],
      radius: const Radius.circular(8),
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(58),
        child: Center(
          child: IconButton(
            onPressed: () => {},
            color: Colors.blueAccent,
            icon: const Icon(Icons.add),
          )
        )
      )
    );
  }

}


class MessageNodeState extends INodeState<MessageNode> {
  List<SBluetoothDevice> connectedDevices = [];
  Map<String, bool> active = {};
  StreamSubscription<dynamic>? myStream;

  @override
  void initState() {
    myStream?.cancel();
    myStream = BluetoothControllerWidget().connectedDevicesStream().listen((event) {
      setState(() {
        connectedDevices = event;
        active = { for (var e in event) e.device.id.id : true };
      });
    });
    super.initState();
  }

  void updateActive() {
    setState(() {
      widget.activeLamps = active.entries.where((element) => element.value == true).map((e) => e.key).toList();
    });
  }

  @override
  void dispose() {
    myStream?.cancel();
    super.dispose();
  }

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

  String getPostfix() {
    return "senden";
  }

  String getText() {
    return widget.message.retrieveText();
  }

  Color getColor() {
    return widget.message.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${getTitle()} ${getPostfix()}: ",
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getColor(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 0.0,
                      spreadRadius: 1,
                      offset:
                      const Offset(0.0, 0.0), // shadow direction: bottom right
                    ),
                  ],
                ),
              ),
              Text(" (${getText()})", style: Theme.of(context).textTheme.labelSmall,)
            ],
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.lamps.map((e) => Chip(
              avatar: CircleAvatar(
                child: Text(e[0].toUpperCase())
              ),
              label: Text(e),
              materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
              onDeleted: () => {
                setState((){
                  widget.lamps.remove(e);
                })
              },
            ) as Widget).toList()..add(
              ActionChip(
                materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                onPressed: () {},
                label: Icon(Icons.add),
              )
            )
        ),

        ],
      );
  }
}

class ParentNodeState extends INodeState<ParentNode> {
  String getTitle() {
    if(widget.type == NodeType.REPEAT) {
      return "Neustart";
    } else if(widget.type == NodeType.WAIT) {
      return "Warten";
    }
    return "Verzögerung";
  }

  bool hasSubtitle() {
    return widget.time.inMicroseconds > 0;
  }

  List<Color> getColors() {
    if(widget.type == NodeType.REPEAT) {
      return [const Color(0xffF7971E), const Color(0xffFFD200)];
    } else if(widget.type == NodeType.WAIT) {
      return [const Color(0xff42275A), const Color(0xff734B6D)];
    }
    return [const Color(0xff136A8A), const Color(0xff267871)];
  }

  void update() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTitle(),
              style: Theme.of(context).textTheme.headline5!),
              if(hasSubtitle()) ...[
                Text(getSubtitle(),
                    style: Theme.of(context).textTheme.subtitle1!)
              ]
            ],
          ),
        ],
      );
  }

  IconData getIcon() {
    if(widget.type == NodeType.REPEAT) {
      return Icons.history;
    } else if(widget.type == NodeType.WAIT) {
      return Icons.hourglass_empty;
    }
    return Icons.timer;
  }

  String formatTime() {
    return "${widget.time.inMinutes.remainder(60)}m ${widget.time.inSeconds.remainder(60)}s ${widget.time.inMilliseconds.remainder(1000)}ms";
  }

  String getSubtitle() {
    if(widget.type == NodeType.REPEAT) {
      return formatTime();
    } else if (widget.type == NodeType.WAIT) {
      return "Auf Benutzereingabe";
    }
    return formatTime();
  }
}