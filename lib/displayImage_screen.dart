import 'package:flutter/material.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'package:camera/camera.dart';
import 'process_image.dart';
import "package:mlkit/mlkit.dart";
import 'post_item.dart';


// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Post_item item;

  const DisplayPictureScreen({Key key, this.imagePath, this.item}) : super(key: key);
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<VisionLabel> currentLabels = <VisionLabel>[];
  File file;


  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('HyperGarageSale'),
          backgroundColor: Colors.pink,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.file(File(widget.imagePath)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(
                        builder: (context) {
                          return RaisedButton(
                            onPressed: () async {
                              var file = File(widget.imagePath);
                              setState(() {
                                file = file;
                              });

                              var currentLabels =
                              await detector.detectFromBinary(file?.readAsBytesSync());
                              setState(() {
                                currentLabels = currentLabels;
                              });
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Process_Image(imagePath: widget.imagePath, file: file, list:currentLabels, item: widget.item),
                                ),
                              );
                              Navigator.pop(context, widget.imagePath);
//                              Navigator.pop(context, res);
                              Navigator.pushNamed(context, Process_Image.id);
                            },
                            color: Colors.pink,
                            textColor: Colors.white,
                            child: Text('Use this picture'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(
                        builder: (context) {
                          return RaisedButton(
                            onPressed: () async {
                              final cameras = await availableCameras();
                              final firstCamera = cameras.first;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TakePictureScreen(camera: firstCamera),
                                  ));
                            },
                            color: Colors.pink,
                            textColor: Colors.white,
                            child: Text('Retake a pciture'),
                          );
                        },
                      ),
                    ),
                  ])
            ]));
  }
}