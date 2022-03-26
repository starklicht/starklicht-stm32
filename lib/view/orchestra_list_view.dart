
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/view/orchestra.dart';

class OrchestraListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrchestraLiveViewState();

}

class OrchestraLiveViewState extends State<OrchestraListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Orchester"),
        TextButton(onPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OrchestraWidget()))
        }
        , child: Text("Öffne Dialog"))
      ],
    );
  }

}