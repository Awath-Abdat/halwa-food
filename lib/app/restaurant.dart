import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:alan_voice/alan_voice.dart';
import 'package:halwa/app/details.dart';

class Restaurant extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;

  const Restaurant(
      {required this.id, required this.name, required this.imageUrl});

  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  _RestaurantState() {}

  void tellUser(String text) async {
    var isActive = await AlanVoice.isActive();
    if (!isActive) {
      AlanVoice.activate();
    }
    AlanVoice.callProjectApi("script::tellUser", "{\"text\":\"$text\"}");
  }

  @override
  void initState() {
    tellUser("You are now on ${widget.name}'s screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlanVoice.setVisualState(
        "{\"screen\" : \"restaurant\", \"screen_text\" : \"${widget.name} restaurant\"}");
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: theme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.name),
                background: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(color: theme.primaryColor),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("restaurants")
                          .doc(widget.id)
                          .collection('food_items')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            QueryDocumentSnapshot product =
                                docs.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                            name: product.get('name'),
                                            imageUrl: product.get('photoUrl'),
                                            price: product.get('price'),
                                            restaurantName: widget.name)));
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.only(bottom: 10.0, top: 10.0),
                                padding: EdgeInsets.all(5.0),
                                child: Card(
                                  child: Container(
                                    width: size.width - 40,
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 80.0,
                                              width: 80.0,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
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
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${product.get('name')}",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.star,
                                                    size: 20.0,
                                                    color: Colors.grey[300],
                                                  ),
                                                  Text(
                                                    (product
                                                                .get('numStars')
                                                                .toDouble() /
                                                            product
                                                                .get(
                                                                    'numRatings')
                                                                .toDouble())
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
