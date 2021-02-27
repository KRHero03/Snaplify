import 'package:flutter/material.dart';
import 'package:koukicons/addApp.dart';
import 'package:koukicons/conferenceCall.dart';
import 'package:koukicons/idea.dart';
import 'package:koukicons/phoneMessage.dart';
import 'package:koukicons/profile.dart';
import 'package:koukicons/rating.dart';
import 'package:snaplify/screens/createchallenge.dart';
import 'package:snaplify/screens/friends.dart';
import 'package:snaplify/screens/challenges.dart';
import 'package:snaplify/screens/leaderboard.dart';
import 'package:snaplify/screens/notify.dart';
import 'package:snaplify/screens/profile.dart';
import 'package:snaplify/screens/search_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageNumber = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageNumber = index;
    });
  }

  void initState() {
    _pages = [
      {
        'page': Friends(),
        'title': 'Friends',
      },
      {
        'page': LeaderBoard(),
        'title': 'LeaderBoard',
      },
      {
        'page': Challenge(),
        'title': 'Challenges',
      },
      {
        'page': Notify(),
        'title': 'Notification',
      },
      {
        'page': Profile(),
        'title': 'My Profile',
      },
    ];
    _selectedPageNumber = 2;
    // or copy inside the build method;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageNumber]['title']),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              })
        ],
      ),
      body: _pages[_selectedPageNumber]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.orange,
        currentIndex: _selectedPageNumber, // to define the current page
        type: BottomNavigationBarType.shifting, // default is the fixed one
        items: [
          BottomNavigationBarItem(
            icon: KoukiconsConferenceCall(height: 35),
            backgroundColor: Theme.of(context).primaryColor,
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: KoukiconsRating(height: 35),
            backgroundColor: Theme.of(context).primaryColor,
            label: "Leader Board",
          ),
          BottomNavigationBarItem(
            icon: KoukiconsIdea(height: 35),
            backgroundColor: Theme.of(context).primaryColor,
            label: "Challenges",
          ),
          BottomNavigationBarItem(
            icon: KoukiconsPhoneMessage(height: 35),
            backgroundColor: Theme.of(context).primaryColor,
            label: "Notification",
          ),
          BottomNavigationBarItem(
            icon: KoukiconsProfile(height: 35),
            backgroundColor: Theme.of(context).primaryColor,
            label: "My Profile",
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: KoukiconsAddApp(height: 35),
        onPressed: () {
          Navigator.of(context).pushNamed(CreateChallenge.routeName);
        },
      ),
    );
  }
}
