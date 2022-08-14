import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alan_voice/alan_voice.dart';

import 'package:halwa/app/login.dart';

import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final int index;
  Cart({required this.index});
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  late TabController _tabController;
  User? currentUser;
  int total_amount = 0;
  TextEditingController numberController = TextEditingController();

  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  void initState() {
    this._tabController = TabController(
      initialIndex: widget.index,
      length: 2,
      vsync: this,
    );

    tellUser("You are now on the cart screen");

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        currentUser = user;
        setState(() {});
      }
    });

    AlanVoice.onCommand.add((command) {
      Map<String, dynamic> data = command.data;
      print("Command is: " + data['command'].toString());
      switch (data['command'].toString()) {
        case 'remove_item':
          {
            FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser!.uid)
                .collection("uncheckedout")
                .where('name', isEqualTo: data['item'])
                .get()
                .then((value) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser!.uid)
                  .collection("uncheckedout")
                  .doc(value.docs.first.id)
                  .delete()
                  .then((value) {
                tellUser("Successfuly removed ${data['item']} from cart.");
              }).onError((error, stackTrace) {
                tellUser(
                    "There was an error removing cart item. ${error.toString()}");
              });
            }).onError((error, stackTrace) {
              tellUser(
                  "There was an error getting cart item. ${error.toString()}");
            });
          }
          break;
        case 'readCart':
          {
            FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser!.uid)
                .collection("uncheckedout")
                .get()
                .then((value) {
              var data = value.docs;
              String cart_items = "";
              String cart_items_intent = "";
              int count = 0;
              data.forEach((element) {
                cart_items +=
                    "{\"name\" : \"${element.get("name")}\", \"id\" : \"${element.id}\"}" +
                        (count + 1 == data.length ? "" : ", ");
                cart_items_intent += element.get("name") +
                    (count + 1 == data.length ? "" : " | ");
                count++;
              });
              AlanVoice.callProjectApi(
                  "listCartItems", "{\"cart_items\":[$cart_items]}");
            }).onError((error, stackTrace) {
              tellUser(
                  "There was an error retrieving cart items. ${error.toString()}");
            });
          }
          break;
        default:
          {}
          break;
      }
    });

    super.initState();
  }

  void checkOut() {
    if (numberController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .collection("uncheckedout")
          .get()
          .then((value) {
        if (value.docs.length > 0) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser!.uid)
                .collection("checkedout")
                .add(element.data())
                .then((value) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser!.uid)
                  .collection("uncheckedout")
                  .doc(element.id)
                  .delete()
                  .then((value) => null);
            });
          });
        }
      }).whenComplete(() {
        Navigator.of(context).pop();
      });
    }
  }

  Widget renderAddList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid)
            .collection("uncheckedout")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            tellUser(
                "An error has occured. Make sure you have good internet connection and try again.");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error,
                    size: 60.0,
                    color: Colors.grey.shade400,
                  ),
                  Text(
                    "Error.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 19.0,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.length == 0) {
            tellUser("The cart is empty.");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    size: 60.0,
                    color: Colors.grey.shade400,
                  ),
                  Text(
                    "No items in cart yet.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 19.0,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.length > 0) {
            var data = snapshot.data!.docs;
            String cart_items = "";
            String cart_items_intent = "";
            int count = 0;
            data.forEach((element) {
              total_amount += element.get("price") as int;
              cart_items +=
                  "{\"name\" : \"${element.get("name")}\", \"id\" : \"${element.id}\"}" +
                      (count + 1 == data.length ? "" : ", ");
              cart_items_intent +=
                  element.get("name") + (count + 1 == data.length ? "" : " | ");
              count++;
            });
            AlanVoice.callProjectApi("listCartItems",
                "{\"screen\" : \"cart\", \"screen_text\" : \"cart\", \"cart_items\":[$cart_items], \"cart_items_intent\": \"$cart_items_intent\"}");

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var food = snapshot.data!.docs.elementAt(index);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'details',
                        arguments: {
                          'product': food,
                          'index': index,
                        },
                      );
                    },
                    child: Card(
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    food.get('imageUrl')),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(food.get('name')),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(currentUser!.uid)
                                              .collection("uncheckedout")
                                              .doc(food.id)
                                              .delete();
                                        },
                                      )
                                    ],
                                  ),
                                  Text('\UGX ${food.get('price')}'),
                                  Text(
                                    '\X ${food.get('quantity')}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        });
  }

  Widget renderDoneOrder() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid)
            .collection("checkedout")
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            tellUser(
                "An error has occured. Make sure you have good internet connection and try again.");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error,
                    size: 60.0,
                    color: Colors.grey.shade400,
                  ),
                  Text(
                    "Error.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 19.0,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.length == 0) {
            tellUser("The cart is empty.");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.history,
                    size: 60.0,
                    color: Colors.grey.shade400,
                  ),
                  Text(
                    "No items in cart yet.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 19.0,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.length > 0) {
            //Send data to Alan Voice
            var data = snapshot.data!.docs;
            String history_items = "";
            int count = 0;
            data.forEach((element) {
              history_items += "\"" +
                  element.get("name") +
                  "\"" +
                  (count + 1 == data.length ? "" : ", ");
              count++;
            });
            AlanVoice.setVisualState(
                "{\"screen\" : \"history\", \"screen_text\" : \"history\", \"history_items\":[$history_items]}");

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var food = snapshot.data!.docs.elementAt(index);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'details',
                        arguments: {
                          'product': food,
                          'index': index,
                        },
                      );
                    },
                    child: Card(
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    food.get('imageUrl')),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(food.get('name')),
                                  Text('\UGX ${food.get('price')}'),
                                  Text(
                                    '\X ${food.get('quantity')}',
                                  ),
                                  Text(
                                    '${DateFormat('dd-MM-yyyy').format((food.get('date') as Timestamp).toDate())}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _tabController.index == 0
        ? AlanVoice.setVisualState(
            "{\"screen\" : \"cart\", \"screen_text\" : \"cart\"}")
        : AlanVoice.setVisualState(
            "{\"screen\" : \"history\", \"screen_text\" : \"history\"}");
    ;
    ThemeData theme = Theme.of(context);
    if (currentUser != null)
      return SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                top: 10.0,
              ),
              child: TabBar(
                controller: this._tabController,
                indicatorColor: theme.primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black87,
                tabs: <Widget>[
                  Tab(text: 'Cart'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: TabBarView(
                  controller: this._tabController,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: this.renderAddList(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 15.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: theme.primaryColor,
                          ),
                          child: TextButton(
                              child: Text(
                                'CHECKOUT',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        title: Text("CheckOut"),
                                        content: Column(
                                          children: <Widget>[
                                            TextField(
                                              controller: numberController,
                                              keyboardType: TextInputType.phone,
                                              autocorrect: true,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: theme.primaryColor,
                                                      width: 1.0),
                                                ),
                                                hintText: 'Input phone number',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 19.0,
                                                ),
                                              ),
                                            ),
                                            Text('\UGX $total_amount')
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 19.0,
                                                      )),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: theme.primaryColor,
                                                  ),
                                                  child: TextButton(
                                                    child: Text(
                                                      'CheckOut',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    onPressed: checkOut,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              }),
                        ),
                      ],
                    ),
                    this.renderDoneOrder(),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    else
      return SafeArea(
          child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ));
  }
}
