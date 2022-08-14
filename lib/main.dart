import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:halwa/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:halwa/app/app.dart';
import 'package:halwa/app/login.dart';
import 'package:halwa/app/restaurant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(MyApp(false));
    } else {
      runApp(MyApp(true));
    }
  });
}

class MyApp extends StatelessWidget {
  bool loggedIn = false;

  MyApp(bool _loggedIn) {
    loggedIn = _loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Cera Pro",
        primaryColor: Color(0xFFE85852),
      ),
      routes: {
        'login': (context) => (loggedIn ? App(index: 0) : Login()),
      },
      home: (loggedIn ? App(index: 0) : Login()),
      debugShowCheckedModeBanner: false,
    );
  }
}
