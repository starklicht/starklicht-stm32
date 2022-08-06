
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

import '../messages/color_message.dart';
import '../messages/imessage.dart';
import '../model/orchestra.dart';
import '../persistence/persistence.dart';
import 'colors.dart';

enum EventStatus {
  NONE, PENDING, RUNNING, FINISHED
}

class EventChanged {
  int index;
  EventStatus status;
  EventChanged(this.index, this.status);
}

class ChildEventChanged {
  int parentIndex;
  int childIndex;
  EventStatus status;
  double? progress;
  ChildEventChanged(this.parentIndex, this.childIndex, this.status, {this.progress});
}

class MessageNodeExecutor {
  List<ParentNode> nodes;
  bool running;
  ValueChanged<double>? onProgressChanged;

  ValueChanged<EventChanged>? onEventUpdate;
  ValueChanged<ChildEventChanged>? onChildEventUpdate;

  MessageNodeExecutor(this.nodes, { this.running = false, this.onProgressChanged, this.onEventUpdate, this.onChildEventUpdate });

  Future<bool> waitForUserInput(BuildContext context) async {
    var continueProgram = false;
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text("Programm ist pausiert"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(strokeWidth: 2,),
          ],
        ),
        actions: [
          TextButton(onPressed: () =>
          {
            continueProgram = false,
            Navigator.pop(context)
          }, child: const Text("Abbrechen")),
          TextButton(onPressed: () => {
            continueProgram = true,
            Navigator.pop(context)
          }, child: const Text("Fortsetzen"))
        ],
      );
    }).then((value) => {
    });
    return continueProgram;
  }

  Future<void> execute(BuildContext context) async {
    var queue = Queue<ParentNode>();
    queue.addAll(nodes);
    print("Queue with ${queue.length} elements");
    running = true;
    int currentIndex = -1;
    while(queue.isNotEmpty && running) {
      var parent = queue.removeFirst();
      currentIndex++;
      onEventUpdate?.call(
        EventChanged(
          currentIndex,
          EventStatus.RUNNING
        )
      );
      var eventQueue = Queue<EventNode>();
      eventQueue.addAll(parent.messages);
      int currentChildIndex = -1;
      while(eventQueue.isNotEmpty && running) {
        var event = eventQueue.removeFirst();
        currentChildIndex++;
        onChildEventUpdate?.call(
          ChildEventChanged(currentIndex, currentChildIndex, EventStatus.RUNNING)
        );
        await event.execute();
        if(event.waitForUserInput) {
          print("Waiting for user Input");
          await waitForUserInput(context);
        } else if(event.delay.inMilliseconds > 0) {
          var startTime = DateTime.now().millisecondsSinceEpoch;
          running = true;
          var elapsedMillis = 0;
          do {
            await Future.delayed(const Duration(milliseconds: 50), () {
              elapsedMillis = DateTime.now().millisecondsSinceEpoch - startTime;
              print(elapsedMillis);
              var progress = elapsedMillis / event.delay.inMilliseconds;
              onChildEventUpdate?.call(
                ChildEventChanged(currentIndex, currentChildIndex, EventStatus.RUNNING, progress: progress));
            });
          } while(elapsedMillis <= event.delay.inMilliseconds);
        }
        onChildEventUpdate?.call(
            ChildEventChanged(currentIndex, currentChildIndex, EventStatus.FINISHED)
        );
      }
      onEventUpdate?.call(
          EventChanged(
              currentIndex,
              EventStatus.FINISHED
          )
      );
    }
    print("Finished");
  }
}

class OrchestraTimeline extends StatefulWidget {
  var running = false;
  var restart = false;
  VoidCallback? play;
  VoidCallback? onFinishPlay;

