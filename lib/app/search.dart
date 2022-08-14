import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:alan_voice/alan_voice.dart';
import 'package:halwa/app/details.dart';

import 'package:halwa/app/restaurant.dart';

class Search extends StatefulWidget {
  final String keyword;
  const Search({required this.keyword});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  void initState() {
    tellUser("You are now on the search screen for ${widget.keyword}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlanVoice.setVisualState(
        "{\"screen\" : \"search\", \"screen_text\" : \"search ${widget.keyword}\"}");
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search: " + widget.keyword,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, bottom: 10.0, top: 10.0),
                child: Text(
                  'Food Items',
                  style: TextStyle(fontSize: 21.0),
                ),
              ),
              Container(
                height: 260.0,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collectionGroup("food_items")
                        .where("name", isGreaterThanOrEqualTo: widget.keyword)
                        .where("name",
                            isLessThanOrEqualTo: widget.keyword + '\uf8ff')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        );
                      }

                      if (snapshot.data!.docs.length == 0) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.shopping_cart,
                                size: 30.0,
                                color: Colors.grey.shade400,
                              ),
                              Text(
                                "No food items.",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 19.0,
                                ),
                              ),
                            ],
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
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
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
                                                          color:
                                                              Colors.grey[400],
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
                                                imageUrl:
                                                    product.get('photoUrl'),
                                                price: product.get('price'),
                                                restaurantName:
                                                    restaurantName)),
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
                                                            product.get(
                                                                'photoUrl')),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                        .where("name", isGreaterThanOrEqualTo: widget.keyword)
                        .where("name",
                            isLessThanOrEqualTo: widget.keyword + '\uf8ff')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        );
                      }

                      if (snapshot.data!.docs.length == 0) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 40.0,
                          height: MediaQuery.of(context).size.width / 2,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.shopping_cart,
                                  size: 30.0,
                                  color: Colors.grey.shade400,
                                ),
                                Text(
                                  "No restaurants.",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 19.0,
                                  ),
                                ),
                              ],
                            ),
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
                                          (restaurant
                                                      .get('numStars')
                                                      .toDouble() /
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
      ),
    );
  }
}
