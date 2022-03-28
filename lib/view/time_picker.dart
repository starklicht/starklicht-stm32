
import 'package:flutter/cupertino.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({Key? key, required this.onChanged, this.startDuration}) : super(key: key);

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
    duration = widget.startDuration ?? Duration();
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
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Minuten"),
          ),
          Container(
            width: 50,
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Sekunden"),
          ),
          Container(
            width: 50,
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Millisekunden"),
          ),

        ],
      );
  }
}