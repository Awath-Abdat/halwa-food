import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:halwa/app/details.dart';
import 'package:halwa/app/restaurant.dart';
import 'package:halwa/app/search.dart';

import 'package:alan_voice/alan_voice.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchFieldController = TextEditingController();

  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  void initState() {
    tellUser("You are now on the home screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlanVoice.setVisualState(
        "{\"screen\" : \"home\", \"screen_text\" : \"home\"}");
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'What would you like to eat?',
                    style: TextStyle(fontSize: 21.0),
                  ),
                  Icon(Icons.notifications_none, size: 28.0)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: TextField(
                controller: searchFieldController,
                keyboardType: TextInputType.text,
                autocorrect: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.0),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 28.0,
                    color: theme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_right,
                      size: 28.0,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      if (searchFieldController.text.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => Search(
                                    keyword:
                                        searchFieldController.text.trim()))));
                      }
                    },
                  ),
                  hintText: 'Find a food or Restaurant',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 19.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, bottom: 10.0, top: 10.0),
              child: Text(
                'Popular Food',
                style: TextStyle(fontSize: 21.0),
              ),
            ),
            Container(
              height: 260.0,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collectionGroup("food_items")
                      .where("name", isNotEqualTo: null)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      );
                    }
                    var docs = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot product = docs.elementAt(index);
                        return StreamBuilder<DocumentSnapshot>(
                            stream: (product.reference.parent.parent
                                    as DocumentReference)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Container(
                                  width: size.width / 2 - 30.0,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 140.0,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        product
                                                            .get('photoUrl')),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 4.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              product.get('name'),
                                              style: TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 20.0,
                                                      color: Colors.grey[300],
                                                    ),
                                                    Text(
                                                      "${(product.get('numStars')! as int).toDouble() / (product.get('numRatings') as int).toDouble()}",
                                                      style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "\UGX ${product.get('price')}",
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                String restaurantName =
                                    snapshot.data!.get('name');
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Details(
                                              name: product.get('name'),
                                              imageUrl: product.get('photoUrl'),
                                              price: product.get('price'),
                                              restaurantName: restaurantName)),
                                    );
                                  },
                                  child: Container(
                                    width: size.width / 2 - 30.0,
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(10.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 140.0,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          product
                                                              .get('photoUrl')),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                product.get('name'),
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 20.0,
                                                    color: Colors.grey[300],
                                                  ),
                                                  Text(
                                                    "${(product.get('numStars')! as int).toDouble() / (product.get('numRatings') as int).toDouble()}",
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "\UGX ${product.get('price')}",
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            });
                      },
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                bottom: 10.0,
                top: 35.0,
              ),
              child: Text(
                'Restaurants',
                style: TextStyle(fontSize: 21.0),
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("restaurants")
                      .where("name", isNotEqualTo: null)
                      .orderBy("numStars", descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      );
                    }
                    var docs = snapshot.data!.docs;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10.0),
                      scrollDirection: Axis.vertical,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot restaurant =
                            docs.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Restaurant(
                                        id: restaurant.reference.id,
                                        name: restaurant.get('name'),
                                        imageUrl: restaurant.get('photoUrl'),
                                      )),
                            );
                          },
                          child: Container(
                            width: size.width - 40,
                            color: Colors.white,
                            padding: const EdgeInsets.only(bottom: 10.0),
                            margin: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 15.0,
                            ),
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      height: (size.width - 40) * 9 / 16,
                                      width: size.width - 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              restaurant.get('photoUrl')),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 4.0,
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "${restaurant.get('name')}",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5.0,
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.star,
                                        size: 20.0,
                                        color: Colors.grey[300],
                                      ),
                                      Text(
                                        (restaurant.get('numStars').toDouble() /
                                                restaurant
                                                    .get('numRatings')
                                                    .toDouble())
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
