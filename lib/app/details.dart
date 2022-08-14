import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:alan_voice/alan_voice.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:halwa/app/login.dart';

import 'package:halwa/app/app.dart';

class Details extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final String restaurantName;

  const Details(
      {required this.name,
      required this.imageUrl,
      required this.price,
      required this.restaurantName});

  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int qty = 1;
  User? currentUser;
  List<Map<String, dynamic>> unCheckedOutList = [];

  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  initState() {
    tellUser(
        "You are now on the details screen of ${widget.restaurantName}'s ${widget.name}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlanVoice.setVisualState(
        "{\"screen\" : \"details\", \"screen_text\" : \"details of ${widget.restaurantName}'s ${widget.name}\"}");
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        currentUser = user;
      }
    });

    currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40.0,
                    height: MediaQuery.of(context).size.width - 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.imageUrl),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(width: 1.0, color: Colors.grey[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: [BoxShadow()],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 20.0),
                    child: Text(
                      widget.restaurantName,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '\UGX ${widget.price}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).primaryColor)),
                        child: IconButton(
                          onPressed: () {
                            if (qty > 1) {
                              qty -= 1;
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.remove,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 80.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            border: Border.all(
                                width: 1.0, color: Colors.blueAccent)),
                        child: Center(child: Text('${qty}')),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).primaryColor)),
                        child: IconButton(
                          onPressed: () {
                            if (qty < 19) {
                              qty += 1;
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(currentUser!.uid)
                              .collection("uncheckedout")
                              .where("name", isEqualTo: widget.name)
                              .where("restaurantName",
                                  isEqualTo: widget.restaurantName)
                              .get()
                              .then((value) {
                            if (value.docs.length > 0) {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUser!.uid)
                                  .collection("uncheckedout")
                                  .doc(value.docs.first.id)
                                  .update({
                                "quantity": qty,
                              }).then((value) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => App(index: 1)));
                              });
                            } else {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUser!.uid)
                                  .collection("uncheckedout")
                                  .doc()
                                  .set({
                                "name": widget.name,
                                "imageUrl": widget.imageUrl,
                                "price": widget.price,
                                "restaurantName": widget.restaurantName,
                                "date": DateTime.now(),
                                "quantity": qty,
                              }).then((value) {
                                Navigator.pop(context);
                              });
                            }
                          });
                        },
                        child: Container(
                          width: 80.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: Center(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                backgroundColor: Theme.of(context).primaryColor,
                                color: Colors.white,
                              ),
                            ),
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
      ),
    );
  }
}
