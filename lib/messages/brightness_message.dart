import 'imessage.dart';

class BrightnessMessage extends IBluetoothMessage {
  int brightness;

  BrightnessMessage(this.brightness);

  @override
  List<int> getMessageBody() {
    return [
      brightness
    ];
  }

  @override
  MessageType messageType = MessageType.brightness;
}