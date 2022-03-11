import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:starklicht_flutter/controller/animators.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/messages/animation_message.dart';
import 'package:starklicht_flutter/model/animation.dart';
import 'package:starklicht_flutter/model/enums.dart';
import 'package:starklicht_flutter/model/redux.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';

import 'colors.dart';

abstract class IGradientChange {
  StreamController<List<ColorPoint>> streamSubject = BehaviorSubject();

  Stream<List<ColorPoint>> stream();
}

abstract class IAnimationSettingsChange {
  StreamController<AnimationSettingsConfig> streamSubject = BehaviorSubject();

  Stream<AnimationSettingsConfig> stream();
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

extension on Color {
  Color blendWithPercentage(Color b, double absolutePercentage) {
    return Color.fromARGB(
        (alpha * absolutePercentage + b.alpha * (1 - absolutePercentage))
            .toInt(),
        (red * absolutePercentage + b.red * (1 - absolutePercentage)).toInt(),
        (green * absolutePercentage + b.green * (1 - absolutePercentage))
            .toInt(),
        (blue * absolutePercentage + b.blue * (1 - absolutePercentage))
            .toInt());
  }
}

class GradientEditorWidget extends StatefulWidget {
  GradientSettingsConfig gradient;
  Function? callback;

  GradientEditorWidget({Key? key, required this.gradient, this.callback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GradientEditorWidgetState();
}

class ColorPoint {
  Color color;
  double point;

  Map<String, dynamic> toJson() => {'color': color.value, 'point': point};

  ColorPoint(this.color, this.point);
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text("Farbe ändern"),
      content: Container(
        child: ColorsWidget(
            sendOnChange: false,
            changeCallback: (color) => {widget.color = color},
            startColor: widget.color),
      ),
      actions: [
        TextButton(
            child: Text("Abbrechen"),
            onPressed: () => {Navigator.pop(context)}),
        TextButton(
            child: Text("Speichern"),
            onPressed: () {
              widget.saveCallback(widget.color);
              Navigator.pop(context);
            })
      ],
    );
  }
}

class AnimationSettings extends StatefulWidget {
  AnimationSettingsConfig settings;
  Function? callback;

  AnimationSettings({Key? key, required this.settings, this.callback})
      : super(key: key);

