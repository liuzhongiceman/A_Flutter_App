import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/post_item.dart';
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
import 'label_item.dart';
import 'post_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PostPage extends StatefulWidget {
  static const id = 'postpage';
  final List<String> labels;
  final String image_path;
  final Post_item item;
  const PostPage({Key key, this.labels, this.image_path, this.item})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PostPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  final _auth = FirebaseAuth.instance;
  String title = "";
  int price = 0;
  String description = "";
//  String image_path = "";

  String url;
//  List<String> labels;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    if (widget.image_path != null) {
      uploadImage();
    }
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
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
        .putFile(File(widget.image_path));
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
                    child: widget.image_path == null
                        ? null
                        : Image.file(
                            File(widget.image_path),
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
                                  final item = Post_item(user:loggedInUser.email, price: price, title :title, description: description,imagePath: null, labels: null);
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TakePictureScreen(
                                            camera: firstCamera, item: item,),
                                      ));
                                  print(result);
//                                  setState(() {
//                                    image_path = result;
//                                  });
                                },
                                color: Colors.pink,
                                textColor: Colors.black,
                                child: widget.image_path == null
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
                                _showNotificationWithSoundNewPost();
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
//                                  uploadImage();
                                  titleController.clear();
                                  priceController.clear();
                                  descriptionController.clear();
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  print('widget item info');
                                  print(widget.item.title);
                                  print(widget.item.price);
                                  print(widget.item.description);
                                  print(url);
                                  _firestore.collection('posts').add({
                                    'user': loggedInUser.email,
                                    'title': widget.item.title,
                                    'price': widget.item.price,
                                    'description': widget.item.description,
                                    'image_path': url,
                                    'labels': widget.labels,
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemList()));
                            print('before upload' + url);
//                            try {
////                              Navigator.push(
////                                  context,
////                                  MaterialPageRoute(
////                                      builder: (context) => ItemList()));
//                              Navigator.pushNamed(context, ItemList.id);
//                            } catch (e) {
//                              print(e);
//                            }
//                            Navigator.pushNamed(context, ItemList.id);
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


  Future _showNotificationWithSoundNewPost() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'Cool stuff here', 'Garage Sale', 'Sell Whatever You want',
        sound: 'slow_spring_board',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'You just added a New Post',
      'What a wonderful day!',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }
}
