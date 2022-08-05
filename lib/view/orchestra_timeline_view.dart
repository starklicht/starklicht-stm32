
import 'dart:collection';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';
import 'package:starklicht_flutter/messages/brightness_message.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/models.dart';
import 'package:starklicht_flutter/view/animations.dart';
import 'package:starklicht_flutter/view/time_picker.dart';
import 'package:timelines/timelines.dart';

import '../controller/orchestra_handler.dart';
import '../messages/color_message.dart';
import '../messages/imessage.dart';
import '../model/animation.dart';
import '../model/orchestra.dart';
import '../persistence/persistence.dart';
import 'colors.dart';

class OrchestraTimeline extends StatefulWidget {
  Map<NodeType, OrchestraNodeHandler> handlers = {};
  var queue = Queue<INode>();
  var running = false;
  var restart = true;

  var nodes = [
    ParentNode(
      title: "Polizei Action",
      messages: [MessageNode(lamps: {"atmosphere", "effect"}, message: ColorMessage.fromColor(Colors.red))],
      time: Duration(seconds: 1),
    ),
    ParentNode(
        messages: [MessageNode(lamps: {"fill", "key"}, message: ColorMessage.fromColor(Colors.blue))],
      time: Duration(milliseconds: 100)
    ),
    ParentNode(
        messages: [MessageNode(lamps: {"fill", "key"}, message: AnimationMessage.buildDefault())],
        time: Duration(milliseconds: 100)
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

  int expandedTitle = -1;
  DragType dragType = DragType.GROUP;

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
                  Text("Ende", style: Theme.of(context).textTheme.headline5),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ChoiceChip(
                      avatar:
                        Icon(Icons.repeat, color: widget.restart?Theme.of(context).colorScheme.secondary:null),
                      label: Text(widget.restart?"Wiederholung aktiviert":"Wiederholung deaktiviert"),
                      selected: widget.restart,
                      onSelected: (s) => {
                        setState(() {
                          widget.restart = s;
                        })
                      },
                    ),
                  )
                ] else ...[
                  LongPressDraggable<DragData>(
                    data: DragData(parentId: index, index: -1, dragType: DragType.GROUP),
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
                    child: DragTarget<DragData>(
                      onWillAccept: (DragData? d) {
                        // Only accepts if there is no data
                        if(d == null) {
                          return false;
                        }
                        if(widget.nodes[index].messages.isNotEmpty && d.dragType != DragType.GROUP) {
                          return false;
                        }
                        if(d.parentId == index) {
                          return false;
                        }
                        setState(() {
                          expandedTitle = index;
                          dragType = d.dragType;
                        });
                        return true;
                      },
                      onLeave: (DragData? d) {
                        setState(() {
                          expandedTitle = -1;
                        });
                      },
                      onAccept: (DragData d) {
                        if(d.dragType == DragType.NODE) {
                          setState(() {
                            expandedTitle = -1;
                            EventNode node = widget.nodes[d.parentId].messages.removeAt(d.index);
                            widget.nodes[index].messages.add(node);
                          });
                        } else {
                          setState(() {
                            expandedTitle = -1;
                            ParentNode p = widget.nodes.removeAt(d.parentId);
                            widget.nodes.insert(index, p);
                          });

                        }
                      },
                      builder: (
                          BuildContext context,
                          List<dynamic> accepted,
                          List<dynamic> rejected,
                        ) {
                        var style = Theme.of(context).textTheme.headline6;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.ease,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue.withOpacity(.2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              height: index == expandedTitle && dragType == DragType.GROUP ? 80 : 0,
                            ),
                            RichText(
                              text: TextSpan(
                                // Note: Styles for TextSpans must be explicitly defined.
                                // Child text spans will inherit styles from parent
                                style: style,
                                children: <TextSpan>[
                                  TextSpan(text: widget.nodes[index].title ?? "Sequenz ${index + 1}",
                                    style: TextStyle(
                                      fontStyle: widget.nodes[index].title == null ? FontStyle.italic : null
                                    )
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.ease,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                height: index == expandedTitle && dragType == DragType.NODE ? 80 : 0,
                            )
                          ],
                        );
                      }
                    ),
                  ),
                  InnerTimeline(
                      messages: widget.nodes[index].messages,
                      parentId: index,
                      onMoveNodeToOtherParent: (MoveNodeEvent e) {
                        setState(() {
                          EventNode node = widget.nodes[e.from.parentId].messages.removeAt(e.from.index);
                          widget.nodes[e.to.parentId].messages.insert(e.to.index, node);
                        });
                        // We can just move it here
                      },
                  ),
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
          gap: 6,
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
  List<EventNode> messages;
  int parentId;
  int dragTargetIndex = -1;
  int data = -1;
  ExpansionDirection expansionDirection = ExpansionDirection.BOTTOM;
  ValueChanged<MoveNodeEvent> onMoveNodeToOtherParent;

  InnerTimeline({Key? key, required this.messages, required this.parentId, required this.onMoveNodeToOtherParent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InnerTimelineState();
}

class MoveNodeEvent {
  DragData from;
  DragData to;

  @override
  String toString() {
    return "From: id = ${from.index}, parentId = ${from.parentId}, to: id = ${to.index}, parentId = ${to.parentId}";
  }

  MoveNodeEvent({required this.from, required this.to});
}

enum DragType {
  GROUP, NODE
}

class DragData {
  int parentId;
  int index;
  DragType dragType;
  DragData({required this.parentId, required this.index, required this.dragType});

  bool equals(var other) {
    if(other is DragData) {
      return parentId == other.parentId && index == other.index && dragType == other.dragType;
    }
    return false;
  }
}

enum ExpansionDirection {
  TOP, BOTTOM
}

class InnerTimelineState extends State<InnerTimeline> {

  List<KeyframeAnimation> _animationStore = [];
  var _messageType = MessageType.brightness;
  var _currentBrightness = 100.0;
  var _currentColor = Colors.white;

  void refresh() {
    setState(() {});
  }

  void openAddDialog(BuildContext context, StateSetter setState) {
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
              /* RadioListTile<MessageType>(value: MessageType.interpolated,
                  title: const Text("Animation"),
                  groupValue: _messageType,
                  onChanged: (value) => {setState((){ _messageType = value!; })}), */
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
                  startColor: _currentColor,
                  onChanged: (c) => { setState(() {
                    _currentColor = c;
                  }) },
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
                    // TODO: Implement factory pattern
                    IBluetoothMessage? message;
                    if(_messageType == MessageType.color) {
                      message = ColorMessage.fromColor(_currentColor);
                    } else if(_messageType == MessageType.brightness) {
                      message = BrightnessMessage(_currentBrightness.toInt());
                    }
                    if(message == null) {
                      return;
                    }
                    widget.messages.add(
                        MessageNode(lamps: const {}, message: message)
                    );
                  });
                  refresh();
                  Navigator.pop(context);
                })
          ],
        );
      });
    });
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
                  onPressed: () => {
                    openAddDialog(context, setState)
                  },
              );
            } else if(isEdgeIndex(index)) {
              return null;
            }
            return DraggableMessageNode(
                message: widget.messages[index - 1],
                index: index - 1,
                parentId: widget.parentId,
                onDelete: () => {
                  setState(() {
                    widget.messages.removeAt(index -1);
                  })
                },
                onAccept: (MoveNodeEvent event) {
                  print(event.toString());
                  if(event.from.parentId != event.to.parentId) {
                    widget.onMoveNodeToOtherParent.call(event);
                  } else {
                    setState(() {
                      EventNode node = widget.messages.removeAt(event.from.index);
                      widget.messages.insert(event.to.index, node);
                    });
                  }
                },
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

class DraggableMessageNode extends StatefulWidget {
  EventNode message;
  int index;
  double dragExpansion;
  int parentId;
  ValueChanged<MoveNodeEvent>? onAccept;
  VoidCallback? onDelete;
  bool isDragGoal = false;
  ExpansionDirection expansionDirection = ExpansionDirection.TOP;

  DraggableMessageNode({Key? key, required this.message, required this.index, required this.parentId, this.onAccept, this.onDelete, this.dragExpansion = 78}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DraggableMessageNodeState();
}

class DraggableMessageNodeState extends State<DraggableMessageNode>{
  bool timeIsExtended = false;

  Card getCard(BuildContext context, {bool dragging = false, bool verySmall = false}) {
    var currentMessage = widget.message;
    return Card(
      elevation: dragging ? 8.0 : 1.0,
      clipBehavior: Clip.antiAlias,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          currentMessage.displayAsProgressBar() ?
          LinearProgressIndicator(
            value: currentMessage.toPercentage(),
            minHeight: verySmall ? 4 : 8,
          )
              :Container(
            height: verySmall ? 4: 12,
            decoration: BoxDecoration(
              color: currentMessage.cardIndicator == CardIndicator.COLOR ? currentMessage.toColor() : null,
              gradient: currentMessage.cardIndicator == CardIndicator.GRADIENT ? currentMessage.toGradient() : null,
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
            verySmall ?
                widget.message.lamps.length == 0 ? Text("Keine Beschränkungen") : Text("${widget.message.lamps.length} Beschränkungen")
                :
            currentMessage.getSubtitle(context, Theme.of(context).textTheme.bodySmall!),
            trailing: verySmall ? null : IconButton(icon: Icon(Icons.delete), onPressed: () => {
              widget.onDelete?.call()
            }),
          ),
          if(!verySmall && widget.message.hasLamps())...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Gruppenbeschränkungen", style: Theme.of(context).textTheme.subtitle1),
            ),
            currentMessage,
            SizedBox(height: 12),
          ]
        ],
      ),
    );
  }

  ExpansionDirection? isHovering() {
    return widget.isDragGoal ? widget.expansionDirection : null;
  }

  bool isHoveringBottom() {
    return isHovering() == ExpansionDirection.BOTTOM;
  }

  bool isHoveringTop() {
    return isHovering() == ExpansionDirection.TOP;
  }

  GlobalKey key = GlobalKey();

  RenderBox getRenderBox() {
    return key.currentContext?.findRenderObject() as RenderBox;
  }

  DragData? willAccept(DragData from) {
    var newIndex;
    if(from.parentId == widget.parentId) {
      if(widget.index > from.index) {
        // When Moving down
        if(widget.expansionDirection == ExpansionDirection.TOP) {
          newIndex = widget.index - 1;
        } else {
          newIndex = widget.index;
        }
      } else {
        // When moving up
        if(widget.expansionDirection == ExpansionDirection.TOP) {
          newIndex = widget.index;
        } else {
          newIndex = widget.index + 1;
        }
      }
    } else {
      // If parent is different, we can just insert it
      if(widget.expansionDirection == ExpansionDirection.TOP) {
        newIndex = widget.index;
      } else {
        newIndex = widget.index + 1;
      }
    }
    var newPosition = DragData(parentId: widget.parentId, index: newIndex, dragType: DragType.NODE);
    if(from.equals(newPosition)) {
      print("Nothing changed");
      return null;
    }
    return newPosition;
  }
  
  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DragData>(
      childWhenDragging: Opacity(opacity: .2, child: getCard(context)),
      data: DragData(parentId: widget.parentId, index: widget.index, dragType: DragType.NODE),
      child: DragTarget(
        key: key,
        onMove: (DragTargetDetails<DragData> details)  {
          RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
          Offset position = box.localToGlobal(Offset.zero); //this is global position
          double y = position.dy; //this is y - I think it's what you want
          double height = box.size.height;
          if(y + height / 2 > details.offset.dy) {
            setState(() {
              widget.expansionDirection = ExpansionDirection.TOP;
            });
          } else {
            setState(() {
              widget.expansionDirection = ExpansionDirection.BOTTOM;
            });
          }
        },
        onWillAccept: (DragData? data) {
          if(data?.index == widget.index && data?.parentId == widget.parentId || data?.dragType == DragType.GROUP) {
            return false;
          }
          setState(() {
            widget.isDragGoal = true;
          });
          return true;
        },
        onLeave: (DragData? data) => {
          setState(() {
            widget.isDragGoal = false;
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
                height: isHoveringTop() ? widget.dragExpansion : 0,
                duration: Duration(milliseconds: 100),
                curve: Curves.ease,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              getCard(context),
               AnimatedContainer(
                height: isHoveringBottom() ? widget.dragExpansion : 0,
                duration: Duration(milliseconds: 100),
                curve: Curves.ease,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )
            ],
          );
        },
        onAccept: (DragData data) => {
          setState(() {
            widget.isDragGoal = false;
            // Move
            int newIndex = widget.index;
            // If moving to the same parent, we have to consider that this element is taken out
            if(data.parentId == widget.parentId) {
              if(widget.index > data.index) {
                // When Moving down
                if(widget.expansionDirection == ExpansionDirection.TOP) {
                  newIndex = widget.index - 1;
                } else {
                  newIndex = widget.index;
                }
              } else {
                // When moving up
                if(widget.expansionDirection == ExpansionDirection.TOP) {
                  newIndex = widget.index;
                } else {
                  newIndex = widget.index + 1;
                }
              }
            } else {
              // If parent is different, we can just insert it
              if(widget.expansionDirection == ExpansionDirection.TOP) {
                newIndex = widget.index;
              } else {
                newIndex = widget.index + 1;
              }
            }

            var newPosition = DragData(parentId: widget.parentId, index: newIndex, dragType: DragType.NODE);
            if(data.equals(newPosition)) {
              print("Nothing changed");
              return;
            }
            var event = MoveNodeEvent(
                from: data,
                to: newPosition
            );
            print(event);
            widget.onAccept?.call(event);
          })
        },
      ),
      dragAnchorStrategy: myOffset,
      feedback: Container(
        width: 200,
        height: widget.dragExpansion,
        child: getCard(context, dragging: true, verySmall: true),
      ),
    );
  }

  Offset myOffset(Draggable<Object> draggable, BuildContext context, Offset position) {
    final RenderBox renderObject = context.findRenderObject()! as RenderBox;
    var pos = renderObject.globalToLocal(position);
    return Offset(pos.dx, widget.dragExpansion / 2);
  }
}