  @override
  _AnimationSettingsWidgetState createState() =>
      _AnimationSettingsWidgetState();
}

class _AnimationSettingsWidgetState extends State<AnimationSettings>
    implements IAnimationSettingsChange {
  @override
  StreamController<AnimationSettingsConfig> streamSubject = BehaviorSubject();

  List<bool> isSelected = [true, false, false, false];
  List<bool> isSelectedInterpolation = [true, false];
  double _currentSeconds = 1;
  double _currentMillis = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentSeconds = widget.settings.seconds.toDouble();
      _currentMillis = widget.settings.millis.toDouble();
      isSelectedInterpolation = [false, false];
      isSelectedInterpolation[widget.settings.interpolationType.index] = true;
      isSelected = [false, false, false, false];
      isSelected[widget.settings.timefactor.index] = true;
    });
  }

  int selIndex(List<bool> array) {
    return array.indexWhere((element) => element == true);
  }

  InterpolationType getInterpolation() {
    return isSelectedInterpolation.indexWhere((i) => i == true) == 1
        ? InterpolationType.constant
        : InterpolationType.linear;
  }

  TimeFactor getTimeFactor() {
    var s = isSelected.indexWhere((i) => i == true);
    switch (s) {
      case 0:
        return TimeFactor.repeat;
      case 1:
        return TimeFactor.pingpong;
      case 2:
        return TimeFactor.shuffle;
      case 3:
        return TimeFactor.once;
    }
    throw Exception("This should not have happened.");
  }

  void updateCurrentConfig() {
    // Notify listeners through stream
    setState(() {
      widget.settings.seconds = _currentSeconds.round();
      widget.settings.millis = _currentMillis.round();
      widget.settings.timefactor = getTimeFactor();
      widget.settings.interpolationType = getInterpolation();
    });
    if (widget.settings.callback != null) {
      widget.settings.callback!();
    }
  }

  @override
  void dispose() {
    streamSubject.close();
    super.dispose();
  }

  String getRepeatText() {
    switch (selIndex(isSelected)) {
      case 0:
        return "Schleife";
      case 1:
        return "Ping Pong";
      case 2:
        return "Zufall";
      case 3:
        return "Einmalig";
    }
    return "Unbekannt";
  }

  String getAnimationText() {
    switch (selIndex(isSelectedInterpolation)) {
      case 0:
        return "Linear";
      case 1:
        return "Konstant";
    }
    return "Unbekannt";
  }

  List<String> getPossibleSeconds() {
    List<String> r = [];
    for (var i = 0; i < 61; i++) {
      r.add("$i");
    }
    return r;
  }

  showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              child: Row(children: <Widget>[
                Expanded(
                    child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      _currentSeconds = value.toDouble();
                      updateCurrentConfig();
                    });
                  },
                  itemExtent: 35.0,
                  children: getPossibleSeconds().map((e) => Text(e)).toList(),
                )),
                Expanded(
                    child: CupertinoPicker(
                        itemExtent: 35,
                        onSelectedItemChanged: (value) => {},
                        children:
                            getPossibleSeconds().map((e) => Text(e)).toList()))
              ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        child: Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const Text("Interpolation: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(getAnimationText()),
                  ],
                ),
                const SizedBox(height: 12),
                ToggleButtons(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  children: const <Widget>[
                    Icon(Icons.horizontal_rule),
                    Icon(Icons.linear_scale),
                  ],
                  isSelected: isSelectedInterpolation,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < isSelectedInterpolation.length; i++) {
                        isSelectedInterpolation[i] = false;
                      }
                      isSelectedInterpolation[index] = true;
                      updateCurrentConfig();
                    });
                  },
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text("Zeitfaktor: ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(getRepeatText()),
              ]),
              SizedBox(height: 12),
              ToggleButtons(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                children: const <Widget>[
                  Icon(Icons.repeat),
                  Icon(Icons.swap_horiz),
                  Icon(Icons.shuffle),
                  Icon(Icons.looks_one)
                ],
                isSelected: isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = false;
                    }
                    isSelected[index] = true;
                    updateCurrentConfig();
                  });
                },
              )
            ])
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        margin: EdgeInsets.all(12),
      ),
      Container(
        margin: EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            const Text("Dauer ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_currentMillis + _currentSeconds == 0) ...[Icon(Icons.warning)]
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<double>(
                value: _currentSeconds,
                items: [for (var i = 0; i <= 60; i++) i].map((value) =>
                    DropdownMenuItem<double>(
                        value: value.toDouble(),
                        child: Text("$value Sekunde${value==1?'':'n'}")
                    )
                ).toList(),
                onChanged: (d) => setState(() {
                  _currentSeconds = d!;
                  updateCurrentConfig();
                }),
              ),
              Text("+"),
              DropdownButton<double>(
                value: _currentMillis,
                items: [for (var i = 0; i <= 20; i++) i].map((value) =>
                    DropdownMenuItem<double>(
                        value: value.toDouble() * 50,
                        child: Text("${value * 50} Millisekunden")
                    )
                ).toList(),
                onChanged: (d) => setState(() {
                  _currentMillis = d!;
                  updateCurrentConfig();
                }),
              )
            ]
          )
        ]),
      )
    ]);
  }

  void vibrate() async {
    // HapticFeedback.selectionClick();
  }

  @override
  Stream<AnimationSettingsConfig> stream() {
    return streamSubject.stream;
  }
}

class ColorPickerWidget extends StatefulWidget {
  Color color;
  Function(Color c) saveCallback;

