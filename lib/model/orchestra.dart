
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
import 'package:starklicht_flutter/view/time_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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

class TimedNode extends INode {
  Stream<double> getProgress() {
    throw UnimplementedError();
  }
  Duration time;
  TimedNode({Key? key, required this.time, update, onDelete, required this.type}) : super(key:key, update: update, onDelete: onDelete);

  @override
  State<StatefulWidget> createState() => TimedNodeState();

  @override
  NodeType type = NodeType.TIME;
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
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTitle().toUpperCase(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                    PopupMenuButton<String>(
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      onSelected: (s) => {
                        if(s == 'Löschen') {
                          widget.onDelete?.call(widget.key!)
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return { 'Bearbeiten', 'Löschen'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:8, bottom: 8, right: 8),
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
              Padding(
                padding: const EdgeInsets.only(left:8.0, right: 8, bottom: 8),
                child: Text(
                  "Lampen".toUpperCase(),
                  style: Theme.of(context).textTheme.overline,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: connectedDevices.map((e) => Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4),
                      child: FilterChip(
                                  label: Text(e.options.name ?? e.device.name),
                                  selected: active[e.device.id.id] ?? false,
                                  onSelected: (eve) => {
                                    setState(() {
                                      active[e.device.id.id] = eve;
                                    }),
                                    updateActive()
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )).toList()
                  ),
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
    if(widget.type == NodeType.REPEAT) {
      return "Neustart";
    } else if(widget.type == NodeType.WAIT) {
      return "Warten";
    }
    return "Verzögerung";
  }

  List<Color> getColors() {
    if(widget.type == NodeType.REPEAT) {
      return [Color(0xffF7971E), Color(0xffFFD200)];
    } else if(widget.type == NodeType.WAIT) {
      return [Color(0xff42275A), Color(0xff734B6D)];
    }
    return [Color(0xff136A8A), Color(0xff267871)];
  }

  void update() {
    setState(() {

    });
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
                  Icon(getIcon(), color: Colors.white, size: 64,),
                  Container(
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.adaptive.more, color: Colors.white,),
                      padding: EdgeInsets.zero,
                      onSelected: (s) => {
                        if(s == 'Löschen') {
                          widget.onDelete?.call(widget.key!)
                        } else if(s == 'Bearbeiten') {
                          showDialog(context: context, builder: (_) {
                            var duration = widget.time;
                            return StatefulBuilder(builder: (context, StateSetter setState) {
                              return AlertDialog(
                                title: Text("Bearbeiten"),
                                content: Container(
                                  height: 150,
                                  child: TimePicker(
                                    onChanged: (v) => {duration = v}, small: true, startDuration: duration,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                  child: Text("Abbrechen"),
                                  onPressed: () => {Navigator.pop(context)}),
                                  TextButton(
                                  child: Text("Speichern"),
                                  onPressed: () => {
                                    setState(() {
                                      widget.time = duration;
                                    }),
                                    update(),
                                    Navigator.pop(context)
                                  })
                                ],
                              );
                            });
                          })
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Bearbeiten', 'Löschen'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
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