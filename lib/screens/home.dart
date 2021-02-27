import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:koukicons/addApp.dart';
import 'package:koukicons/conferenceCall.dart';
import 'package:koukicons/idea.dart';
import 'package:koukicons/phoneMessage.dart';
import 'package:koukicons/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/screens/createChallenge.dart';
import 'package:snaplify/screens/challengeScreen.dart';
import 'package:snaplify/screens/leaderboard.dart';
import 'package:snaplify/screens/notify.dart';
import 'package:snaplify/screens/profile.dart';
import 'package:snaplify/screens/search_bar.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageNumber = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageNumber = index;
    });
  }

  GlobalKey _createChallengeKey = GlobalKey();
  GlobalKey _challengeScreenKey = GlobalKey();
  GlobalKey _searchFriendsKey = GlobalKey();
  GlobalKey _friendsKey = GlobalKey();
  GlobalKey _profileKey = GlobalKey();
  GlobalKey _notificationKey = GlobalKey();

  List<dynamic> testNotification;

  String _currentTitle(int id) {
    if (id == 0) return "Snap-Challenges";
    if (id == 1) return "Friend Leaderboard";
    if (id == 2) return "Notifications";
    if (id == 3) return "Profile";
    return "";
  }

  Widget _currentPage(int id) {
    if (id == 0) return ChallengeScreen();
    if (id == 1) return LeaderBoard();
    if (id == 2) return Notify(notification: testNotification);
    if (id == 3)
      return Profile(userId: Provider.of<Auth>(context, listen: false).userId);
    return Container();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) async => ShowCaseWidget.of(context).startShowCase([
              _createChallengeKey,
              // _challengeScreenKey,
              // _friendsKey,
              // _searchFriendsKey,
              // _profileKey,
              // _notificationKey
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context).userId;
    SharedPreferences preferences;
    BuildContext myContext;

    displayShowCase() async {
      preferences = await SharedPreferences.getInstance();
      bool showCaseHome = preferences.getBool("showCaseHome");
      if (showCaseHome == null) {
        await preferences.setBool("showCaseHome", false);
        return true;
      }
      return false;
    }

    displayShowCase().then((status) {
      if (status) {
        ShowCaseWidget.of(myContext).startShowCase([
          _createChallengeKey,
          _challengeScreenKey,
          _friendsKey,
          _searchFriendsKey,
          _profileKey,
          _notificationKey
        ]);
      }
    });

    return ShowCaseWidget(builder: Builder(builder: (context) {
      myContext = context;
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentTitle(_selectedPageNumber)),
          actions: [
            Showcase(
              key: _searchFriendsKey,
              description: 'Search for Users using this Search Bar',
              showcaseBackgroundColor: Colors.purple,
              textColor: Colors.white,
              shapeBorder: CircleBorder(),
              child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  }),
            )
          ],
        ),
        body: _currentPage(_selectedPageNumber),
        bottomNavigationBar: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("notification")
                .doc(userId)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                if (snapshot.data != null)
                  testNotification = snapshot.data["data"];
              }
              return BottomNavigationBar(
                onTap: _selectPage,
                backgroundColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.white,
                selectedItemColor: Colors.white,
                currentIndex: _selectedPageNumber, // to define the current page
                type: BottomNavigationBarType
                    .shifting, // default is the fixed one
                items: [
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _challengeScreenKey,
                      title: 'Explore Snap Challenges',
                      description: 'View challenges posted by other users!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: KoukiconsIdea(height: 35),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Challenges",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _friendsKey,
                      title: 'Friends and Leaderboard',
                      description:
                          'Compete among your Friends and check them out!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: KoukiconsConferenceCall(height: 35),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Leader Board",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _notificationKey,
                      title: 'Notifications and Updates',
                      description: 'Check your Notifications here!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: KoukiconsPhoneMessage(height: 35),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Notification",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _profileKey,
                      title: 'Your Profile',
                      description: 'You can view your profile from here!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: KoukiconsProfile(height: 35),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "My Profile",
                  )
                ],
              );
            }),
        floatingActionButton: Showcase(
          key: _createChallengeKey,
          title: 'Hi there! Glad to have you on Snaplify!',
          description: 'Create your own Snap Challenge using this button!',
          showcaseBackgroundColor: Colors.purple,
          textColor: Colors.white,
          shapeBorder: CircleBorder(),
          child: FloatingActionButton(
            child: KoukiconsAddApp(height: 35),
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed(CreateChallenge.routeName);
            },
          ),
        ),
      );
    }));
  }
}
