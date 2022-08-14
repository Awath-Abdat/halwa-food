import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:halwa/app/account.dart';
import 'package:halwa/app/cart.dart';
import 'package:halwa/app/home.dart';
import 'package:alan_voice/alan_voice.dart';

class App extends StatefulWidget {
  int index;
  App({this.index = 0});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    this._tabController =
        TabController(length: 3, initialIndex: widget.index, vsync: this);
    AlanVoice.addButton(
      "89ca3fdf40ab4ae319aa1fdbb85a1cdc2e956eca572e1d8b807a3e2338fdd0dc/stage",
      buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT,
      bottomMargin: 40,
    );

    AlanVoice.onCommand.add((command) {
      Map<String, dynamic> data = command.data;
      switch (data['command'].toString()) {
        case 'navigate':
          {
            switch (data['screen'].toString().toLowerCase()) {
              case 'home':
                {
                  _tabController.animateTo(0);
                }
                break;
              case 'cart':
                {
                  setState(() {
                    widget.index = 0;
                  });
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _tabController.animateTo(1);
                  });
                }
                break;
              case 'history':
                {
                  setState(() {
                    widget.index = 1;
                  });
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _tabController.animateTo(1);
                  });
                }
                break;
              case 'account':
                {
                  _tabController.animateTo(2);
                }
                break;
              default:
                {
                  AlanVoice.playText("Could not recognise screen.");
                }
                break;
            }
          }
          break;
        default:
          {}
          break;
      }
    });

    AlanVoice.setLogLevel("none");
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Home(),
          Cart(index: widget.index),
          Account(),
        ],
      ),
      bottomNavigationBar: Material(
        color: theme.primaryColor,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home, size: 28),
            ),
            Tab(
              icon: Icon(Icons.shopping_cart, size: 28),
            ),
            Tab(
              icon: Icon(Icons.person_outline, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
