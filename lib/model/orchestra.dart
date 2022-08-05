
import 'dart:async';
import 'package:collection/src/iterable_extensions.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/messages/imessage.dart';
import 'package:starklicht_flutter/model/lamp_groups_enum.dart';
import 'package:starklicht_flutter/view/time_picker.dart';
import 'package:uuid/uuid.dart';

import '../controller/starklicht_bluetooth_controller.dart';

enum NodeType {
  NOT_DEFINED, TIME, REPEAT, MESSAGE, WAIT
}

enum WaitType {
  NONE, TIME, USER_INPUT
}

abstract class INode extends StatefulWidget {
  Function? notifyParent;
  Function(Key id)? onDelete;
  double progress = 0;
  INode({Key? key, this.notifyParent, this.update, this.onDelete}) : super(key: key ?? Key(const Uuid().v4()));
  Stream<double>? update;
  abstract NodeType type;
}

enum CardIndicator {
  COLOR, GRADIENT, PROGRESS
}

abstract class EventNode extends INode {
  EventNode({Key? key, update, onDelete, this.waitType = WaitType.NONE}) : super(key: key, update: update, onDelete: onDelete);

  bool get isGradient;

  WaitType waitType;

  bool hasLamps();

  get lamps;
  String getTitle();

  bool displayAsProgressBar();

  double toPercentage();

  Color toColor();

  Gradient? toGradient();

  Duration? delayAfterwards();

  bool manualDelayAfterwards();

  Widget getSubtitle(BuildContext context, TextStyle textStyle);
}

class TimedNode extends EventNode {
  @override
  NodeType type = NodeType.TIME;

  Duration time = Duration(seconds: 10);

  @override
  State<StatefulWidget> createState() => TimedNodeState();

  String formatTime() {
    var minutes = time.inMinutes.remainder(60);
    var seconds = time.inSeconds.remainder(60);
    var millis = time.inMilliseconds.remainder(1000);
    var str = "";
    if(minutes > 0) {
      str+= "${minutes} Minuten ";
    }
    if(seconds > 0) {
      str+= "${seconds} Sekunden ";
    }
    if(millis > 0) {
      str+= "${millis} Millisekunden ";
    }
    return str.trim();
  }

  @override
  bool displayAsProgressBar() {
    return true;
  }

  @override
  Widget getSubtitle(BuildContext context, TextStyle textStyle) {
    return Text("Für ${formatTime()} warten");
  }

  @override
  String getTitle() {
    return "Warten";
  }

  @override
  // TODO: implement isGradient
  get isGradient => false;

  @override
  // TODO: implement lamps
  get lamps => [];

  @override
  toColor() {
    return Colors.red;
  }

  @override
  toGradient() {
    return null;
  }

  @override
  toPercentage() {
    return 0;
  }

  @override
  bool hasLamps() {
    return false;
  }

  @override
  Duration? delayAfterwards() {
    return Duration(seconds: 1);
  }

  @override
  bool manualDelayAfterwards() {
    return false;
  }

  @override
  // TODO: implement waitType
  WaitType get waitType => WaitType.TIME;

  @override
  void setWaitType(WaitType n) {
  }
}

class TimedNodeState extends State<TimedNode> {
  @override
  Widget build(BuildContext context) {
    return Text("");
  }

}

class MessageNode extends EventNode {
  final List<String> lamps;
  WaitType waitAfter;
  List<String> activeLamps = [];
  final IBluetoothMessage message;
  Duration delay = Duration();
  bool waitForUserInput;

  String formatTime() {
    var minutes = delay.inMinutes.remainder(60);
    var seconds = delay.inSeconds.remainder(60);
    var millis = delay.inMilliseconds.remainder(1000);
    var str = "";
    if(waitForUserInput) {
      return "Auf Benutzereingabe warten";
    }
    if(minutes > 0) {
      str+= "${minutes} Minuten ";
    }
    if(seconds > 0) {
      str+= "${seconds} Sekunden ";
    }
    if(millis > 0) {
      str+= "${millis} Millisekunden ";
    }
    if(str.trim().isEmpty) {
      return "Ohne Zeitverzögerung";
    }
    return str.trim();
  }

  @override
  String getTitle() {
    switch(message.messageType) {
      case MessageType.color:
        return "Farbe";
      case MessageType.interpolated:
        return "Animation";
      case MessageType.request:
        // TODO: Handle this case.
        break;
      case MessageType.onoff:
        // TODO: Handle this case.
        break;
      case MessageType.poti:
        // TODO: Handle this case.
        break;
      case MessageType.brightness:
        return "Helligkeit";
        break;
      case MessageType.save:
        // TODO: Handle this case.
        break;
      case MessageType.clear:
        // TODO: Handle this case.
        break;
    }
    return "Unbekannt";
  }

  MessageNode({Key? key, required this.lamps, required this.message, update, onDelete, this.waitAfter = WaitType.NONE, this.waitForUserInput = false}) : super(key: key, update: update, onDelete: onDelete);

  @override
  State<StatefulWidget> createState() => MessageNodeState();

  @override
  NodeType type = NodeType.MESSAGE;

