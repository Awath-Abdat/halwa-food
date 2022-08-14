import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:halwa/app/login.dart';

import 'package:alan_voice/alan_voice.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool switchValue = true;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? currentUser;

  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
      currentUser = user;
      setState(() {});
    });
    tellUser("You are now on the account screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlanVoice.setVisualState("{\"screen\" : \"account\"}");
    ThemeData theme = Theme.of(context);

    if (currentUser == null) {
      return SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE85852),
          ),
        ),
      );
    }

    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {}

          if (snapshot.hasData && !snapshot.data!.exists) {}

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            AlanVoice.setVisualState(
                "{\"screen\" : \"account\", \"screen_text\" : \"account\", \"name\": \"${data['firstName']} ${data['lastName']}\"}");

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 30.0,
                    bottom: 15.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    radius: MediaQuery.of(context).size.width * 0.30,
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: data['photoUrl'],
                      ),
                    ),
                  ),
                ),
                Text(
                  "${data['firstName']} ${data['lastName']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 65.0),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.power_settings_new,
                                size: 25.0,
                                color: theme.primaryColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    FirebaseAuth.instance
                                        .signOut()
                                        .then((value) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    });
                                  },
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE85852),
              ),
            );
          }
        },
      ),
    );
  }
}
