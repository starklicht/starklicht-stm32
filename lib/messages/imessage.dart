import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/model/orchestra.dart';

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

abstract class IBluetoothMessage<T> {
  abstract MessageType messageType;
  static const int endChar = 10;
  static const int escapeChar = 0;
  bool isGradient = false;

  CardIndicator get indicator => CardIndicator.COLOR;

  Gradient? toGradient() {
    return null;
  }

  static const List<int> endOfMessageSign = [escapeChar, endChar];

  List<int> getMessageBody({ bool inverse = false });

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

  Future<void> send(BluetoothCharacteristic c, StarklichtBluetoothOptions options) async {
    if(!options.active) {
      return;
    }
    // Build Message: ID - BODY - END-OF-MESSAGE-SIGN
    List<int> message = escape(messageType.id);
    message.addAll(escapeList(getMessageBody(inverse: options.inverse)));
    message.addAll(endOfMessageSign);
    // Send to Device!
    if(Platform.isIOS) {
      // Split the messages in ios
      if(!options.delay || options.delayTimeMillis == 0) {
        int chunkSize = 20;
        for (var i = 0; i < message.length; i += chunkSize) {
          c.write(message.sublist(i, i+chunkSize > message.length ? message.length : i + chunkSize), withoutResponse: true);
        }
      } else {
        Future.delayed(Duration(milliseconds: options.delayTimeMillis), () {
          int chunkSize = 20;
          for (var i = 0; i < message.length; i += chunkSize) {
            c.write(message.sublist(i, i+chunkSize > message.length ? message.length : i + chunkSize), withoutResponse: true);
          }
        });
      }
    } else {
      if(!options.delay || options.delayTimeMillis == 0) {
        return c.write(message, withoutResponse: withoutResponse);
      } else {
        Future.delayed(Duration(milliseconds: options.delayTimeMillis), () {
          return c.write(message, withoutResponse: withoutResponse);
        });
      }
    }
  }

  bool withoutResponse = true;

  String retrieveText() {
    return "Not defined";
  }

  Color toColor() {
    return Colors.red;
  }

  bool displayAsProgressBar() {
    return false;
  }

  void setValue(T value) {
    // Return
  }

  double toPercentage() {
    return 1.0;
  }

  Map<String, dynamic> dataToJson() {
    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      "type": messageType.name,
      "data": dataToJson()
    };
  }

  /* void broadcast(List<BluetoothCharacteristic> broadcastList) async {
    for (var b in broadcastList) {
      send(b);
    }
  } */
}