  ColorPickerWidget({Key? key, required this.color, required this.saveCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerWidgetState();
}

class _GradientEditorWidgetState extends State<GradientEditorWidget> {
  // final _startState = [ColorPoint(Colors.black, 0), ColorPoint(Colors.white, 1)];
  int? _activeIndex;
  double circleRadius = 32;
  double boundingBoxSize = 80;
  double widgetHeight = 80;
  bool _hasBeenTouched = false;
  var _tapPosition;
  var duplicateDistance = .25;

  double constrain(double value) {
    return value < 0
        ? 0
        : value > 1
            ? 1
            : value;
  }

  void duplicatePoint() {
    var p;
    if (_activeIndex == null) {
      return;
    }
    var c = widget.gradient.colors[_activeIndex!];
    if (c.point < 0.5) {
      p = c.point + duplicateDistance;
    } else {
      p = c.point - duplicateDistance;
    }
    setState(() {
      widget.gradient.colors.add(ColorPoint(c.color, p));
    });
    notify();
  }

  realignSpaceBetween() {
    int num = widget.gradient.colors.length - 1;
    for (int i = 0; i < widget.gradient.colors.length; i++) {
      setState(() {
        widget.gradient.colors[i].point = i / num;
      });
    }
    notify();
  }

  void _showCustomMenu() {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.content_copy), // your icon
              title: Text("Duplizieren"),
            ),
            value: 1,
            onTap: duplicatePoint,
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.delete), // your icon
              title: Text("Löschen"),
            ),
            value: 2,
            onTap: deletePoint,
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.horizontal_distribute), // your icon
              title: Text("Neu anordnen"),
            ),
            value: 3,
            onTap: realignSpaceBetween,
          )
        ],
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
            ));
  }

  double map(
      double x, double in_min, double in_max, double out_min, double out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }

  double getCanvasPosition(double pointPos) {
    return map(pointPos, (-boundingBoxSize + circleRadius) / 2, MediaQuery.of(context).size.width - (boundingBoxSize + circleRadius) / 2, 0, 1);
  }

  void storePosition(TapDownDetails details) =>
      _tapPosition = details.globalPosition;

  /// Returns a generated color for a given point
  Color getPointColor(double pointPos) {
    if (widget.gradient.colors.isEmpty) {
      return Colors.white;
    } else if (widget.gradient.colors.length == 1) {
      return widget.gradient.colors[0].color;
    }
    var left = widget.gradient.colors
        .where((element) => element.point <= pointPos)
        .toList()
      ..sort((a, b) => pointPos.compareTo(a.point));
    var right = widget.gradient.colors
        .where((element) => element.point > pointPos)
        .toList()
      ..sort((a, b) => pointPos.compareTo(a.point));
    print(left.map((e) => e.point));
    print(right.map((e) => e.point));
    if (left.isEmpty && right.isEmpty) {
      return Colors.white;
    } else if (left.isEmpty) {
      return right[0].color;
    } else if (right.isEmpty) {
      return left[0].color;
    }
    return left[0].color.blendWithPercentage(
        right[0].color, map(pointPos, left[0].point, right[0].point, 0, 1));
  }

  double getPointPosition(double pos) {
    return map(pos, 0, 1, (-boundingBoxSize + circleRadius) / 2, MediaQuery.of(context).size.width - (boundingBoxSize + circleRadius) / 2);
  }

  void addPoint(double globalPositionX) {
    var position = constrain(getCanvasPosition(globalPositionX - boundingBoxSize / 2));
    var color = getPointColor(position);
    var point = ColorPoint(color, position);
    setState(() {
      widget.gradient.colors.add(point);
      widget.gradient.colors.sort((a, b) => a.point.compareTo(b.point));
      _activeIndex = widget.gradient.colors.indexOf(point);
      _hasBeenTouched = true;
    });
    notify();
    print(widget.gradient.colors.map((e) => e.point));
  }

  void onDragEnd(double position, int pointIndex) {
    var pointPos = constrain(getCanvasPosition(position));
    setState(() {
      widget.gradient.colors[pointIndex].point = pointPos;
      var i = widget.gradient.colors[pointIndex];
      // Sort
      widget.gradient.colors.sort((a, b) => a.point.compareTo(b.point));
      _activeIndex = widget.gradient.colors.indexOf(i);
      _hasBeenTouched = true;
    });
    notify();
  }

  void onDragUpdate(DragUpdateDetails d, int pointIndex) {
    var pointPos = constrain(getCanvasPosition(d.globalPosition.dx));
    setState(() {
      widget.gradient.colors[pointIndex].point = pointPos;
      _hasBeenTouched = true;
    });
  }

  void updateColor(Color c) {
    setState(() {
      widget.gradient.colors[_activeIndex!].color = c;
    });
    notify();
  }

  void notify() {
    if (widget.gradient.callback != null) {
      widget.gradient.callback!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      Stack(
        clipBehavior: Clip.none,
          children: [
        GestureDetector(
            onTapUp: (e) => {addPoint(e.globalPosition.dx)},
            child: Container(
                height: widgetHeight,
                margin: EdgeInsets.only(
                    left: circleRadius / 2, right: circleRadius / 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors:
                          List.from(widget.gradient.colors.map((e) => e.color)),
                      stops: List.from(
                          widget.gradient.colors.map((e) => e.point))),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                      offset:
                          Offset(2.0, 2.0), // shadow direction: bottom right
                    ),
                  ],
                ))),
        ...widget.gradient.colors.mapIndexed((e, currentIndex) => Positioned(
            left: getPointPosition(e.point),
            top: (widgetHeight - boundingBoxSize) / 2,
            child: Draggable(
              child: GestureDetector(
                  onTap: () {
                    // Show Color Selection Dialog only when tapping item and is active already
                    if (currentIndex == _activeIndex) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return ColorPickerWidget(
                                color:
                                    widget.gradient.colors[_activeIndex!].color,
                                saveCallback: updateColor);
                          });
                    }
                    setState(() {
                      _activeIndex = currentIndex;
                    });
                  },
                  onTapDown: storePosition,
                  onLongPress: () {
                    setState(() {
                      _activeIndex = currentIndex;
                    });
                    // Open context menu
                    _showCustomMenu();
                  },
                  child: Container(
                      width: boundingBoxSize,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      height: boundingBoxSize,
                      child: Container(
                          width: circleRadius,
                          height: circleRadius,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == _activeIndex
                                  ? Colors.blueGrey
                                  : Colors.black,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ])))),
              feedback: Container(
                  width: boundingBoxSize,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  height: boundingBoxSize,
                  child: Container(
                  width: circleRadius,
                  height: circleRadius,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == _activeIndex
                          ? Colors.blueGrey
                          : Colors.black,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        )
                      ]))),
              childWhenDragging: Container(),
              axis: Axis.horizontal,
              onDragEnd: (d) => onDragEnd(d.offset.dx, currentIndex),
              onDragStarted: () => setState(() {
                _activeIndex = currentIndex;
              }),
              // TODO: Make Dragupdate work, so users see gradient in real time
              onDragUpdate: (d) => onDragUpdate(d, currentIndex),
            )))
      ]),
      Column(children: [
        if (true) ...[
          /* Container(
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Ink(
                  height: 32,
                  decoration: BoxDecoration(
                      color: _activeIndex == null
                          ? Colors.grey
                          : widget.gradient.colors[_activeIndex!].color,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        )
                      ]),
                ),
                onTap: () => _activeIndex == null
                    ? null
                    : showDialog(
                        context: context,
                        builder: (_) {
                          return ColorPickerWidget(
                              color:
                                  widget.gradient.colors[_activeIndex!].color,
                              saveCallback: updateColor);
                        })),
            margin: EdgeInsets.all(16),
          ), */
          Row(children: [
            TextButton.icon(
                onPressed: revertAll,
                label: Text("Zurücksetzen"),
                icon: const Icon(Icons.restore)),
            TextButton.icon(
                onPressed:
                    _activeIndex == null && widget.gradient.colors.length <= 2
                        ? null
                        : deletePoint,
                label: Text("Löschen"),
                icon: const Icon(Icons.highlight_remove)),
          ])
        ]
      ])
    ]);
  }

  revertAll() {
    setState(() {
      _activeIndex = null;
      widget.gradient.colors = [
        ColorPoint(Colors.black, 0),
        ColorPoint(Colors.white, 1)
      ];
      _hasBeenTouched = false;
    });
    notify();
  }

  deletePoint() {
    if (widget.gradient.colors.length <= 2) {
      return;
    }
    setState(() {
      widget.gradient.colors.removeAt(_activeIndex!);
      _activeIndex = null;
    });
    notify();
  }
}