  List<ParentNode> nodes = [
    ParentNode(
      title: "Test",
      messages: [
        MessageNode(lamps: {}, message: ColorMessage.fromColor(Colors.purpleAccent), delay: Duration(seconds: 2),)
      ],
    ),
    ParentNode(
      title: "Test",
      messages: [
        MessageNode(lamps: {}, message: ColorMessage.fromColor(Colors.purpleAccent), delay: Duration(seconds: 2),)
      ],
    ),
    ParentNode(
      title: "Test",
      messages: [
        MessageNode(lamps: {}, message: ColorMessage.fromColor(Colors.purpleAccent), delay: Duration(seconds: 2),)
      ],
    ),
    ParentNode(
      title: "Test",
      messages: [
        MessageNode(lamps: {}, message: ColorMessage.fromColor(Colors.purpleAccent), delay: Duration(seconds: 2),)
      ],
    ),

    ParentNode(
      messages: [
        MessageNode(lamps: {}, message: ColorMessage.fromColor(Colors.purpleAccent), delay: Duration(seconds: 1),)
      ]
    ),
  ];
  OrchestraTimeline({Key? key, this.play, this.onFinishPlay}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrchestraTimelineState();
}

class OrchestraTimelineState extends State<OrchestraTimeline> {
  IconData getDraggingIcon(int length) {
    return Icons.collections_bookmark_outlined;
  }


