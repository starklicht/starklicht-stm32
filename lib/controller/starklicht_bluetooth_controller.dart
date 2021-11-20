import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

const uuid = "0000ffe0-0000-1000-8000-00805f9b34fb";

abstract class BluetoothMessage {

}

abstract class BluetoothController<T> {
  Stream<T> scan(int duration);
  Future stopScan();
  void connect(T device);
  int broadcast(BluetoothMessage m);
  bool send(BluetoothMessage m, T device);
  Stream<bool> scanning();
  Stream<Future<T>> getConnectionStream();
  Future<List<BluetoothDevice>> connectedDevicesStream();
}

class BluetoothControllerWidget implements BluetoothController<BluetoothDevice> {
  static final BluetoothControllerWidget _instance = BluetoothControllerWidget._internal();
  factory BluetoothControllerWidget() => _instance;

  BluetoothControllerWidget._internal();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamController<BluetoothDevice> lamps = BehaviorSubject();
  StreamController<Future<BluetoothDevice>> connectionStream = BehaviorSubject();

  @override
  Stream<BluetoothDevice> scan(int duration) {
    flutterBlue.scan(timeout: Duration(seconds: duration)).listen((res) {
      if(res.advertisementData.serviceUuids.contains(uuid)) {
        lamps.add(res.device);
      }
    });
    return lamps.stream;
  }

  @override
  void connect(BluetoothDevice device) {
    connectionStream.add(device.connect().then((value) => device));
  }

  @override
  Future stopScan() {
    return flutterBlue.stopScan();
  }

  @override
  int broadcast(BluetoothMessage m) {
    // TODO: implement broadcast
    throw UnimplementedError();
  }

  @override
  bool send(BluetoothMessage m, BluetoothDevice device) {
    return false;
  }

  @override
  Stream<bool> scanning() {
    return flutterBlue.isScanning;
  }

  @override
  Stream<Future<BluetoothDevice>> getConnectionStream() {
    return connectionStream.stream;
  }

  @override
  Future<List<BluetoothDevice>> connectedDevicesStream() {
    return flutterBlue.connectedDevices;
  }
}