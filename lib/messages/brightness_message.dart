import 'imessage.dart';

class BrightnessMessage extends IBluetoothMessage {
  int brightness;

  BrightnessMessage(this.brightness);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    return [
      brightness
    ];
  }

  @override
  String retrieveText() {
    return "$brightness%";
  }

  @override
  MessageType messageType = MessageType.brightness;
}