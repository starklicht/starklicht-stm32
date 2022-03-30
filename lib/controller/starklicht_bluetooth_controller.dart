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

class SBluetoothDevice {
  BluetoothDevice device;
  StarklichtBluetoothOptions options;
  BluetoothCharacteristic? characteristic;
  SBluetoothDevice(this.device, this.options, this.characteristic);
}

enum ConnectionType {
  CONNECT, DISCONNECT
}

class ConnectionDiff {
  SBluetoothDevice device;
  ConnectionType type;
  bool auto;
  ConnectionDiff(this.device, this.type, this.auto);
}

abstract class BluetoothController<T> {
  Stream<List<T>> scan(int duration);
  Future stopScan();
  void connect(T device);
  int broadcast(IBluetoothMessage m);
  bool send(IBluetoothMessage m, T device);
  Stream<bool> scanning();
  Stream<List<T>> connectedDevicesStream();
  Stream<BluetoothState> stateStream();
  String getName(String id);
  String? getCustomName(String id);
  void registerOptionsCallback(Function(String) callback);
  void setOptions(String id, StarklichtBluetoothOptions o);
  disconnect(T d);

  Stream<ConnectionDiff> connectionChangeStream();
}

class BluetoothControllerWidget implements BluetoothController<SBluetoothDevice> {
  static final BluetoothControllerWidget _instance = BluetoothControllerWidget._internal();
  factory BluetoothControllerWidget() => _instance;
  Function(String)? callback;
  var makingConnectOperation = false;


  BluetoothControllerWidget._internal() {
    registerHandlers();
  }

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamController<List<SBluetoothDevice>> foundDevicesStream = BehaviorSubject();
  StreamController<List<SBluetoothDevice>> connectionStream = BehaviorSubject();
  StreamController<ConnectionDiff> connectionChanges = BehaviorSubject();
  List<SBluetoothDevice> foundDevices = [];
  List<SBluetoothDevice> connectedDevices = [];
  // StreamController<List<StarklichtBluetoothOptions>> optionsStream = BehaviorSubject();
  // final Map<BluetoothDevice, BluetoothCharacteristic> deviceMap = {};
  // Map<String, StarklichtBluetoothOptions> options = {};
  // final Map<BluetoothDevice, StarklichtBluetoothOptions> optionsMap = {};
  Stopwatch stopwatch = Stopwatch()..start();


  void registerHandlers() {
    print("REGISTER HANDLERS!!!");
    Timer.periodic(Duration(seconds: 2), (_) {
      flutterBlue.connectedDevices.then((value) async {
        if(makingConnectOperation) {
          return;
        }
        // Find all devices that disconnected
        var disconnections = connectedDevices.map((e) => e.device.id.id).where((element) =>
          !value.map((e1) => e1.id.id).contains(element)
        );
        var newConnections = value.map((e) => e.id.id).where((element) =>
          !connectedDevices.map((e1) => e1.device.id.id).contains(element)
        );
        if(disconnections.isNotEmpty) {
          // Notify user
          for(var d in disconnections) {
            var currentD = connectedDevices.firstWhere((element) =>
                d == element.device.id.id
            );
            connectionChanges.add(
              ConnectionDiff(currentD, ConnectionType.DISCONNECT, true)
            );
            // remove from connections
          }
          connectedDevices.removeWhere((e) => disconnections.contains(e.device.id.id));
          connectionStream.add(connectedDevices);
        };
        if(newConnections.isNotEmpty) {
          var a = <SBluetoothDevice>[];
          for(var d in newConnections) {
            var con = value.firstWhere((element) => d == element.id.id);
            var b = await postConnect(con);
            a.add(b);
            connectionChanges.add(ConnectionDiff(b, ConnectionType.CONNECT, true));
          }
          connectedDevices.addAll(a);
          connectionStream.add(connectedDevices);
        }
      });
    });
  }

  Future<StarklichtBluetoothOptions> getOption(String id) async {
    return await Persistence().getBluetoothOption(id);
  }

  @override
  Stream<List<SBluetoothDevice>> scan(int duration) {
    flutterBlue.stopScan().then((value) => {
        foundDevices.clear(),
        foundDevicesStream.add(foundDevices),
        flutterBlue.scan(timeout: Duration(seconds: duration)).listen((res) {
            if (res.advertisementData.serviceUuids.contains(serviceUUID) ||
                res.advertisementData.serviceUuids.contains(iosUUID)) {
              getOption(res.device.id.id).then((option) => {
                foundDevices.add(
                  SBluetoothDevice(res.device, option, null)
                ),
                foundDevicesStream.add(foundDevices)
              });
            }
          })
        });
    return foundDevicesStream.stream;
  }

  @override
  void connect(SBluetoothDevice device) async {
    makingConnectOperation = true;
    await device.device.connect();
    postConnect(device.device).then((value) => {
      connectedDevices.add(
        value
      ),
      connectionStream.add(connectedDevices),
      connectionChanges.add(ConnectionDiff(value, ConnectionType.CONNECT, false)),
      makingConnectOperation = false
    });
  }

  Future<SBluetoothDevice> postConnect(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    var s = services.firstWhere((service) => service.uuid == Guid(serviceUUID));
    var c = s.characteristics.firstWhere((characteristic) =>
    characteristic.uuid == Guid(characterUUID));
    var o = await getOption(device.id.id);
    var d = SBluetoothDevice(device, o, c);
    return d;
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
      for (var value in connectedDevices) {
          m.send(value.characteristic!, value.options);
      }
      stopwatch = Stopwatch()..start();
    }
    return connectedDevices.length;
  }

  @override
  Future<int> broadcastWaiting(IBluetoothMessage m) async {
    if (canSend()) {
      for (var value in connectedDevices) {
        await m.send(value.characteristic!, value.options);
      }
      stopwatch = Stopwatch()..start();
    }
    return connectedDevices.length;
  }

  @override

  @override
  bool send(IBluetoothMessage m, SBluetoothDevice device) {
    return false;
  }

  @override
  Stream<bool> scanning() {
    return flutterBlue.isScanning;
  }

  @override
  Stream<List<SBluetoothDevice>> connectedDevicesStream() {
    return connectionStream.stream;
  }

  @override
  Stream<BluetoothState> stateStream() {
    return flutterBlue.state;
  }



  @override
  void setOptions(String id, StarklichtBluetoothOptions o) {
    Persistence().setBluetoothOption(id, o).then((value) => {
      connectedDevices.firstWhere((element) => element.device.id.id == id).options = o,
      connectionStream.add(connectedDevices)
    });
  }

  @override
  void registerOptionsCallback(Function(String) callback) {
    this.callback = callback;
  }

  @override
  String getName(String id) {
    return getCustomName(id) ?? connectedDevices.firstWhereOrNull((element) =>
      element.device.id.id == id
    )?.device.name ?? "No Name";
  }

  @override
  disconnect(SBluetoothDevice d) {
    makingConnectOperation = true;
    d.device.disconnect().then((value) {
      var remove = connectedDevices.firstWhere((element) => element.device.id.id == d.device.id.id);
      connectionChanges.add(ConnectionDiff(remove, ConnectionType.DISCONNECT, false));
      connectedDevices.remove(remove);
      connectionStream.add(connectedDevices);
      makingConnectOperation = false;
    });
  }

  @override
  String? getCustomName(String id) {
    return connectedDevices.firstWhere((element) => element.device.id.id == id).options.name;
  }

  @override
  Stream<ConnectionDiff> connectionChangeStream() {
    return connectionChanges.stream;
  }
}