  @override
  void initState() {
    super.initState();
    widget.play = () {
      print("OK LET'S GO!");
      var messages = widget.nodes.expand((element) => element.messages).toList();
      setState(() {
        for(var node in widget.nodes) {
          node.status = EventStatus.NONE;
        }
      });
      print(messages.length);
      MessageNodeExecutor(
        widget.nodes,
        onEventUpdate: (ev) => {
          setState(() {
            widget.nodes[ev.index].status = ev.status;
          })
        },
        onChildEventUpdate: (ev) {
          setState(() {
            widget.nodes[ev.parentIndex].messages[ev.childIndex].status = ev.status;
            widget.nodes[ev.parentIndex].messages[ev.childIndex].progress = ev.progress;
          });
          Future.delayed(Duration.zero, () => setState(() {
          }));
        }
      ).execute(context).then((value) {
        if(widget.restart) {
          widget.play?.call();
          return;
        }
        Future.delayed(Duration(seconds: 1),() {
          setState(() {
            for(var node in widget.nodes) {
              node.status = EventStatus.NONE;
              for(var message in node.messages) {
                message.status = EventStatus.NONE;
                message.progress = null;
              }
            }
          });
          widget.onFinishPlay?.call();
        });

      });
    };
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
                              Text(widget.nodes[index].title ?? "Sequenz ${index + 1}", style: Theme.of(context).textTheme.titleSmall),
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
          return ContainerIndicator(
            size: 40,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.ease,
              decoration: BoxDecoration(
                color: getDotIndicatorColor(index),
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(isRunning(index) ? .3: 0),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: isRunning(index) ? Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            ) :Icon(
              getIcon(index),
              size: 20,
            )
            ));
        },
        connectorBuilder: (_, index, ___) => hasReached(index) ? SolidLineConnector(
          color: getDotIndicatorColor(index),
        ) :  DashedLineConnector(
          gap: 6,
        ),
      ),
    );
  }

  bool hasReached(index) {
    if(index > widget.nodes.length - 1) {
      if(widget.nodes[widget.nodes.length - 1].status == EventStatus.FINISHED) {
        return true;
      }
      return false;
    }
    return widget.nodes[index].status == EventStatus.RUNNING || widget.nodes[index].status == EventStatus.FINISHED;
  }

  bool isRunning(index) {
    if(index > widget.nodes.length - 1) {
      return false;
    }
    return widget.nodes[index].status == EventStatus.RUNNING;
  }

  IconData getIcon(index) {
    if(index > widget.nodes.length - 1) {
      if(widget.nodes[widget.nodes.length - 1].status == EventStatus.FINISHED) {
        return Icons.checklist;
      }
      return Icons.flag;
    }
    switch(widget.nodes[index].status) {
      case EventStatus.NONE:
        return Icons.arrow_downward;
      case EventStatus.PENDING:
        return Icons.timelapse;
      case EventStatus.RUNNING:
        return Icons.add;
      case EventStatus.FINISHED:
        return Icons.check;
    }
  }

  Color getDotIndicatorColor(index) {
    if(index > widget.nodes.length - 1) {
      if(widget.nodes[widget.nodes.length - 1].status == EventStatus.FINISHED) {
        return Colors.green;
      }
      return Theme.of(context).colorScheme.background;
    }
    switch(widget.nodes[index].status) {
      case EventStatus.PENDING:
        return Colors.blueGrey;
      case EventStatus.RUNNING:
        return Colors.blue;
      case EventStatus.FINISHED:
        return Colors.green;
      case EventStatus.NONE:
        return Theme.of(context).colorScheme.background;
    }
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

  List<AnimationMessage> _animationStore = [];
  var _messageType = MessageType.brightness;
  var _currentBrightness = 100.0;
  var _currentColor = Colors.white;

  void refresh() {
    setState(() {});
  }

  void openAddDialog(BuildContext context, StateSetter setState) {
    showDialog(context: context, builder: (_) {
      Persistence().getAnimationStore().then((value) => _animationStore = value);
      int? selectedAnimation = 0;
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
                  startColor: _currentColor,
                  onChanged: (c) => { setState(() {
                    _currentColor = c;
                  }) },
                )
              ]
              else if (_messageType == MessageType.interpolated) ...[
                  Text("Animation aus Liste auswählen".toUpperCase(), style: Theme.of(context).textTheme.overline),
                  // Persistence
                  DropdownButton<int>(
                      items: _animationStore.mapIndexed((animation, index) => DropdownMenuItem<int>(value: index, child: Text(animation.title!))).toList(),
                      onChanged: (i) => {
                        setState(() {
                          selectedAnimation = i;
                        })
                    },
                    value: selectedAnimation,
                  )
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
                    if(_messageType == MessageType.interpolated) {
                      if(selectedAnimation != null ) {
                        message = _animationStore[selectedAnimation!];
                      }
                    }
                    if(message == null) {
                      return;
                    }
                    widget.messages.add(
                        MessageNode(lamps: {}, message: message)
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
  VoidCallback? onEdit;
  bool isDragGoal = false;
  bool finished;
  ExpansionDirection expansionDirection = ExpansionDirection.TOP;
  VoidCallback? doRefresh;

  DraggableMessageNode({Key? key, required this.message, required this.index, required this.parentId, this.onAccept, this.onDelete, this.dragExpansion = 78, this.finished = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DraggableMessageNodeState();
}

class DraggableMessageNodeState extends State<DraggableMessageNode>{
  bool timeIsExtended = false;

  Widget? getLeading (bool verySmall) {
    if(verySmall) {
      return null;
    }
    if(widget.message.status == EventStatus.RUNNING) {
      return Transform.scale(scale: 0.5, child: CircularProgressIndicator(value: widget.message.progress));
    } else if(widget.message.status == EventStatus.FINISHED) {
      return Icon(Icons.check, color: Colors.green,);
    }
    return null;
  }

  getCard(BuildContext context, {bool dragging = false, bool verySmall = false}) {
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
            leading: getLeading(verySmall),
            title:
            Text(currentMessage.getTitle(), style: Theme.of(context).textTheme.titleLarge),
            subtitle:
            verySmall ?
                widget.message.lamps.length == 0 ? Text("Keine Beschränkungen") : Text("${widget.message.lamps.length} Beschränkungen")
                :
            currentMessage.getSubtitle(context, Theme.of(context).textTheme.bodySmall!),
            trailing: verySmall ? null : Wrap(
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => {
                  openEditMessage(context, setState)
                }),
                IconButton(icon: Icon(Icons.delete), onPressed: () => {
                  widget.onDelete?.call()
                }),
              ],
            ),
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

  void openEditMessage(BuildContext context, StateSetter setState) {
    assert(widget.message is MessageNode);
    var m = widget.message as MessageNode;
    var _messageType = m.message.messageType;
    var _currentBrightness = m.message.toPercentage() * 100;
    var _currentColor = m.message.toColor();
    var _animationStore = [];
    showDialog(context: context, builder: (_) {
      Persistence().getAnimationStore().then((value) => _animationStore = value);
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Zeitevent ändern"),
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
                child: const Text("Ändern"),
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
                    m.onUpdateMessage?.call(message);
                  });
                  Future.delayed(Duration.zero, () => {
                    refresh()
                  });
                  refresh();
                  Navigator.pop(context);
                })
          ],
        );
      });
    });
  }

  void refresh() {
    setState(() {});
  }

}

