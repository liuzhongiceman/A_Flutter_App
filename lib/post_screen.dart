import 'package:flutter/material.dart';
import 'list_view_screen.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'constants.dart';
import 'welcome_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PostPage extends StatefulWidget {
  static const id = 'postpage';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PostPage> {
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  final _auth = FirebaseAuth.instance;
  String title = "";
  int price = 0;
  String description = "";
  String image_path = "";
  String url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
        print('current user ${loggedInUser.email}');
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  void uploadImage() async {
    final StorageReference postImageRef =
        FirebaseStorage.instance.ref().child("Post Images");
    var timeKey = new DateTime.now();
    final StorageUploadTask uploadTask = postImageRef
        .child(timeKey.toString() + ".jpg")
        .putFile(File(image_path));
    var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      url = ImageUrl;
    });
    print("Image url = " + url);
  }

  @override
  Widget build(BuildContext context) {
    bool showSpinner = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('HyperGarageSale'),
        backgroundColor: Colors.pink,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              FirebaseAuth.instance.signOut();
              titleController.clear();
              priceController.clear();
              descriptionController.clear();
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
            child: Text("Log Out"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 32.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                      controller: titleController,
                      onChanged: (v) {
                        setState(() {
                          title = v;
                        });
                        print(v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter title of the item',
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                      controller: priceController,
                      onChanged: (v) {
                        setState(() {
                          price = int.parse(v);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Enter price",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                      controller: descriptionController,
                      onChanged: (v) {
                        setState(() {
                          description = v;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter description of the item',
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: image_path == ""
                        ? null
                        : Image.file(
                            File(image_path),
                            width: 120,
                            height: 120,
                          ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                                onPressed: () async {
                                  final cameras = await availableCameras();
                                  final firstCamera = cameras.first;
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TakePictureScreen(
                                            camera: firstCamera),
                                      ));
                                  print(result);
                                  setState(() {
                                    image_path = result;
                                  });
                                },
                                color: Colors.pink,
                                textColor: Colors.black,
                                child: image_path == ""
                                    ? Text('Take a picture')
                                    : Text('Retake a picture'));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
                                  uploadImage();
                                  titleController.clear();
                                  priceController.clear();
                                  descriptionController.clear();
                                  setState(() {
                                    showSpinner = false;
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              },
                              color: Colors.pink,
                              textColor: Colors.black,
                              child: Text('Post'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Builder(
                      builder: (context) {
                        return RaisedButton(
                          onPressed: () async {
                            print('before upload' + url);
                            try {
                              _firestore.collection('itemsInfo').add({
                                'user': loggedInUser.email,
                                'title': title,
                                'price': price,
                                'description': description,
                                'image_path': url
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ItemList()));
                            } catch (e) {
                              print(e);
                            }
                          },
                          color: Colors.pink,
                          textColor: Colors.black,
                          child: Text('Check All Posts'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
