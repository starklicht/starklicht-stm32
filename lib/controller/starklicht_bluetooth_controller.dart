import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:starklicht_flutter/model/factory.dart';
import 'package:starklicht_flutter/persistence/persistence.dart';
import '../messages/imessage.dart';
const serviceUUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
const characterUUID = "0000ffe1-0000-1000-8000-00805f9b34fb";
const iosUUID = "FFE0";


class StarklichtBluetoothOptions {
  bool inverse;
  bool active;
  bool delay;
  int delayTimeMillis;
  String id;
  String? name;
  StarklichtBluetoothOptions(this.id, { this.inverse = false, this.active = true, this.delay = false, this.delayTimeMillis = 0, this.name });

  StarklichtBluetoothOptions withInverse(bool inverse) {
    this.inverse = inverse;
    return this;
  }

  StarklichtBluetoothOptions withActive(bool active) {
    this.active = active;
    return this;
  }

  StarklichtBluetoothOptions withDelay(bool delay) {
    this.delay = delay;
    return this;
  }

  StarklichtBluetoothOptions withDelayTime(int delayTimeMillis) {
    this.delayTimeMillis = delayTimeMillis;
    return this;
  }

  StarklichtBluetoothOptions withName(String? name) {
    this.name = name;
    return this;
  }

  Map<String, dynamic> toJson() => {
    'inverse': inverse,
    'active': active,
    'delay': delay,
    'delayTime': delayTimeMillis,
    'id': id,
    'name': name
  };
}

class StarklichtBluetoothOptionsFactory implements Factory<StarklichtBluetoothOptions> {
  @override
  StarklichtBluetoothOptions build(String params) {
    var json = jsonDecode(params);
    return StarklichtBluetoothOptions(
      json["id"],
      inverse: json["inverse"] as bool,
      active: json["active"] as bool,
      delay: json["delay"] as bool,
      delayTimeMillis: json["delayTime"],
      name: json["name"]
    );
  }

}

abstract class BluetoothController<T> {
  Stream<T> scan(int duration);
  Future stopScan();
  void connect(T device);
  int broadcast(IBluetoothMessage m);
  bool send(IBluetoothMessage m, T device);
  Stream<bool> scanning();
  Stream<T> getConnectionStream();
  Future<List<T>> connectedDevicesStream();
  Stream<BluetoothState> stateStream();
  Map<String, StarklichtBluetoothOptions> getOptions();
  String getName(String id);
  String? getCustomName(String id);
  StarklichtBluetoothOptions getOptionsByDevice(BluetoothDevice device);
  StarklichtBluetoothOptions getOptionsById(String uid);
  void updateOptions(Map<String, StarklichtBluetoothOptions> options);
  void registerOptionsCallback(Function(String) callback);
  void setOptions(String id, StarklichtBluetoothOptions o);
  Stream<List<StarklichtBluetoothOptions>> getOptionsStream();
  Stream<T> getDisconnectionStream();
  disconnect(BluetoothDevice d);
}

class BluetoothControllerWidget implements BluetoothController<BluetoothDevice> {
  static final BluetoothControllerWidget _instance = BluetoothControllerWidget._internal();
  factory BluetoothControllerWidget() => _instance;
  Function(String)? callback;

  BluetoothControllerWidget._internal();

  @override
  void updateOptions(Map<String, StarklichtBluetoothOptions> options) {
    this.options = options;
  }

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamController<BluetoothDevice> lamps = BehaviorSubject();
  StreamController<BluetoothDevice> connectionStream = BehaviorSubject();
  StreamController<BluetoothDevice> disconnectionStream = BehaviorSubject();
  StreamController<List<StarklichtBluetoothOptions>> optionsStream = BehaviorSubject();
  final Map<BluetoothDevice, BluetoothCharacteristic> deviceMap = {};
  Map<String, StarklichtBluetoothOptions> options = {};
  // final Map<BluetoothDevice, StarklichtBluetoothOptions> optionsMap = {};
  Stopwatch stopwatch = Stopwatch()..start();

  @override
  Map<String, StarklichtBluetoothOptions> getOptions() {
    return options;
  }

  @override
  Stream<BluetoothDevice> scan(int duration) {
    flutterBlue.scan(timeout: Duration(seconds: duration)).listen((res) {
      if(res.advertisementData.serviceUuids.contains(serviceUUID) || res.advertisementData.serviceUuids.contains(iosUUID)) {
        lamps.add(res.device);
      }
    });
    return lamps.stream;
  }


  @override
  void connect(BluetoothDevice device) async {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    var s = services.firstWhere((service) => service.uuid == Guid(serviceUUID));
    var c = s.characteristics.firstWhere((characteristic) =>
    characteristic.uuid == Guid(characterUUID));
    deviceMap[device] = c;
    // Put Options
    Persistence().getBluetoothOption(device.id.id).then((value) => {
      // Store it in controller
      options[device.id.id] = value,
      optionsStream.add(options.values.toList())
    });
    connectionStream.add(device);
  }

  Future stopScan() {
    return flutterBlue.stopScan();
  }

  bool canSend() {
    return stopwatch.elapsedMilliseconds > 20;
  }

  @override
  int broadcast(IBluetoothMessage m) {
    if (canSend()) {
      deviceMap.forEach((key, value) {
        if(!options.containsKey(key.id.id)) {
          Persistence().setBluetoothOption(key.id.id, StarklichtBluetoothOptions(key.id.id)).then((v) =>
          {
            m.send(value, v)
          });
        } else {
          m.send(value, options[key.id.id]!);
        }
      });
      stopwatch = Stopwatch()..start();
    }
    return deviceMap.length;
  }

  @override
  bool send(IBluetoothMessage m, BluetoothDevice device) {
    return false;
  }

  @override
  Stream<bool> scanning() {
    return flutterBlue.isScanning;
  }

  @override
  Stream<BluetoothDevice> getConnectionStream() {
    return connectionStream.stream;
  }

  @override
  Future<List<BluetoothDevice>> connectedDevicesStream() {
    return flutterBlue.connectedDevices;
  }

  @override
  Stream<BluetoothState> stateStream() {
    return flutterBlue.state;
  }

  @override
  StarklichtBluetoothOptions getOptionsByDevice(BluetoothDevice device) {
    return options[device.id]!;
  }

  @override
  StarklichtBluetoothOptions getOptionsById(String uid) {
    return options[uid]!;
  }


  @override
  void setOptions(String id, StarklichtBluetoothOptions o) {
    Persistence().setBluetoothOption(id, o).then((value) => {
      options[id] = value,
      optionsStream.add(options.values.toList())
    });
  }

  @override
  void registerOptionsCallback(Function(String) callback) {
    this.callback = callback;
  }

  @override
  Stream<List<StarklichtBluetoothOptions>> getOptionsStream() {
    return optionsStream.stream;
  }

  @override
  String getName(String id) {
    return getCustomName(id) ?? deviceMap.keys.firstWhereOrNull((element) =>
      element.id.id == id
    )?.name?? "No Name";
  }

  @override
  disconnect(BluetoothDevice d) {
    d.disconnect().then((value) => {
      options.removeWhere((key, value) => key == d.id.id),
      deviceMap.remove(d),
      optionsStream.add(options.values.toList()),
      disconnectionStream.add(d),
    });
  }

  @override
  Stream<BluetoothDevice> getDisconnectionStream() {
    return disconnectionStream.stream;
  }

  @override
  String? getCustomName(String id) {
    return options[id]?.name;
  }
}