class AnimationPreviewWidget extends StatefulWidget {
  AnimationSettingsConfig settings;
  GradientSettingsConfig colors;
  Function? callback;
  Set<Function> restartCallback;
  Set<Function> notify;
  bool isEditorPreview = false;

  AnimationPreviewWidget(
      {Key? key,
      required this.settings,
      required this.colors,
      this.callback,
      required this.restartCallback,
      required this.notify,
      required this.isEditorPreview})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationPreviewWidgetState();
}

class _AnimationPreviewWidgetState extends State<AnimationPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation colorAnimation;
  var isAnimationValid = true;

  void restart() {
    controller.reset();
    updateAnimationCallback();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.restartCallback.add(restart);
      widget.settings.callback = updateAnimationCallbackAndSend;
      widget.colors.callback = updateAnimationCallbackAndSend;
    });
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    controller.addListener(update);
    updateAnimationCallback();
  }

  void update() {
    setState(() {});
  }

  void updateAnimationCallbackAndSend() {
    updateAnimationCallback();
    for (var element in widget.notify) {
      element.call();
    }
  }

  void updateAnimationCallback() {
    // Save
    if (widget.isEditorPreview) {
      Persistence().saveEditorAnimation(
          KeyframeAnimation(widget.colors.colors, widget.settings, ''));
    }
    if (widget.settings.seconds + widget.settings.millis == 0) {
      setState(() {
        isAnimationValid = false;
      });
      return;
    }
    setState(() {
      isAnimationValid = true;
    });
    controller.duration = Duration(
        seconds: widget.settings.seconds, milliseconds: widget.settings.millis);
    if (widget.settings.interpolationType == InterpolationType.linear) {
      colorAnimation = BaseColorAnimation(widget.colors.colors,
              widget.settings.timefactor == TimeFactor.shuffle)
          .animate(controller);
    } else {
      colorAnimation = ConstantColorAnimator(widget.colors.colors,
              widget.settings.timefactor == TimeFactor.shuffle)
          .animate(controller);
    }
    if (widget.settings.timefactor == TimeFactor.once) {
      controller.forward(from: 0);
    } else {
      controller.repeat(
          reverse: widget.settings.timefactor == TimeFactor.pingpong);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            color: isAnimationValid ? colorAnimation.value : Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: isAnimationValid
                      ? colorAnimation.value
                      : Colors.transparent,
                  blurRadius: 32,
                  spreadRadius: 3)
            ]),
        child: isAnimationValid ? null : Icon(Icons.warning));
  }
}

