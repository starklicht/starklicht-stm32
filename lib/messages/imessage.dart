import 'package:flutter_blue/flutter_blue.dart';

enum MessageType {
  color, interpolated, request, onoff, poti, brightness, save, clear
}

extension MessageTypeExtension on MessageType {
  int get id {
    switch(this) {
      case MessageType.color:
        return 0;
      case MessageType.interpolated:
        return 1;
      case MessageType.request:
        return 2;
      case MessageType.onoff:
        return 3;
      case MessageType.poti:
        return 4;
      case MessageType.brightness:
        return 5;
      case MessageType.save:
        return 6;
      case MessageType.clear:
        return 255;
    }
  }
}

abstract class IBluetoothMessage {
  abstract MessageType messageType;
  static const int endChar = 10;
  static const int escapeChar = 0;

  static const List<int> endOfMessageSign = [escapeChar, endChar];

  List<int> getMessageBody();

  List<int> escape(int character) {
    return character == escapeChar?[escapeChar, character]:[character];
  }

  List<int> escapeList(List<int> message) {
    List<int> buffer = [];
    for (var character in message) {
      buffer.addAll(escape(character));
    }
    return buffer;
  }

  Future<void> send(BluetoothCharacteristic c) async {
    // Build Message: ID - BODY - END-OF-MESSAGE-SIGN
    List<int> message = escape(messageType.id);
    message.addAll(escapeList(getMessageBody()));
    message.addAll(endOfMessageSign);
    // Send to Device!
    return c.write(message, withoutResponse: true);
  }

  void broadcast(List<BluetoothCharacteristic> broadcastList) async {
    for (var b in broadcastList) {
      send(b);
    }
  }
}
