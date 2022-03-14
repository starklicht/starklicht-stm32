import 'imessage.dart';

class ColorMessage extends IBluetoothMessage {
  int maxValue = 255;
  int red, green, blue, master;

  ColorMessage(this.red, this.green, this.blue, this.master);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    if(inverse == false) {
      return [red, green, blue, master];
    } else {
      return [maxValue - red, maxValue - green, maxValue - blue, master];
    }
  }

  @override
  MessageType messageType = MessageType.color;
}