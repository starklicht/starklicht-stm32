
import 'dart:collection';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/view/animations.dart';
import 'package:timelines/timelines.dart';

import '../controller/orchestra_handler.dart';
import '../messages/color_message.dart';
import '../model/orchestra.dart';

class OrchestraTimeline extends StatefulWidget {
  Map<NodeType, OrchestraNodeHandler> handlers = {};
  var queue = Queue<INode>();
  var running = false;
  var restart = true;

  var nodes = [
    ParentNode(
      messages: [MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.red))],
      time: Duration(seconds: 1),
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["front", "back"], message: ColorMessage.fromColor(Colors.greenAccent)), MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.blue))],
      time: Duration(milliseconds: 100)
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key", "back", "black", "variable"], message: BrightnessMessage(20))],
      type: NodeType.WAIT
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key"], message: BrightnessMessage(100))],
    ),
    ParentNode(
        messages: [MessageNode(lamps: ["front", "back"], message: ColorMessage.fromColor(Colors.greenAccent)), MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.orangeAccent))],
        time: Duration(milliseconds: 100)
    ),
    ParentNode(
        messages: [MessageNode(lamps: ["front", "back"], message: ColorMessage.fromColor(Colors.greenAccent)), MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.purple)), MessageNode(lamps: [], message: AnimationMessage.buildDefault())],
        time: Duration(milliseconds: 100)
    ),
    ParentNode(
        messages: [],
        time: Duration(seconds: 10)
    ),
  ];
  OrchestraTimeline({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrchestraTimelineState();
}

class OrchestraTimelineState extends State<OrchestraTimeline> {
  IconData getDraggingIcon(int length) {
    return Icons.collections_bookmark_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: Color(0xff989898),
        indicatorTheme: IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: widget.nodes.length + 1,
        contentsBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.nodes.length == 0)... [
                    Text("Keine Knotenpunkte")
                ]
                else if(widget.nodes.length <= index) ...[
                  Text("Ende", style: Theme.of(context).textTheme.headline6),
                  ChoiceChip(
                    avatar:
                      Icon(Icons.repeat, color: widget.restart?Theme.of(context).colorScheme.secondary:null),
                    label: Text(widget.restart?"Wiederholung aktiviert":"Wiederholung deaktiviert"),
                    selected: widget.restart,
                    onSelected: (s) => {
                      setState(() {
                        widget.restart = s;
                      })
                    },
                  )
                ] else ...[
                  LongPressDraggable(
                    dragAnchorStrategy:
                        (Draggable<Object> _, BuildContext __, Offset ___) =>
                    const Offset(40, 128), //
                    feedback: Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text("Schritt ${index + 1}", style: Theme.of(context).textTheme.titleSmall),
                              Row(
                                children: [
                                  Text("${widget.nodes[index].messages.length} x "),
                                  Icon(getDraggingIcon(widget.nodes[index].messages.length), size: 32),
                                ],
                              )
                            ],
                          ),
                        )
                    ),
                    child: RichText(
                      text: TextSpan(
                        // Note: Styles for TextSpans must be explicitly defined.
                        // Child text spans will inherit styles from parent
                        children: <TextSpan>[
                          TextSpan(text: "Schritt ${index + 1}",
                            style: Theme.of(context).textTheme.titleSmall
                          ),
                          if(!widget.nodes[index].hasSubtitle()) ...[
                            TextSpan(text: " ohne Trigger", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.normal)),
                          ] else ...[
                            TextSpan(text: " mit Trigger: ${widget.nodes[index].getSubtitle()}", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.normal))
                          ]
                        ],
                      ),
                    ),
                  ),
                  InnerTimeline(messages: widget.nodes[index].messages, parentId: index),
                ]
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          return DotIndicator(
            color: index == 0 ? Colors.lightBlue :Theme.of(context).colorScheme.background,
            size: 32,
            child: Icon(
              widget.nodes.length <= index ? Icons.flag : widget.nodes[index].getIcon(),
              size: 16,
            )
          );
        },
        connectorBuilder: (_, index, ___) => DashedLineConnector(
          gap: 4,
        ),
      ),
    );
  }
}

class _DeliveryMessage {
  const _DeliveryMessage(this.createdAt, this.message);

