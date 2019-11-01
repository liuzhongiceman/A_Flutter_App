import 'package:flutter/material.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'package:camera/camera.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

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
              Image.file(File(imagePath)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(
                        builder: (context) {
                          return RaisedButton(
                            onPressed: () {
                              Navigator.pop(context, imagePath);
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
