
import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starklicht_flutter/controller/starklicht_bluetooth_controller.dart';
import 'package:starklicht_flutter/model/orchestra.dart';

abstract class OrchestraNodeHandler<T extends INode> {
  Future<bool> execute(T event, StreamController<double> progress, {BuildContext? context});
  Future<void> cancel();
  bool stopThread = false;
}

class TimedNodeHandler extends OrchestraNodeHandler<TimedNode> {
  bool running = false;
  StreamController<double>? controller;

  @override
  Future<bool> execute(TimedNode event, StreamController<double> progress, {BuildContext? context}) async {
    stopThread = false;
    controller = progress;
    var startTime = DateTime.now().millisecondsSinceEpoch;
    running = true;
    var elapsedMillis = 0;
    do {
      await Future.delayed(Duration(milliseconds: 10), () {
        elapsedMillis = DateTime.now().millisecondsSinceEpoch - startTime;
        progress.add(elapsedMillis / event.time.inMilliseconds);
      });
    } while(elapsedMillis <= event.time.inMilliseconds && !stopThread);
    progress.add(0);
    running = false;
    return true;
  }

  @override
  Future<void> cancel() async {
    stopThread = true;
    do {
      await Future.delayed(Duration(milliseconds: 10), () => {});
    } while(running);
    controller?.add(0);
  }
}

class UserInputHandler extends OrchestraNodeHandler<WaitUserNode> {
  @override
  Future<void> cancel() {
    // TODO: implement cancel
    throw UnimplementedError();
  }

  @override
  Future<bool> execute(WaitUserNode event, StreamController<double> progress, {BuildContext? context}) async {
    var continueProgram = false;
    await showDialog(context: context!, builder: (_) {
      return AlertDialog(
        title: Text("Programm ist pausiert"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2,),
          ],
        ),
        actions: [
          TextButton(onPressed: () =>
          {
            continueProgram = false,
            Navigator.pop(context)
          }, child: Text("Abbrechen")),
          TextButton(onPressed: () => {
            continueProgram = true,
            Navigator.pop(context)
          }, child: Text("Fortsetzen"))
        ],
      );
    }).then((value) => {
    });
    return continueProgram;
  }

}

class MessageNodeHandler extends OrchestraNodeHandler<MessageNode> {
  bool running = false;
  StreamController<double>? controller;

  @override
  Future<bool> execute(MessageNode event, StreamController<double> progress, {BuildContext? context}) async {
    await BluetoothControllerWidget().broadcast(event.message);
    return true;
  }

  @override
  Future<void> cancel() async {
    stopThread = true;
    do {
      await Future.delayed(Duration(milliseconds: 1), () => {});
    } while(running);
    controller?.add(0);
  }
}