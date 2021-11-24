import 'imessage.dart';

class ColorMessage extends IBluetoothMessage {
  int red, green, blue, master;

  ColorMessage(this.red, this.green, this.blue, this.master);

  @override
  List<int> getMessageBody() {
    return [red, green, blue, master];
  }

  @override
  MessageType messageType = MessageType.color;
}