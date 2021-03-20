import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:koukicons/addApp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snaplify/providers/auth.dart';
import 'package:snaplify/screens/createChallenge.dart';
import 'package:snaplify/screens/challengeScreen.dart';
import 'package:snaplify/screens/leaderboard.dart';
import 'package:snaplify/screens/notify.dart';
import 'package:snaplify/widgets/profile.dart';
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
  BuildContext myContext;
  var notifications = [];

  String _currentTitle(int id) {
    if (id == 0) return "Snaplify";
    if (id == 1) return "Friend Leaderboard";
    if (id == 2) return "Notifications";
    if (id == 3) return "My Profile";
    return "";
  }

  Widget _currentPage(int id) {
    if (id == 0) return ChallengeScreen();
    if (id == 1) return LeaderBoard();
    if (id == 2) return Notify(notification: notifications);
    if (id == 3)
      return Profile(userId: Provider.of<Auth>(context, listen: false).userId);
    return Container();
  }

  displayShowCase() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool showCaseHome = preferences.getBool("showCaseHome");
    if (showCaseHome == null) {
      await preferences.setBool("showCaseHome", false);
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      displayShowCase().then((res) {
        if (res)
          ShowCaseWidget.of(myContext).startShowCase([
            _createChallengeKey,
            _challengeScreenKey,
            _friendsKey,
            _notificationKey,
            _profileKey,
            _searchFriendsKey
          ]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context, listen: false).userId;

    return ShowCaseWidget(builder: Builder(builder: (context) {
      myContext = context;
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(_currentTitle(_selectedPageNumber)),
          actions: [
            Showcase(
              key: _searchFriendsKey,
              contentPadding: const EdgeInsets.all(10),
              title: 'Find Friends',
              description: 'Search for friends using this Search Bar',
              showcaseBackgroundColor: Colors.purple,
              textColor: Colors.white,
              shapeBorder: CircleBorder(),
              child: IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  }),
            )
          ],
        ),
        body: _currentPage(_selectedPageNumber),
        bottomNavigationBar: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(userId)
                .collection("notification")
                .where("seen", isEqualTo: false)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                notifications = snapshot.data.docs;
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
                      contentPadding: const EdgeInsets.all(10),
                      title: 'Explore Snap Challenges',
                      description: 'View challenges posted by other users!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: Icon(
                        Icons.workspaces_filled,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Challenges",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _friendsKey,
                      contentPadding: const EdgeInsets.all(10),
                      title: 'Friends and Leaderboard',
                      description:
                          'Compete among your Friends and check them out!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: Icon(
                        Icons.leaderboard_rounded,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Leader Board",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                        key: _notificationKey,
                        contentPadding: const EdgeInsets.all(10),
                        title: 'Notifications and Updates',
                        description: 'Check your Notifications here!',
                        showcaseBackgroundColor: Colors.purple,
                        textColor: Colors.white,
                        shapeBorder: CircleBorder(),
                        child: Badge(
                            position: BadgePosition.topStart(),
                            badgeContent: Text("${notifications.length}"),
                            child: Icon(
                              Icons.notifications,
                              size: 30,
                            ))),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "Notification",
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _profileKey,
                      contentPadding: const EdgeInsets.all(10),
                      title: 'Your Profile',
                      description: 'You can view your profile from here!',
                      showcaseBackgroundColor: Colors.purple,
                      textColor: Colors.white,
                      shapeBorder: CircleBorder(),
                      child: Icon(Icons.person, size: 30),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "My Profile",
                  )
                ],
              );
            }),
        floatingActionButton: Showcase(
          key: _createChallengeKey,
          contentPadding: const EdgeInsets.all(10),
          title: 'Hi there! Welcome to Snaplify', //'Hi there! ',
          description:
              'Create your own Snap Challenge using this button!', //'Create your own Snap\n Challenge using this button!',
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