class AnimationsEditorWidget extends StatefulWidget {
  const AnimationsEditorWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationsEditorWidgetState();
}

class _AnimationTaskbarWidgetState extends State<AnimationTaskbarWidget> {
  bool _syncWithLamp = false;
  bool _integrateAnimations = false;
  BluetoothController controller = BluetoothControllerWidget();

  void send() {
    controller
        .broadcast(AnimationMessage(widget.colors.colors, widget.settings));
  }

  bool errorState() {
    return widget.settings.seconds == 0 && widget.settings.millis == 0;
  }

  @override
  void initState() {
    super.initState();
    widget.notify.add(notify);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        TextButton.icon(
            label: Text("Senden"),
            onPressed: errorState() ? null : send,
            icon: Icon(Icons.settings_remote)),
        TextButton.icon(
            label: Text("Speichern"),
            onPressed: errorState()
                ? null
                : () => {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return SaveWidget(
                                animation: KeyframeAnimation(
                                    widget.colors.colors, widget.settings, ""));
                          })
                    },
            icon: Icon(Icons.save)),
      ], mainAxisAlignment: MainAxisAlignment.center),
      CheckboxListTile(
          value: _syncWithLamp,
          onChanged: (e) {
            setState(() {
              _syncWithLamp = e!;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: Text("Automatisch mit Lampe synchronisieren")),
      CheckboxListTile(
          value: _integrateAnimations,
          onChanged: (e) {
            setState(() {
              _integrateAnimations = e!;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: Text("Nahtlose Übergänge zwischen Animationen")),
    ]);
  }

  void notify() {
    setState(() {});
    if (_syncWithLamp) {
      send();
    }
  }
}

class AnimationTaskbarWidget extends StatefulWidget {
  Set<Function> notify;
  AnimationSettingsConfig settings;
  GradientSettingsConfig colors;

  BluetoothController controller = BluetoothControllerWidget();

  AnimationTaskbarWidget(
      {Key? key,
      required this.notify,
      required this.colors,
      required this.settings})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationTaskbarWidgetState();
}

class _SaveWidgetState extends State<SaveWidget> {
  String value = "";
  String name = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      name = widget.animation.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, StateSetter setState) {
      return AlertDialog(
        title: const Text('Animation speichern'),
        content: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Name der Animation',
          ),
          onChanged: (text) {
            setState(() {
              name = text;
            });
            // widget.animation.title = text.trim();
          },
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
              onPressed: () => {Navigator.pop(context)},
              child: Text('Abbrechen')),
          TextButton(
              onPressed: name.isEmpty
                  ? null
                  : () {
                      widget.animation.title = name.trim();
                      Persistence()
                          .existsByName(widget.animation.title)
                          .then((value) {
                        if (value) {
                          // Notify
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(
                                      'Animation "${widget.animation.title}" existiert bereits. Überschreiben?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        child: Text("Abbrechen")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Persistence()
                                              .saveAnimation(widget.animation);
                                          var snackBar = SnackBar(
                                            content: Text(
                                                'Animation "${widget.animation.title}" wurde überschrieben'),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        },
                                        child: Text("Überschreiben"))
                                  ],
                                );
                              });
                        } else {
                          Persistence().saveAnimation(widget.animation);
                          var snackBar = SnackBar(
                            content: Text(
                                'Animation "${widget.animation.title}" wurde gespeichert'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
                        }
                      });
                    },
              child: Text('Speichern'))
        ],
      );
    });
  }
}

