import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'post_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_screen.dart';
import 'welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ItemList extends StatefulWidget {
  static String id = 'item_list';
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final _auth = FirebaseAuth.instance;
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
  }

//  Future _showNotificationWithSound() async {
//    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//        'Cool stuff here', 'Garage Sale', 'Sell Whatever You want',
//        sound: 'slow_spring_board',
//        importance: Importance.Max,
//        priority: Priority.High);
//    var iOSPlatformChannelSpecifics =
//    new IOSNotificationDetails(sound: "slow_spring_board.aiff");
//    var platformChannelSpecifics = new NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//      0,
//      'You just added a New Post',
//      'What a wonderful day!',
//      platformChannelSpecifics,
//      payload: 'Custom_Sound',
//    );
//  }
//
//  Future onSelectNotification(String payload) async {
//    showDialog(
//      context: context,
//      builder: (_) {
//        return new AlertDialog(
//          title: Text("PayLoad"),
//          content: Text("Payload : $payload"),
//        );
//      },
//    );
//  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Items For Sale';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Garage Sale'),
          backgroundColor: Colors.pink,
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, PostPage.id);
              },
              child: Text("Post A New Item"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
              child: Text("Log Out"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body:
        MessagesStream(),
//        body: Column(
//        children: <Widget>[
//          MessagesStream(),
//        ]),
      ),
    );
  }
}


class MessagesStream extends StatefulWidget {
  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
  }
  final List<Widget> itemList = [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
//
//        CollectionReference reference = Firestore.instance.collection('posts');
//        reference.snapshots().listen((querySnapshot) {
//          querySnapshot.documentChanges.forEach((change) {
//            // Do something with changie
//            _showNotificationWithSound();
//            print('changed');
//          });
//        });
        final messages = snapshot.data.documents;
        for (var message in messages) {
          final user = message.data['user'];
          final price = message.data['price'];
          final title = message.data['title'];
          final description = message.data['description'];
          final image_path = message.data['image_path'];
          final labels = message.data['labels'].cast<String>();
          final item = Post_item(
            user: user,
            price: price,
            title: title,
            description: description,
            imagePath: image_path,
            labels: labels,
          );
          itemList.add(ListTile(
              leading: CircleAvatar(
                  backgroundImage: item.imagePath == null?
                  AssetImage('images/image.png') : NetworkImage(image_path)),
              title: Text( item.title + "        \$" + item.price.toString()),
              subtitle: Text('Labels : ' + labels[0] + " , " + labels[1] + " , "+ labels[2] + " , "+labels[3] + " , "+labels[4])
//            subtitle: Text(item.description + ' by ' + item.user),
          ));
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: itemList,
        );
      },
    );
  }


//  Future _showNotificationWithSound() async {
//    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//        'Cool stuff here', 'Garage Sale', 'Sell Whatever You want',
//        sound: 'slow_spring_board',
//        importance: Importance.Max,
//        priority: Priority.High);
//    var iOSPlatformChannelSpecifics =
//    new IOSNotificationDetails(sound: "slow_spring_board.aiff");
//    var platformChannelSpecifics = new NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//      0,
//      'Somebody posted a new Item',
//      'Check it out!',
//      platformChannelSpecifics,
//      payload: 'Custom_Sound',
//    );
//  }
//
//  Future onSelectNotification(String payload) async {
//    showDialog(
//      context: context,
//      builder: (_) {
//        return new AlertDialog(
//          title: Text("PayLoad"),
//          content: Text("Payload : $payload"),
//        );
//      },
//    );
//  }
}
