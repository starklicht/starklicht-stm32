
import 'dart:ui';

import 'package:starklicht_flutter/messages/imessage.dart';
import 'package:starklicht_flutter/model/enums.dart';

class FadeMessage extends IBluetoothMessage<FadeMessage> {
  @override
  MessageType messageType = MessageType.fade;

  Duration duration;
  Color color;
  bool ease;

  FadeMessage({required this.duration, required this.color, this.ease = true});


  @override
  List<int> getMessageBody({bool inverse = false}) {
    /*
  int minutes = (int) ((uint8_t) receivedChars[1] & 0xFF);
  int seconds = (int) ((uint8_t) receivedChars[2] & 0xFF);
  int millis = (int) ((uint8_t) receivedChars[3] & 0xFF);
  duration = minutes * 60000 + seconds * 1000 + millis * 50;
	// TODO: Map
	color.r = receivedChars[4] * 16;
	color.g = receivedChars[5] * 16;
	color.b = receivedChars[6] * 16;
	color.master = receivedChars[7] * 16;
	interpolation = receivedChars[8];
   */
    var body = [
      duration.inMinutes.remainder(60),
      duration.inSeconds.remainder(60),
      duration.inMilliseconds.remainder(1000) ~/ 50,
      color.red,
      color.green,
      color.blue,
      color.alpha,
      ease ? 4 : 0 // Interpolation type: ease.
    ];
    print(body);
    return body;
  }

}