import 'imessage.dart';

class SaveMessage extends IBluetoothMessage {
  bool save = true;
  int button;

  SaveMessage(this.save, this.button);

  @override
  List<int> getMessageBody({ bool inverse = false }) {
    return [
      save?1:0,
      button
    ];
  }

  @override
  MessageType messageType = MessageType.save;
}