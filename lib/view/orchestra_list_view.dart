
import 'package:timelines/timelines.dart';
import 'package:flutter/material.dart';
import 'package:starklicht_flutter/view/orchestra.dart';

import 'orchestra_timeline_view.dart';

class OrchestraListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrchestraLiveViewState();

  List<String> animations = [
    "Mori Show",
    "Crazy Show",
    "Inception - Part 1, Scene 2",
    "Test",
    "Test 2"
  ];
  List<String> images = [
    "https://saarlouis.my-movie-world.de/images/Breite_400px_RGB/p_99343.jpg",
    "https://de.web.img3.acsta.net/pictures/21/03/03/20/40/1002269.jpg",
    "https://upload.wikimedia.org/wikipedia/de/0/04/Scary_movie3_logo.jpg",
    "http://cineprog.de/images/Breite_235px_RGB/p_79860.jpg",
    "https://i.ytimg.com/vi/Hi-kQn3ze4o/maxresdefault.jpg"
  ];
  List<bool> playing = [
    false,
    false,
    false,
    false,
    false
  ];
}

class OrchestraLiveViewState extends State<OrchestraListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.animations.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          child: InkWell(
            onTap: () => {
              showDialog(context: context, builder: (_) {
                return AlertDialog(
                  insetPadding: EdgeInsets.all(16),
                  contentPadding: EdgeInsets.all(16),
                  title: Text(widget.animations[index]),
                  content: Container(
                    height: 20000,
                    width: 2000,
                    child: OrchestraTimeline()
                  ),
                  actions: [
                    TextButton(onPressed: () => {}, child: Text("Abbrechen")),
                    TextButton(onPressed: () => {}, child: Text("Speichern"))
                  ],
                );
              })
            },
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.images[index]),
              ),
              trailing: IconButton(
                onPressed: ()  {
                  setState(() {
                    widget.playing[index] = !widget.playing[index];
                  });
                  Future.delayed(Duration(seconds: 1), () => {
                    setState(() {
                      widget.playing[index] = false;
                    })
                  });
                },
                icon: Icon(widget.playing[index] ? Icons.stop : Icons.play_arrow),
              ),
              title: Text(widget.animations[index]),
              subtitle: Text("Animation")
            ),
          ),
        );
      }
    );
  }

}