class SaveWidget extends StatefulWidget {
  KeyframeAnimation animation;

  SaveWidget({Key? key, required this.animation}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SaveWidgetState();
}

class _AnimationsEditorWidgetState extends State<AnimationsEditorWidget> {
  AnimationSettingsConfig? settings;
  GradientSettingsConfig? gradient;
  Set<Function> restartCallback = {};
  Set<Function> notifyChanges = {};

  @override
  void initState() {
    super.initState();
    Persistence().getEditorAnimation().then((value) {
      setState(() {
        settings = value.config;
        gradient = GradientSettingsConfig(value.colors);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Persistence
    // settings = AnimationSettingsConfig(InterpolationType.linear, TimeFactor.repeat, 1, 0);
    // gradient = GradientSettingsConfig([ColorPoint(Colors.black, 0), ColorPoint(Colors.white, 1)]);
    Function? callback;
    if (settings == null || gradient == null) {
      return Container(child: Text("Lädt..."));
    } else {
      return Container(
          child: SingleChildScrollView(
              child: Column(children: [
        const Text(
          "Zeitverlauf\n",
          textAlign: TextAlign.start,
        ),
        GradientEditorWidget(gradient: gradient!, callback: callback),
        const Divider(height: 32),
        const Text(
          "Animationseinstellungen",
          textAlign: TextAlign.start,
        ),
        AnimationSettings(settings: settings!, callback: callback),
        const Divider(height: 32),
        const Text("Animationsvorschau"),
        const SizedBox(height: 12),
        AnimationPreviewWidget(
            settings: settings!,
            colors: gradient!,
            callback: callback,
            restartCallback: restartCallback,
            notify: notifyChanges,
            isEditorPreview: true),
        const Divider(height: 32),
        const Text("Aktionen"),
        const SizedBox(height: 12),
        AnimationTaskbarWidget(
            settings: settings!, colors: gradient!, notify: notifyChanges)
      ])));
    }
  }
}
