
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
        const Text("Orchester"),
        TextButton(onPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OrchestraWidget()))
        }
        , child: const Text("Öffne Dialog")),
      ],
    );
  }

}