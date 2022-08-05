
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({Key? key, required this.onChanged, this.startDuration, this.small = false, this.disabled = false}) : super(key: key);
  final bool small;
  final bool disabled;
  final ValueChanged<Duration>? onChanged;
  final Duration? startDuration;

  @override
  State<StatefulWidget> createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  double height = 200;
  late FixedExtentScrollController minutesController;
  late FixedExtentScrollController secondsController;
  late FixedExtentScrollController millisController;
  late Duration duration;
  @override
  void initState() {
    super.initState();
    duration = widget.startDuration ?? const Duration();
    minutesController = FixedExtentScrollController(initialItem: duration.inMinutes.remainder(60));
    secondsController = FixedExtentScrollController(initialItem: duration.inSeconds.remainder(60));
    millisController = FixedExtentScrollController(initialItem: duration.inMilliseconds.remainder(1000) ~/ 50);
  }

  List<int> seconds() {
    return List<int>.generate(60, (index) => index++);
  }

  List<int> millis() {
    return List<int>.generate(20, (index) => index*=50);
  }

  handleChange(Duration d) {
    assert(widget.onChanged != null);
    widget.onChanged!.call(d);
  }

  updateDuration() {
    handleChange(Duration(minutes: minutesController.selectedItem, seconds: secondsController.selectedItem, milliseconds: millisController.selectedItem * 50));
  }

  collapse() {

  }

  @override
  Widget build(BuildContext context) {
    var theme = CupertinoThemeData(
        primaryColor: Theme.of(context).colorScheme.onBackground
    );
    return
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: CupertinoTheme(
                data: theme,
                child: CupertinoPicker(
                  onSelectedItemChanged: (index) => updateDuration(),
                  // controller: minutesController,
                  itemExtent: 28,
                  // physics:  FixedExtentScrollPhysics(),
                  scrollController: minutesController,
                  children:
                  seconds().map((e) => Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(e.toString()),
                  )).toList()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(widget.small ? "m" : "Minuten"),
            ),
            SizedBox(
              width: 50,
              child: CupertinoTheme(
                data: theme,
                child: CupertinoPicker(
                    onSelectedItemChanged: (index) => updateDuration(),
                    // controller: minutesController,
                    itemExtent: 28,
                    // physics:  FixedExtentScrollPhysics(),
                    scrollController: secondsController,
                    children:
                    seconds().map((e) => Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(e.toString()),
                    )).toList()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(widget.small ? "s" : "Sekunden"),
            ),
            SizedBox(
              width: 50,
              child: CupertinoTheme(
                data: theme,
                child: CupertinoPicker(
                    onSelectedItemChanged: (index) => updateDuration(),
                    // controller: minutesController,
                    itemExtent: 28,
                    // physics:  FixedExtentScrollPhysics(),
                    scrollController: millisController,
                    children:
                    millis().map((e) => Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(e.toString()),
                    )).toList()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(widget.small ? "ms" : "Millisekunden"),
            ),

          ],
        ),
      );
  }
}