  @override
  RichText getSubtitle(BuildContext context, TextStyle baseStyle) {
    switch(message.messageType) {
      case MessageType.color:
        return RichText(
            text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: "Setze die Lampen auf die Farbe "),
                  TextSpan(text: message.retrieveText(), style: TextStyle(fontWeight: FontWeight.bold))
                ]
            )
        );
      case MessageType.interpolated:
        return RichText(
            text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: "Spiele die Animation "),
                  TextSpan(text: message.retrieveText(), style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " ab")
                ]
            )
        );
      case MessageType.request:
      // TODO: Handle this case.
        break;
      case MessageType.onoff:
      // TODO: Handle this case.
        break;
      case MessageType.poti:
      // TODO: Handle this case.
        break;
      case MessageType.brightness:
        return RichText(text: TextSpan(
            style: baseStyle,
            children: [
              TextSpan(text: "Setze die Helligkeit der Lampen auf "),
              TextSpan(text: message.retrieveText(), style: TextStyle(fontWeight: FontWeight.bold)),
            ]
        ));
      case MessageType.save:
      // TODO: Handle this case.
        break;
      case MessageType.clear:
      // TODO: Handle this case.
        break;
    }
    return RichText(text: TextSpan(
        style: baseStyle,
        text: "Unbekannt")
    );
  }

  @override
  displayAsProgressBar() {
    return message.displayAsProgressBar();
  }

  @override
  // TODO: implement isGradient
  get isGradient => message.isGradient;

  @override
  toColor() {
    return message.toColor();
  }

  @override
  toGradient() {
    return message.toGradient();
  }

  @override
  toPercentage() {
    return 0.5;
  }

  @override
  bool hasLamps() {
    return true;
  }

  @override
  Duration? delayAfterwards() {
    return Duration(seconds: 1);
  }

  @override
  bool manualDelayAfterwards() {
    return false;
  }

  @override
  // TODO: implement waitType
  WaitType get waitType => waitAfter;

  @override
  void setWaitType(WaitType n) {
    waitAfter = n;
  }
}

class ParentNode extends INode {
  String getSubtitle() {
    if(hasTime()) {
      return "${formatTime()} warten";
    } else if (type == NodeType.WAIT) {
      return "Auf Benutzereingabe warten";
    }
    return "Sofort";
  }

  IconData? getIcon() {
    if(hasTime()) {
      return Icons.timer;
    } else if(type == NodeType.WAIT) {
      return Icons.hourglass_empty;
    }
    return Icons.arrow_downward;
  }

  String formatTime() {
    var minutes = time.inMinutes.remainder(60);
    var seconds = time.inSeconds.remainder(60);
    var millis = time.inMilliseconds.remainder(1000);
    var str = "";
    if(minutes > 0) {
      str+= "${minutes}m ";
    }
    if(seconds > 0) {
      str+= "${seconds}s ";
    }
    if(millis > 0) {
      str+= "${millis}ms ";
    }
    return str.trim();
  }

  bool hasSubtitle() {
    return hasTime() || type == NodeType.WAIT;
  }

  bool hasTime() {
    return time.inMicroseconds > 0;
  }

  List<EventNode> messages;
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


class MessageNodeState extends INodeState<MessageNode> with TickerProviderStateMixin  {
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _myAnimation = CurvedAnimation(
        curve: Curves.linear,
        parent: _controller
    );
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

  Widget getAvatar(String name) {
    var group = LampGroups.values.firstWhereOrNull((e) => name.toLowerCase() == e.name.toLowerCase());
    if(group != null) {
      return Icon(group.icon, size: 18);
    }
    return Text(name[0].toUpperCase());
  }

  late Animation<double> _myAnimation;
  late AnimationController _controller;
  bool timeIsExtended = false;

  @override
  Widget build(BuildContext context) {
    return
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: widget.lamps.map((e) => Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Chip(
                    avatar: CircleAvatar(
                      child: getAvatar(e),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(e),
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () => {
                      setState((){
                        widget.lamps.remove(e);
                      })
                    },
                  ),
              )).toList()..add(
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: ActionChip(
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      label: Icon(Icons.add),
                    ),
                  )
                ))
            ),
            Divider(),
            ListTile(
              title: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Dauer: ", style: TextStyle(fontWeight: FontWeight.bold
                    )),
                    WidgetSpan(child: Icon(Icons.access_time, size: 16)),
                    TextSpan(text: " ${widget.formatTime()}")
                  ])),
              trailing: IconButton(
                icon: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                  child: Icon(Icons.expand_more),
                ),
                onPressed: () {
                  setState(() {
                    timeIsExtended = !timeIsExtended;
                  });
                  if(timeIsExtended) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: timeIsExtended ? null : 0,
              child:
                  SizeTransition(
                    sizeFactor: Tween<double>(begin: 0, end: 1).animate(_controller),
                    child:
                    CheckboxListTile(value: widget.waitForUserInput, onChanged: (t) => {
                      setState(() {
                        widget.waitForUserInput = t!;
                      })
                    }, title: Text("Auf Benutzereingabe warten") )
                    ,
                  )
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: timeIsExtended && !widget.waitForUserInput ? 100 : 0.000001,
              child: TimePicker(
                small: true,
                onChanged: (t) => {
                  setState(() {
                    widget.delay = t;
                  })
                },
              ),
            )
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