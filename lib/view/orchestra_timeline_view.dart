
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:timelines/timelines.dart';

import '../controller/orchestra_handler.dart';
import '../messages/color_message.dart';
import '../model/orchestra.dart';

class OrchestraTimeline extends StatefulWidget {
  Map<NodeType, OrchestraNodeHandler> handlers = {};
  var queue = Queue<INode>();
  var running = false;

  var nodes = [
    ParentNode(
      messages: [MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.red))],
      time: Duration(seconds: 1),
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["front", "back"], message: ColorMessage.fromColor(Colors.red)), MessageNode(lamps: [], message: ColorMessage.fromColor(Colors.blue))],
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key", "back", "black", "variable"], message: BrightnessMessage(100))],
    ),

    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key"], message: BrightnessMessage(100))],
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key"], message: BrightnessMessage(100))],
    ),
    ParentNode(
      messages: [MessageNode(lamps: ["fill", "key"], message: BrightnessMessage(100))],
    ),
  ];
  OrchestraTimeline({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrchestraTimelineState();
}

class OrchestraTimelineState extends State<OrchestraTimeline> {
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
        connectorTheme: ConnectorThemeData(
          thickness: 2.5,
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
                  Text("Ende", style: Theme.of(context).textTheme.headline6)
                ] else ...[
                  Text("Schritt ${index + 1}", style: Theme.of(context).textTheme.headline6),
                  if(widget.nodes[index].hasSubtitle()) ...[
                    Text(widget.nodes[index].getSubtitle())
                  ],
                  _InnerTimeline(messages: widget.nodes[index].messages),
                ]
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          return OutlinedDotIndicator(
            borderWidth: 2.5,
            size: 20,
          );
        },
        connectorBuilder: (_, index, ___) => SolidLineConnector(
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

class _InnerTimeline extends StatelessWidget {
  const _InnerTimeline({
    required this.messages,
  });

  final List<MessageNode> messages;

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == messages.length + 1;
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
            if (isEdgeIndex(index)) {
              return null;
            }
            return Padding(
              padding: EdgeInsets.only(left: 8, top: 16, bottom: 16),
                child: messages[index - 1]
            );
          },
          nodeItemOverlapBuilder: (_, index) =>
          isEdgeIndex(index) ? true : null,
          itemCount: messages.length + 2,
        ),
      ),
    );
  }
}