  final String createdAt; // final DateTime createdAt;
  final String message;

  @override
  String toString() {
    return '$createdAt $message';
  }
}

class InnerTimeline extends StatefulWidget {
  List<MessageNode> messages;
  int parentId;
  int dragTargetIndex = -1;
  int data = -1;

  InnerTimeline({Key? key, required this.messages, required this.parentId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InnerTimelineState();
}


class DragData {
  int parentId;
  int index;
  DragData({required this.parentId, required this.index});
}

class InnerTimelineState extends State<InnerTimeline> {

  Card getCard(BuildContext context, int index, {bool dragging = false}) {
    var currentMessage = widget.messages[index - 1];
    return Card(
        elevation: dragging ? 8.0 : 1.0,
        clipBehavior: Clip.antiAlias,
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentMessage.message.displayAsProgressBar() ?
            LinearProgressIndicator(
              value: currentMessage.message.toPercentage(),
              minHeight: 8,
            )
                :Container(
              height: 12,
              decoration: BoxDecoration(
                color: currentMessage.message.isGradient ? null : currentMessage.message.toColor(),
                gradient: currentMessage.message.isGradient ? currentMessage.message.toGradient() : null,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(.2),
                      offset: const Offset(0, 0),
                      blurRadius: 2)
                ],
              ),
            ),
            ListTile(
              dense: true,
              title:
              Text(currentMessage.getTitle(), style: Theme.of(context).textTheme.titleLarge),
              subtitle:
              currentMessage.getSubtitle(context, Theme.of(context).textTheme.bodySmall!),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Gruppenbeschränkungen", style: Theme.of(context).textTheme.subtitle1),
            ),
            currentMessage,
            SizedBox(height: 12),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == widget.messages.length + 1;
    }

    bool isLastIndex(int index) {
      return index == widget.messages.length + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
          nodePosition: 0,
          connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
            thickness: 1.0,
          ),
          indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
            size: 10.0,
            position: 0.5,
          ),
        ),
        builder: TimelineTileBuilder(
          indicatorBuilder: (_, index) =>
          !isEdgeIndex(index) ? Indicator.outlined(borderWidth: 1.0) : null,
          startConnectorBuilder: (_, index) => Connector.solidLine(),
          endConnectorBuilder: (_, index) => Connector.solidLine(),
          contentsBuilder: (_, index) {
            if (isLastIndex(index)) {
              return ElevatedButton(
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(8),
                  ),
                  onPressed: () => {},
              );
            } else if(isEdgeIndex(index)) {
              return null;
            }
            return LongPressDraggable<DragData>(
                childWhenDragging: Opacity(opacity: .2, child: getCard(context, index)),
                data: DragData(parentId: widget.parentId, index: index - 1),
                child: DragTarget(
                    onWillAccept: (int? data) {
                      if(index - 1 != data) {
                        setState(() {
                          widget.dragTargetIndex = index;
                          widget.data = data!;
                        });
                      }
                      return true;
                    },
                    onLeave: (var data) => {
                      setState(() {
                        widget.dragTargetIndex = -1;
                        widget.data = -1;
                      })
                    },
                    builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                    ) {
                      return Column(
                        children: [
                          AnimatedContainer(
                            height: widget.dragTargetIndex == index && widget.data > index -1 ? 100 : 0,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease,
                          ),
                          getCard(context, index),
                          AnimatedContainer(
                            height: widget.dragTargetIndex == index && widget.data < index - 1 ? 100 : 0,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease,
                          ),
                        ],
                      );
                    },
                    onAcceptWithDetails: (DragTargetDetails<int> details) {

                    },
                    onAccept: (int data) => {
                      setState(() {
                        widget.dragTargetIndex = -1;
                        widget.data = -1;
                        // Move
                        var m = widget.messages.removeAt(data);
                        widget.messages.insert(index - 1, m);
                      })
                    },
                ),
                feedback: Container(
                width: 250,
                height: 180,
                child: getCard(context, index, dragging: true),
                ),
            );
          },
          nodeItemOverlapBuilder: (_, index) =>
          isEdgeIndex(index) ? true : null,
          itemCount: widget.messages.length + 2,
        ),
      ),
    );
  }
}