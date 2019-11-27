import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/process_image.dart';
import 'package:hyper_garage_sale/welcome_screen.dart';
import 'package:hyper_garage_sale/post_screen.dart';
import 'package:hyper_garage_sale/login_screen.dart';
import 'package:hyper_garage_sale/registration_screen.dart';
import 'package:hyper_garage_sale/list_view_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Sale',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        RegistrationScreen.id : (context) => RegistrationScreen(),
        PostPage.id: (context) => PostPage(),
        Process_Image.id: (context) => Process_Image(),
        ItemList.id: (context) => ItemList(),
      },
    );
  }

}
